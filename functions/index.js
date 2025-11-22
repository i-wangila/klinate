const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const cors = require('cors')({ origin: true });

admin.initializeApp();

// M-Pesa Configuration
const MPESA_CONFIG = {
    consumerKey: functions.config().mpesa?.consumer_key || '',
    consumerSecret: functions.config().mpesa?.consumer_secret || '',
    businessShortCode: functions.config().mpesa?.business_short_code || '',
    passkey: functions.config().mpesa?.passkey || '',
    environment: functions.config().mpesa?.environment || 'sandbox',
};

const MPESA_BASE_URL = MPESA_CONFIG.environment === 'production'
    ? 'https://api.safaricom.co.ke'
    : 'https://sandbox.safaricom.co.ke';

// Helper: Get M-Pesa Access Token
async function getMpesaAccessToken() {
    try {
        console.log('Getting M-Pesa access token...');
        console.log('Environment:', MPESA_CONFIG.environment);
        console.log('Base URL:', MPESA_BASE_URL);
        console.log('Consumer Key:', MPESA_CONFIG.consumerKey ? 'Set' : 'Missing');
        console.log('Consumer Secret:', MPESA_CONFIG.consumerSecret ? 'Set' : 'Missing');

        const auth = Buffer.from(
            `${MPESA_CONFIG.consumerKey}:${MPESA_CONFIG.consumerSecret}`
        ).toString('base64');

        const response = await axios.get(
            `${MPESA_BASE_URL}/oauth/v1/generate?grant_type=client_credentials`,
            {
                headers: {
                    Authorization: `Basic ${auth}`,
                },
            }
        );

        console.log('Access token obtained successfully');
        return response.data.access_token;
    } catch (error) {
        console.error('M-Pesa Auth Error Details:', {
            status: error.response?.status,
            statusText: error.response?.statusText,
            data: error.response?.data,
            message: error.message,
        });
        throw new Error(
            `Failed to authenticate with M-Pesa: ${error.response?.data?.error_description || error.message}`
        );
    }
}

// Helper: Generate M-Pesa Password
function generateMpesaPassword() {
    const timestamp = getTimestamp();
    const password = Buffer.from(
        `${MPESA_CONFIG.businessShortCode}${MPESA_CONFIG.passkey}${timestamp}`
    ).toString('base64');
    return { password, timestamp };
}

// Helper: Get Timestamp
function getTimestamp() {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    return `${year}${month}${day}${hours}${minutes}${seconds}`;
}

// Helper: Format Phone Number
function formatPhoneNumber(phone) {
    let cleaned = phone.replace(/\D/g, '');
    if (cleaned.startsWith('0')) {
        cleaned = '254' + cleaned.substring(1);
    } else if (!cleaned.startsWith('254')) {
        cleaned = '254' + cleaned;
    }
    return cleaned;
}

// Cloud Function: Initiate STK Push (Top Up)
exports.initiateSTKPush = functions.https.onCall(async (data, context) => {
    // TODO: Add proper authentication later
    // For now, allow unauthenticated requests for testing
    const userId = context.auth?.uid || 'anonymous';

    const { phoneNumber, amount, accountReference } = data;

    // Validate input
    if (!phoneNumber || !amount || amount <= 0) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Phone number and valid amount are required'
        );
    }

    try {
        const accessToken = await getMpesaAccessToken();
        const { password, timestamp } = generateMpesaPassword();
        const formattedPhone = formatPhoneNumber(phoneNumber);

        const requestBody = {
            BusinessShortCode: MPESA_CONFIG.businessShortCode,
            Password: password,
            Timestamp: timestamp,
            TransactionType: 'CustomerPayBillOnline',
            Amount: Math.floor(amount),
            PartyA: formattedPhone,
            PartyB: MPESA_CONFIG.businessShortCode,
            PhoneNumber: formattedPhone,
            CallBackURL: `${functions.config().app?.url || ''}/mpesaCallback`,
            AccountReference: accountReference || 'Klinate',
            TransactionDesc: 'Wallet Top Up',
        };

        const response = await axios.post(
            `${MPESA_BASE_URL}/mpesa/stkpush/v1/processrequest`,
            requestBody,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        // Store transaction in Firestore
        await admin.firestore().collection('mpesa_transactions').add({
            userId: userId,
            type: 'topup',
            amount: amount,
            phoneNumber: formattedPhone,
            checkoutRequestId: response.data.CheckoutRequestID,
            merchantRequestId: response.data.MerchantRequestID,
            status: 'pending',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
            success: true,
            message: 'STK Push sent successfully',
            checkoutRequestId: response.data.CheckoutRequestID,
            merchantRequestId: response.data.MerchantRequestID,
        };
    } catch (error) {
        console.error('STK Push error:', error.response?.data || error.message);
        throw new functions.https.HttpsError(
            'internal',
            error.response?.data?.errorMessage || 'Failed to initiate STK Push'
        );
    }
});

// Cloud Function: Query STK Push Status
exports.querySTKPushStatus = functions.https.onCall(async (data, context) => {
    // TODO: Add proper authentication later
    const userId = context.auth?.uid || 'anonymous';

    const { checkoutRequestId } = data;

    if (!checkoutRequestId) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Checkout Request ID is required'
        );
    }

    try {
        const accessToken = await getMpesaAccessToken();
        const { password, timestamp } = generateMpesaPassword();

        const requestBody = {
            BusinessShortCode: MPESA_CONFIG.businessShortCode,
            Password: password,
            Timestamp: timestamp,
            CheckoutRequestID: checkoutRequestId,
        };

        const response = await axios.post(
            `${MPESA_BASE_URL}/mpesa/stkpushquery/v1/query`,
            requestBody,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        return {
            success: true,
            resultCode: response.data.ResultCode,
            resultDesc: response.data.ResultDesc,
        };
    } catch (error) {
        console.error('Query error:', error.response?.data || error.message);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to query transaction status'
        );
    }
});

// Cloud Function: M-Pesa Callback
exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
    cors(req, res, async () => {
        try {
            const callbackData = req.body;
            console.log('M-Pesa Callback:', JSON.stringify(callbackData));

            const { Body } = callbackData;
            const { stkCallback } = Body;

            const {
                MerchantRequestID,
                CheckoutRequestID,
                ResultCode,
                ResultDesc,
            } = stkCallback;

            // Update transaction in Firestore
            const transactionQuery = await admin
                .firestore()
                .collection('mpesa_transactions')
                .where('checkoutRequestId', '==', CheckoutRequestID)
                .limit(1)
                .get();

            if (!transactionQuery.empty) {
                const transactionDoc = transactionQuery.docs[0];
                const updateData = {
                    resultCode: ResultCode,
                    resultDesc: ResultDesc,
                    status: ResultCode === 0 ? 'completed' : 'failed',
                    completedAt: admin.firestore.FieldValue.serverTimestamp(),
                };

                // If successful, extract transaction details
                if (ResultCode === 0 && stkCallback.CallbackMetadata) {
                    const metadata = {};
                    stkCallback.CallbackMetadata.Item.forEach((item) => {
                        metadata[item.Name] = item.Value;
                    });
                    updateData.metadata = metadata;

                    // Update user wallet balance
                    const transaction = transactionDoc.data();
                    const userRef = admin.firestore().collection('users').doc(transaction.userId);
                    await userRef.update({
                        'wallet.balance': admin.firestore.FieldValue.increment(transaction.amount),
                        'wallet.lastUpdated': admin.firestore.FieldValue.serverTimestamp(),
                    });
                }

                await transactionDoc.ref.update(updateData);
            }

            res.status(200).json({ ResultCode: 0, ResultDesc: 'Success' });
        } catch (error) {
            console.error('Callback error:', error);
            res.status(500).json({ ResultCode: 1, ResultDesc: 'Failed' });
        }
    });
});

// Cloud Function: Initiate Withdrawal (B2C)
exports.initiateWithdrawal = functions.https.onCall(async (data, context) => {
    // TODO: Add proper authentication later
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'User must be authenticated for withdrawals'
        );
    }

    const { phoneNumber, amount } = data;

    if (!phoneNumber || !amount || amount <= 0) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Phone number and valid amount are required'
        );
    }

    try {
        // Check user balance first
        const userDoc = await admin
            .firestore()
            .collection('users')
            .doc(context.auth.uid)
            .get();

        const userBalance = userDoc.data()?.wallet?.balance || 0;
        if (userBalance < amount) {
            throw new functions.https.HttpsError(
                'failed-precondition',
                'Insufficient balance'
            );
        }

        const accessToken = await getMpesaAccessToken();
        const formattedPhone = formatPhoneNumber(phoneNumber);

        const requestBody = {
            InitiatorName: functions.config().mpesa?.initiator_name || 'Klinate',
            SecurityCredential: functions.config().mpesa?.security_credential || '',
            CommandID: 'BusinessPayment',
            Amount: Math.floor(amount),
            PartyA: MPESA_CONFIG.businessShortCode,
            PartyB: formattedPhone,
            Remarks: 'Wallet Withdrawal',
            QueueTimeOutURL: `${functions.config().app?.url || ''}/mpesaB2CTimeout`,
            ResultURL: `${functions.config().app?.url || ''}/mpesaB2CResult`,
            Occasion: 'Withdrawal',
        };

        const response = await axios.post(
            `${MPESA_BASE_URL}/mpesa/b2c/v1/paymentrequest`,
            requestBody,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        // Deduct from wallet and store transaction
        await admin.firestore().collection('mpesa_transactions').add({
            userId: context.auth.uid,
            type: 'withdrawal',
            amount: amount,
            phoneNumber: formattedPhone,
            conversationId: response.data.ConversationID,
            originatorConversationId: response.data.OriginatorConversationID,
            status: 'pending',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Deduct from wallet
        await admin.firestore().collection('users').doc(context.auth.uid).update({
            'wallet.balance': admin.firestore.FieldValue.increment(-amount),
            'wallet.lastUpdated': admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
            success: true,
            message: 'Withdrawal initiated successfully',
            conversationId: response.data.ConversationID,
        };
    } catch (error) {
        console.error('Withdrawal error:', error.response?.data || error.message);
        throw new functions.https.HttpsError(
            'internal',
            error.response?.data?.errorMessage || 'Failed to initiate withdrawal'
        );
    }
});

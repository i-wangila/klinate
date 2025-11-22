import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet.dart';
import 'wallet_service.dart';
import 'user_service.dart';

/// C2B Payment Service - Facilitates direct payments to provider M-Pesa accounts
/// This service helps users pay directly to healthcare providers' paybill/till numbers
class C2BPaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initiate payment to a provider's M-Pesa paybill/till
  /// This creates a payment record and provides instructions for the user
  static Future<Map<String, dynamic>> initiateProviderPayment({
    required String providerId,
    required String providerName,
    required double amount,
    required String description,
    String? appointmentId,
  }) async {
    try {
      // Get provider's M-Pesa payment details
      final providerDoc = await _firestore
          .collection('provider_profiles')
          .doc(providerId)
          .get();

      if (!providerDoc.exists) {
        throw Exception('Provider not found');
      }

      final providerData = providerDoc.data()!;
      final paymentMethods = List<String>.from(
        providerData['paymentMethods'] ?? [],
      );

      // Extract M-Pesa payment details from payment methods
      String? paybillNumber;
      String? accountNumber;
      String? tillNumber;

      for (var method in paymentMethods) {
        if (method.contains('Paybill')) {
          // Extract paybill number from string like "M-Pesa Paybill: 123456 (Acc: 789)"
          final paybillMatch = RegExp(r'Paybill:\s*(\d+)').firstMatch(method);
          if (paybillMatch != null) {
            paybillNumber = paybillMatch.group(1);
          }
          final accountMatch = RegExp(r'Acc:\s*([^\)]+)').firstMatch(method);
          if (accountMatch != null) {
            accountNumber = accountMatch.group(1)?.trim();
          }
        } else if (method.contains('Till')) {
          // Extract till number from string like "M-Pesa Till: 123456"
          final tillMatch = RegExp(r'Till:\s*(\d+)').firstMatch(method);
          if (tillMatch != null) {
            tillNumber = tillMatch.group(1);
          }
        }
      }

      if (paybillNumber == null && tillNumber == null) {
        throw Exception('Provider has not set up M-Pesa payment details');
      }

      // Create payment record
      final currentUserId = UserService.currentUser?.id ?? 'unknown';
      final paymentRef = await _firestore.collection('c2b_payments').add({
        'providerId': providerId,
        'providerName': providerName,
        'userId': currentUserId,
        'amount': amount,
        'description': description,
        'appointmentId': appointmentId,
        'paybillNumber': paybillNumber,
        'accountNumber': accountNumber,
        'tillNumber': tillNumber,
        'status': 'pending',
        'paymentMethod': tillNumber != null ? 'till' : 'paybill',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'paymentId': paymentRef.id,
        'paybillNumber': paybillNumber,
        'accountNumber': accountNumber,
        'tillNumber': tillNumber,
        'amount': amount,
        'providerName': providerName,
      };
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  /// Mark payment as completed (called after user confirms payment)
  static Future<void> confirmPayment({
    required String paymentId,
    required String mpesaCode,
  }) async {
    try {
      await _firestore.collection('c2b_payments').doc(paymentId).update({
        'status': 'completed',
        'mpesaCode': mpesaCode,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Get payment details
      final paymentDoc = await _firestore
          .collection('c2b_payments')
          .doc(paymentId)
          .get();
      final paymentData = paymentDoc.data()!;

      // Create transaction record for user
      await WalletService.createTransaction(
        type: TransactionType.payment,
        paymentMethod: PaymentMethod.mpesa,
        amount: paymentData['amount'],
        description: paymentData['description'],
        reference: mpesaCode,
        metadata: {
          'providerId': paymentData['providerId'],
          'providerName': paymentData['providerName'],
          'paymentId': paymentId,
        },
      );
    } catch (e) {
      throw Exception('Failed to confirm payment: $e');
    }
  }

  /// Cancel payment
  static Future<void> cancelPayment(String paymentId) async {
    try {
      await _firestore.collection('c2b_payments').doc(paymentId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel payment: $e');
    }
  }

  /// Get payment details
  static Future<Map<String, dynamic>?> getPaymentDetails(
    String paymentId,
  ) async {
    try {
      final doc = await _firestore
          .collection('c2b_payments')
          .doc(paymentId)
          .get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Get user's payment history
  static Stream<List<Map<String, dynamic>>> getUserPayments(String userId) {
    return _firestore
        .collection('c2b_payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }
}

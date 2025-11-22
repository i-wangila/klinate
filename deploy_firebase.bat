@echo off
echo ========================================
echo Firebase Cloud Functions Deployment
echo ========================================
echo.

echo Step 1: Installing dependencies...
cd functions
call npm install
cd ..

echo.
echo Step 2: Setting M-Pesa Sandbox configuration...
echo Using Safaricom Sandbox credentials for testing...
echo.

firebase functions:config:set mpesa.consumer_key="xpfmmNWGPuqEu7pKGKi0B13TlI8UlALkBR7xhHGujUXyDLMK"
firebase functions:config:set mpesa.consumer_secret="gVWzsbHVY6QWkNaQxL2NIn9EawvxjJqj4rLKYBlp5NSo6EwkDG5z690ZGGgAw8mxi"
firebase functions:config:set mpesa.business_short_code="174379"
firebase functions:config:set mpesa.passkey="bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
firebase functions:config:set mpesa.environment="sandbox"

echo.
echo Step 3: Deploying functions...
firebase deploy --only functions

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Test on Android device with Kenyan phone number
echo 2. Check Firebase Console for function logs
echo 3. Monitor M-Pesa transactions
echo.
pause

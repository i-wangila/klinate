import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// M-Pesa Service for handling mobile money transactions
/// Uses Firebase Cloud Functions for secure server-side processing
class MpesaService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Initiate STK Push for wallet top-up
  ///
  /// This will send an STK Push prompt to the user's phone
  /// User enters M-Pesa PIN to complete the transaction
  ///
  /// Returns a map with:
  /// - success: bool
  /// - message: String
  /// - checkoutRequestId: String (if successful)
  static Future<Map<String, dynamic>> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    String accountReference = 'Klinate',
  }) async {
    try {
      final result = await _functions.httpsCallable('initiateSTKPush').call({
        'phoneNumber': phoneNumber,
        'amount': amount,
        'accountReference': accountReference,
      });

      return {
        'success': true,
        'message': result.data['message'] ?? 'STK Push sent successfully',
        'checkoutRequestId': result.data['checkoutRequestId'],
        'merchantRequestId': result.data['merchantRequestId'],
      };
    } on FirebaseFunctionsException catch (e) {
      debugPrint('M-Pesa STK Push error: ${e.code} - ${e.message}');
      return {'success': false, 'message': _getErrorMessage(e)};
    } catch (e) {
      debugPrint('Error initiating STK Push: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  /// Query the status of an STK Push transaction
  ///
  /// Use this to check if user has completed the payment
  static Future<Map<String, dynamic>> querySTKPushStatus({
    required String checkoutRequestId,
  }) async {
    try {
      final result = await _functions.httpsCallable('querySTKPushStatus').call({
        'checkoutRequestId': checkoutRequestId,
      });

      final resultCode = result.data['resultCode'];

      return {
        'success': true,
        'resultCode': resultCode,
        'resultDesc': result.data['resultDesc'],
        'isCompleted': resultCode == 0,
        'isCancelled': resultCode == 1032, // User cancelled
        'isFailed': resultCode != 0 && resultCode != 1032,
      };
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Query error: ${e.code} - ${e.message}');
      return {'success': false, 'message': _getErrorMessage(e)};
    } catch (e) {
      debugPrint('Error querying status: $e');
      return {
        'success': false,
        'message': 'Failed to check transaction status',
      };
    }
  }

  /// Initiate withdrawal from wallet to M-Pesa (B2C)
  ///
  /// Money will be sent directly to the user's M-Pesa account
  static Future<Map<String, dynamic>> initiateWithdrawal({
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final result = await _functions.httpsCallable('initiateWithdrawal').call({
        'phoneNumber': phoneNumber,
        'amount': amount,
      });

      return {
        'success': true,
        'message':
            result.data['message'] ?? 'Withdrawal initiated successfully',
        'conversationId': result.data['conversationId'],
      };
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Withdrawal error: ${e.code} - ${e.message}');
      return {'success': false, 'message': _getErrorMessage(e)};
    } catch (e) {
      debugPrint('Error initiating withdrawal: $e');
      return {
        'success': false,
        'message': 'Failed to initiate withdrawal. Please try again.',
      };
    }
  }

  /// Validate Kenyan phone number
  static bool isValidKenyanPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Must be 9-12 digits
    if (cleaned.length < 9 || cleaned.length > 12) return false;

    // Check if it's a valid Kenyan number
    if (cleaned.startsWith('254')) {
      return cleaned.length == 12;
    } else if (cleaned.startsWith('0')) {
      return cleaned.length == 10;
    } else if (cleaned.startsWith('7') || cleaned.startsWith('1')) {
      return cleaned.length == 9;
    }

    return false;
  }

  /// Format phone number for display (e.g., 0712 345 678)
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Convert 254... to 0...
    if (cleaned.startsWith('254')) {
      cleaned = '0${cleaned.substring(3)}';
    }

    // Format as 0XXX XXX XXX
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    }

    return phone;
  }

  /// Get user-friendly error message
  static String _getErrorMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Please login to continue';
      case 'invalid-argument':
        return 'Invalid phone number or amount';
      case 'failed-precondition':
        return 'Insufficient balance';
      case 'unavailable':
        return 'M-Pesa service is currently unavailable';
      case 'deadline-exceeded':
        return 'Request timed out. Please try again';
      default:
        return e.message ?? 'An error occurred. Please try again';
    }
  }
}

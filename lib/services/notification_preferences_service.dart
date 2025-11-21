import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class NotificationPreferencesService {
  // General notification keys
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _smsNotificationsKey = 'sms_notifications';

  // Category-specific notification keys
  static const String _appointmentNotificationsKey =
      'appointment_notifications';
  static const String _messageNotificationsKey = 'message_notifications';
  static const String _promotionNotificationsKey = 'promotion_notifications';
  static const String _reminderNotificationsKey = 'reminder_notifications';

  // Get push notifications preference
  static Future<bool> getPushNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushNotificationsKey) ?? true;
  }

  // Set push notifications preference
  static Future<void> setPushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, value);
    if (kDebugMode) {
      print('Push notifications set to: $value');
    }
  }

  // Get email notifications preference
  static Future<bool> getEmailNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_emailNotificationsKey) ?? true;
  }

  // Set email notifications preference
  static Future<void> setEmailNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailNotificationsKey, value);
    if (kDebugMode) {
      print('Email notifications set to: $value');
    }
  }

  // Get SMS notifications preference
  static Future<bool> getSmsNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_smsNotificationsKey) ?? false;
  }

  // Set SMS notifications preference
  static Future<void> setSmsNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smsNotificationsKey, value);
    if (kDebugMode) {
      print('SMS notifications set to: $value');
    }
  }

  // Get appointment notifications preference
  static Future<bool> getAppointmentNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appointmentNotificationsKey) ?? true;
  }

  // Set appointment notifications preference
  static Future<void> setAppointmentNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appointmentNotificationsKey, value);
    if (kDebugMode) {
      print('Appointment notifications set to: $value');
    }
  }

  // Get message notifications preference
  static Future<bool> getMessageNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_messageNotificationsKey) ?? true;
  }

  // Set message notifications preference
  static Future<void> setMessageNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_messageNotificationsKey, value);
    if (kDebugMode) {
      print('Message notifications set to: $value');
    }
  }

  // Get promotion notifications preference
  static Future<bool> getPromotionNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_promotionNotificationsKey) ?? true;
  }

  // Set promotion notifications preference
  static Future<void> setPromotionNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promotionNotificationsKey, value);
    if (kDebugMode) {
      print('Promotion notifications set to: $value');
    }
  }

  // Get reminder notifications preference
  static Future<bool> getReminderNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderNotificationsKey) ?? true;
  }

  // Set reminder notifications preference
  static Future<void> setReminderNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderNotificationsKey, value);
    if (kDebugMode) {
      print('Reminder notifications set to: $value');
    }
  }

  // Get all notification preferences
  static Future<Map<String, bool>> getAllPreferences() async {
    return {
      'push': await getPushNotifications(),
      'email': await getEmailNotifications(),
      'sms': await getSmsNotifications(),
      'appointment': await getAppointmentNotifications(),
      'message': await getMessageNotifications(),
      'promotion': await getPromotionNotifications(),
      'reminder': await getReminderNotifications(),
    };
  }

  // Reset all preferences to default
  static Future<void> resetToDefaults() async {
    await setPushNotifications(true);
    await setEmailNotifications(true);
    await setSmsNotifications(false);
    await setAppointmentNotifications(true);
    await setMessageNotifications(true);
    await setPromotionNotifications(true);
    await setReminderNotifications(true);
    if (kDebugMode) {
      print('All notification preferences reset to defaults');
    }
  }

  // Check if any notification type is enabled
  static Future<bool> isAnyNotificationEnabled() async {
    final prefs = await getAllPreferences();
    return prefs.values.any((enabled) => enabled);
  }
}

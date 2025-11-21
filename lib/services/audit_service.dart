import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_action.dart';
import '../models/user_profile.dart';
import 'user_service.dart';
import 'provider_service.dart';

class AuditService {
  static const String _storageKey = 'klinate_audit_log';
  static final List<AdminAction> _actions = [];
  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadActions();
    _isInitialized = true;
  }

  // Load actions from storage
  static Future<void> _loadActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = prefs.getString(_storageKey);

      if (actionsJson != null) {
        final List<dynamic> actionsList = json.decode(actionsJson);
        _actions.clear();
        _actions.addAll(
          actionsList.map((json) => AdminAction.fromJson(json)).toList(),
        );
      }

      if (kDebugMode) {
        print('Audit actions loaded from storage: ${_actions.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audit actions: $e');
      }
    }
  }

  // Save actions to storage
  static Future<void> _saveActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsList = _actions.map((action) => action.toJson()).toList();
      final actionsJson = json.encode(actionsList);
      await prefs.setString(_storageKey, actionsJson);

      if (kDebugMode) {
        print('Audit actions saved to storage. Total: ${_actions.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving audit actions: $e');
      }
    }
  }

  // Log action
  static Future<void> logAction(AdminAction action) async {
    try {
      _actions.add(action);
      await _saveActions();

      if (kDebugMode) {
        print(
          'Action logged: ${action.type.displayName} by ${action.adminName}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging action: $e');
      }
    }
  }

  // Log provider approval
  static Future<void> logProviderApproval(
    String adminId,
    String providerId,
  ) async {
    final admin = UserService.currentUser;
    final provider = ProviderService.getProviderById(providerId);

    if (admin == null || provider == null) return;

    final action = AdminAction(
      adminId: adminId,
      adminName: admin.name,
      type: AdminActionType.providerApproved,
      targetId: providerId,
      targetName: ProviderService.getProviderDisplayName(providerId),
      details: {
        'providerType': provider.providerType.displayName,
        'email': ProviderService.getProviderEmail(providerId),
      },
    );

    await logAction(action);
  }

  // Log provider rejection
  static Future<void> logProviderRejection(
    String adminId,
    String providerId,
    String reason,
  ) async {
    final admin = UserService.currentUser;
    final provider = ProviderService.getProviderById(providerId);

    if (admin == null || provider == null) return;

    final action = AdminAction(
      adminId: adminId,
      adminName: admin.name,
      type: AdminActionType.providerRejected,
      targetId: providerId,
      targetName: ProviderService.getProviderDisplayName(providerId),
      details: {
        'providerType': provider.providerType.displayName,
        'email': ProviderService.getProviderEmail(providerId),
        'reason': reason,
      },
    );

    await logAction(action);
  }

  // Log provider suspension
  static Future<void> logProviderSuspension(
    String adminId,
    String providerId,
    String reason,
  ) async {
    final admin = UserService.currentUser;
    final provider = ProviderService.getProviderById(providerId);

    if (admin == null || provider == null) return;

    final action = AdminAction(
      adminId: adminId,
      adminName: admin.name,
      type: AdminActionType.providerSuspended,
      targetId: providerId,
      targetName: ProviderService.getProviderDisplayName(providerId),
      details: {
        'providerType': provider.providerType.displayName,
        'email': ProviderService.getProviderEmail(providerId),
        'reason': reason,
      },
    );

    await logAction(action);
  }

  // Log provider reactivation
  static Future<void> logProviderReactivation(
    String adminId,
    String providerId,
  ) async {
    final admin = UserService.currentUser;
    final provider = ProviderService.getProviderById(providerId);

    if (admin == null || provider == null) return;

    final action = AdminAction(
      adminId: adminId,
      adminName: admin.name,
      type: AdminActionType.providerReactivated,
      targetId: providerId,
      targetName: ProviderService.getProviderDisplayName(providerId),
      details: {
        'providerType': provider.providerType.displayName,
        'email': ProviderService.getProviderEmail(providerId),
      },
    );

    await logAction(action);
  }

  // Log user suspension
  static Future<void> logUserSuspension(
    String adminId,
    String userId,
    String reason,
  ) async {
    final admin = UserService.currentUser;
    final users = UserService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw Exception('User not found'),
    );

    final action = AdminAction(
      adminId: adminId,
      adminName: admin?.name ?? 'Unknown Admin',
      type: AdminActionType.userSuspended,
      targetId: userId,
      targetName: user.name,
      details: {'email': user.email, 'reason': reason},
    );

    await logAction(action);
  }

  // Log user reactivation
  static Future<void> logUserReactivation(String adminId, String userId) async {
    final admin = UserService.currentUser;
    final users = UserService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw Exception('User not found'),
    );

    final action = AdminAction(
      adminId: adminId,
      adminName: admin?.name ?? 'Unknown Admin',
      type: AdminActionType.userReactivated,
      targetId: userId,
      targetName: user.name,
      details: {'email': user.email},
    );

    await logAction(action);
  }

  // Log document approval
  static Future<void> logDocumentApproval(
    String adminId,
    String documentId,
  ) async {
    final admin = UserService.currentUser;

    if (admin == null) return;

    final action = AdminAction(
      adminId: adminId,
      adminName: admin.name,
      type: AdminActionType.documentApproved,
      targetId: documentId,
      targetName: 'Document',
      details: {'documentId': documentId},
    );

    await logAction(action);
  }

  // Log document rejection
  static Future<void> logDocumentRejection(
    String adminId,
    String documentId,
    String reason,
  ) async {
    final admin = UserService.currentUser;

    if (admin == null) return;

    final action = AdminAction(
      adminId: adminId,
      adminName: admin.name,
      type: AdminActionType.documentRejected,
      targetId: documentId,
      targetName: 'Document',
      details: {'documentId': documentId, 'reason': reason},
    );

    await logAction(action);
  }

  // Log notification sent
  static Future<void> logNotificationSent(
    String adminId,
    String recipientType,
    int recipientCount,
  ) async {
    final admin = UserService.currentUser;

    if (admin == null) return;

    final action = AdminAction(
      adminId: adminId,
      adminName: admin.name,
      type: AdminActionType.notificationSent,
      targetId: 'notification',
      targetName: 'Notification',
      details: {
        'recipientType': recipientType,
        'recipientCount': recipientCount,
      },
    );

    await logAction(action);
  }

  // Log settings changed
  static Future<void> logSettingsChanged(
    String adminId,
    String settingName,
    dynamic oldValue,
    dynamic newValue,
  ) async {
    final admin = UserService.currentUser;

    if (admin == null) return;

    final action = AdminAction(
      adminId: adminId,
      adminName: admin.name,
      type: AdminActionType.settingsChanged,
      targetId: 'settings',
      targetName: settingName,
      details: {
        'settingName': settingName,
        'oldValue': oldValue.toString(),
        'newValue': newValue.toString(),
      },
    );

    await logAction(action);
  }

  // Get recent actions
  static List<AdminAction> getRecentActions({int limit = 50}) {
    final sorted = List<AdminAction>.from(_actions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  // Get actions by admin
  static List<AdminAction> getActionsByAdmin(String adminId) {
    return _actions.where((action) => action.adminId == adminId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get actions by type
  static List<AdminAction> getActionsByType(AdminActionType type) {
    return _actions.where((action) => action.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get actions in date range
  static List<AdminAction> getActionsInDateRange(DateTime start, DateTime end) {
    return _actions
        .where(
          (action) =>
              action.timestamp.isAfter(start) && action.timestamp.isBefore(end),
        )
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Export actions to CSV
  static Future<String> exportActionsToCSV(DateTime start, DateTime end) async {
    final actions = getActionsInDateRange(start, end);

    final csv = StringBuffer();
    csv.writeln('Timestamp,Admin,Action Type,Target,Details');

    for (final action in actions) {
      csv.writeln(
        '${action.timestamp.toIso8601String()},'
        '${action.adminName},'
        '${action.type.displayName},'
        '${action.targetName},'
        '"${action.details.toString()}"',
      );
    }

    return csv.toString();
  }

  // Get action statistics
  static Map<AdminActionType, int> getActionStatistics() {
    final stats = <AdminActionType, int>{};

    for (final action in _actions) {
      stats[action.type] = (stats[action.type] ?? 0) + 1;
    }

    return stats;
  }

  // Clear old actions (keep last 1000)
  static Future<void> cleanupOldActions() async {
    if (_actions.length > 1000) {
      _actions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _actions.removeRange(1000, _actions.length);
      await _saveActions();

      if (kDebugMode) {
        print('Cleaned up old audit actions. Remaining: ${_actions.length}');
      }
    }
  }
}

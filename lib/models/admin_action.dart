enum AdminActionType {
  providerApproved,
  providerRejected,
  providerSuspended,
  providerReactivated,
  userSuspended,
  userReactivated,
  documentApproved,
  documentRejected,
  notificationSent,
  settingsChanged,
  adminCreated,
  adminUpdated,
  adminDeleted,
}

extension AdminActionTypeExtension on AdminActionType {
  String get displayName {
    switch (this) {
      case AdminActionType.providerApproved:
        return 'Business Account Approved';
      case AdminActionType.providerRejected:
        return 'Business Account Rejected';
      case AdminActionType.providerSuspended:
        return 'Business Account Suspended';
      case AdminActionType.providerReactivated:
        return 'Business Account Reactivated';
      case AdminActionType.userSuspended:
        return 'User Suspended';
      case AdminActionType.userReactivated:
        return 'User Reactivated';
      case AdminActionType.documentApproved:
        return 'Document Approved';
      case AdminActionType.documentRejected:
        return 'Document Rejected';
      case AdminActionType.notificationSent:
        return 'Notification Sent';
      case AdminActionType.settingsChanged:
        return 'Settings Changed';
      case AdminActionType.adminCreated:
        return 'Admin Created';
      case AdminActionType.adminUpdated:
        return 'Admin Updated';
      case AdminActionType.adminDeleted:
        return 'Admin Deleted';
    }
  }

  String get icon {
    switch (this) {
      case AdminActionType.providerApproved:
        return '✅';
      case AdminActionType.providerRejected:
        return '❌';
      case AdminActionType.providerSuspended:
        return '🚫';
      case AdminActionType.providerReactivated:
        return '✅';
      case AdminActionType.userSuspended:
        return '🚫';
      case AdminActionType.userReactivated:
        return '✅';
      case AdminActionType.documentApproved:
        return '📄';
      case AdminActionType.documentRejected:
        return '📄';
      case AdminActionType.notificationSent:
        return '📧';
      case AdminActionType.settingsChanged:
        return '⚙️';
      case AdminActionType.adminCreated:
        return '👤';
      case AdminActionType.adminUpdated:
        return '👤';
      case AdminActionType.adminDeleted:
        return '👤';
    }
  }
}

class AdminAction {
  final String id;
  final String adminId;
  final String adminName;
  final AdminActionType type;
  final String targetId;
  final String targetName;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  AdminAction({
    String? id,
    required this.adminId,
    required this.adminName,
    required this.type,
    required this.targetId,
    required this.targetName,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) : id = id ?? 'action_${DateTime.now().millisecondsSinceEpoch}',
       details = details ?? {},
       timestamp = timestamp ?? DateTime.now();

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'adminName': adminName,
      'type': type.toString(),
      'targetId': targetId,
      'targetName': targetName,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AdminAction.fromJson(Map<String, dynamic> json) {
    return AdminAction(
      id: json['id'],
      adminId: json['adminId'],
      adminName: json['adminName'],
      type: AdminActionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AdminActionType.settingsChanged,
      ),
      targetId: json['targetId'],
      targetName: json['targetName'],
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

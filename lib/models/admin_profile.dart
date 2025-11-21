enum AdminLevel { superAdmin, admin, moderator }

extension AdminLevelExtension on AdminLevel {
  String get displayName {
    switch (this) {
      case AdminLevel.superAdmin:
        return 'Super Administrator';
      case AdminLevel.admin:
        return 'Administrator';
      case AdminLevel.moderator:
        return 'Moderator';
    }
  }

  String get description {
    switch (this) {
      case AdminLevel.superAdmin:
        return 'Full system access and control';
      case AdminLevel.admin:
        return 'Standard administrative access';
      case AdminLevel.moderator:
        return 'Limited administrative access';
    }
  }
}

enum AdminPermission {
  approveProviders,
  rejectProviders,
  suspendUsers,
  viewAllData,
  sendNotifications,
  manageAdmins,
  viewReports,
  configureSystem,
}

extension AdminPermissionExtension on AdminPermission {
  String get displayName {
    switch (this) {
      case AdminPermission.approveProviders:
        return 'Approve Providers';
      case AdminPermission.rejectProviders:
        return 'Reject Providers';
      case AdminPermission.suspendUsers:
        return 'Suspend Users';
      case AdminPermission.viewAllData:
        return 'View All Data';
      case AdminPermission.sendNotifications:
        return 'Send Notifications';
      case AdminPermission.manageAdmins:
        return 'Manage Admins';
      case AdminPermission.viewReports:
        return 'View Reports';
      case AdminPermission.configureSystem:
        return 'Configure System';
    }
  }
}

class AdminProfile {
  final String id;
  final String userId;
  AdminLevel level;
  List<AdminPermission> permissions;
  final DateTime createdAt;
  DateTime lastActiveAt;
  final String createdBy;

  AdminProfile({
    String? id,
    required this.userId,
    this.level = AdminLevel.admin,
    List<AdminPermission>? permissions,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    this.createdBy = 'system',
  }) : id = id ?? 'admin_${DateTime.now().millisecondsSinceEpoch}',
       permissions = permissions ?? _getDefaultPermissions(level),
       createdAt = createdAt ?? DateTime.now(),
       lastActiveAt = lastActiveAt ?? DateTime.now();

  static List<AdminPermission> _getDefaultPermissions(AdminLevel level) {
    switch (level) {
      case AdminLevel.superAdmin:
        return AdminPermission.values;
      case AdminLevel.admin:
        return [
          AdminPermission.approveProviders,
          AdminPermission.rejectProviders,
          AdminPermission.suspendUsers,
          AdminPermission.viewAllData,
          AdminPermission.sendNotifications,
          AdminPermission.viewReports,
        ];
      case AdminLevel.moderator:
        return [
          AdminPermission.approveProviders,
          AdminPermission.viewAllData,
          AdminPermission.viewReports,
        ];
    }
  }

  bool hasPermission(AdminPermission permission) {
    return permissions.contains(permission);
  }

  bool get isSuperAdmin => level == AdminLevel.superAdmin;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'level': level.toString(),
      'permissions': permissions.map((p) => p.toString()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'],
      userId: json['userId'],
      level: AdminLevel.values.firstWhere(
        (e) => e.toString() == json['level'],
        orElse: () => AdminLevel.admin,
      ),
      permissions:
          (json['permissions'] as List?)
              ?.map(
                (p) => AdminPermission.values.firstWhere(
                  (e) => e.toString() == p,
                  orElse: () => AdminPermission.viewAllData,
                ),
              )
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastActiveAt: DateTime.parse(
        json['lastActiveAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: json['createdBy'] ?? 'system',
    );
  }

  AdminProfile copyWith({
    String? id,
    String? userId,
    AdminLevel? level,
    List<AdminPermission>? permissions,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? createdBy,
  }) {
    return AdminProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      level: level ?? this.level,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

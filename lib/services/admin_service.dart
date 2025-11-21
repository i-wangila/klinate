import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_profile.dart';
import '../models/user_profile.dart';
import '../models/provider_profile.dart';
import '../models/system_stats.dart';
import 'user_service.dart';
import 'provider_service.dart';

class AdminService {
  static const String _storageKey = 'klinate_admins';
  static final Map<String, AdminProfile> _admins = {};
  static bool _isInitialized = false;
  static SystemStats? _cachedStats;
  static DateTime? _lastStatsUpdate;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadAdmins();
    _isInitialized = true;
  }

  // Load admins from storage
  static Future<void> _loadAdmins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminsJson = prefs.getString(_storageKey);

      if (adminsJson != null && adminsJson.isNotEmpty) {
        final Map<String, dynamic> adminsMap = json.decode(adminsJson);
        _admins.clear();
        adminsMap.forEach((key, value) {
          _admins[key] = AdminProfile.fromJson(value);
        });
      }

      if (kDebugMode) {
        print('Admins loaded from storage: ${_admins.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading admins: $e');
      }
    }
  }

  // Save admins to storage
  static Future<void> _saveAdmins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminsMap = _admins.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      final adminsJson = json.encode(adminsMap);
      await prefs.setString(_storageKey, adminsJson);

      if (kDebugMode) {
        print('Admins saved to storage. Total admins: ${_admins.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving admins: $e');
      }
    }
  }

  // Create admin account
  static Future<AdminProfile?> createAdmin({
    required String userId,
    AdminLevel level = AdminLevel.admin,
    List<AdminPermission>? permissions,
    String createdBy = 'system',
  }) async {
    try {
      // Check if admin already exists for this user
      if (_admins.containsKey(userId)) {
        if (kDebugMode) {
          print('Admin already exists for user: $userId');
        }
        return null;
      }

      final admin = AdminProfile(
        userId: userId,
        level: level,
        permissions: permissions,
        createdBy: createdBy,
      );

      _admins[userId] = admin;
      await _saveAdmins();

      // Add admin role to user
      await UserService.addRole(UserRole.admin);

      if (kDebugMode) {
        print('Admin created successfully: ${admin.id}');
      }

      return admin;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating admin: $e');
      }
      return null;
    }
  }

  // Update admin
  static Future<bool> updateAdmin(AdminProfile admin) async {
    try {
      if (!_admins.containsKey(admin.userId)) {
        if (kDebugMode) {
          print('Admin not found: ${admin.userId}');
        }
        return false;
      }

      _admins[admin.userId] = admin;
      await _saveAdmins();

      if (kDebugMode) {
        print('Admin updated successfully: ${admin.id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating admin: $e');
      }
      return false;
    }
  }

  // Delete admin
  static Future<bool> deleteAdmin(String userId) async {
    try {
      if (!_admins.containsKey(userId)) {
        if (kDebugMode) {
          print('Admin not found: $userId');
        }
        return false;
      }

      _admins.remove(userId);
      await _saveAdmins();

      // Remove admin role from user
      await UserService.removeRole(UserRole.admin);

      if (kDebugMode) {
        print('Admin deleted successfully: $userId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting admin: $e');
      }
      return false;
    }
  }

  // Get admin by user ID
  static AdminProfile? getAdminByUserId(String userId) {
    return _admins[userId];
  }

  // Get all admins
  static List<AdminProfile> getAllAdmins() {
    return _admins.values.toList();
  }

  // Check if any admin exists in the system
  static bool hasAdmin() {
    return _admins.isNotEmpty;
  }

  // Check if user is admin
  static bool isAdmin(String userId) {
    return _admins.containsKey(userId);
  }

  // Check if current user is admin
  static bool get isCurrentUserAdmin {
    final user = UserService.currentUser;
    return user != null && isAdmin(user.id);
  }

  // Get current admin profile
  static AdminProfile? get currentAdminProfile {
    final user = UserService.currentUser;
    if (user == null) return null;
    return getAdminByUserId(user.id);
  }

  // Check permission
  static bool hasPermission(String userId, AdminPermission permission) {
    final admin = getAdminByUserId(userId);
    if (admin == null) return false;
    return admin.hasPermission(permission);
  }

  // Check if current user has permission
  static bool currentUserHasPermission(AdminPermission permission) {
    final user = UserService.currentUser;
    if (user == null) return false;
    return hasPermission(user.id, permission);
  }

  // Grant permission
  static Future<bool> grantPermission(
    String userId,
    AdminPermission permission,
  ) async {
    try {
      final admin = getAdminByUserId(userId);
      if (admin == null) return false;

      if (admin.hasPermission(permission)) {
        if (kDebugMode) {
          print('Admin already has permission: $permission');
        }
        return false;
      }

      final updatedPermissions = List<AdminPermission>.from(admin.permissions)
        ..add(permission);
      final updatedAdmin = admin.copyWith(permissions: updatedPermissions);

      return await updateAdmin(updatedAdmin);
    } catch (e) {
      if (kDebugMode) {
        print('Error granting permission: $e');
      }
      return false;
    }
  }

  // Revoke permission
  static Future<bool> revokePermission(
    String userId,
    AdminPermission permission,
  ) async {
    try {
      final admin = getAdminByUserId(userId);
      if (admin == null) return false;

      if (!admin.hasPermission(permission)) {
        if (kDebugMode) {
          print('Admin does not have permission: $permission');
        }
        return false;
      }

      final updatedPermissions = List<AdminPermission>.from(admin.permissions)
        ..remove(permission);
      final updatedAdmin = admin.copyWith(permissions: updatedPermissions);

      return await updateAdmin(updatedAdmin);
    } catch (e) {
      if (kDebugMode) {
        print('Error revoking permission: $e');
      }
      return false;
    }
  }

  // Get system statistics
  static SystemStats getSystemStats() {
    // Return cached stats if recent (less than 5 minutes old)
    if (_cachedStats != null &&
        _lastStatsUpdate != null &&
        DateTime.now().difference(_lastStatsUpdate!).inMinutes < 5) {
      return _cachedStats!;
    }

    // Calculate fresh stats
    final users = UserService.getAllUsers();
    final providers = ProviderService.getAllProviders();

    final totalUsers = users.length;
    final totalPatients = users
        .where((u) => u.hasRole(UserRole.patient))
        .length;
    final totalProviders = providers.length;
    final activeProviders = providers
        .where((p) => p.status == ProviderStatus.approved)
        .length;
    final pendingProviders = providers
        .where((p) => p.status == ProviderStatus.pending)
        .length;
    final rejectedProviders = providers
        .where((p) => p.status == ProviderStatus.rejected)
        .length;
    final suspendedProviders = providers
        .where((p) => p.status == ProviderStatus.suspended)
        .length;

    // Count providers by type
    final providersByType = <String, int>{};
    for (final provider in providers) {
      final type = provider.providerType.displayName;
      providersByType[type] = (providersByType[type] ?? 0) + 1;
    }

    _cachedStats = SystemStats(
      totalUsers: totalUsers,
      totalPatients: totalPatients,
      totalProviders: totalProviders,
      activeProviders: activeProviders,
      pendingProviders: pendingProviders,
      rejectedProviders: rejectedProviders,
      suspendedProviders: suspendedProviders,
      totalAppointments: 0, // Placeholder - would come from appointment service
      todayAppointments: 0, // Placeholder
      totalReviews: 0, // Placeholder - would come from review service
      providersByType: providersByType,
      appointmentsByStatus: {}, // Placeholder
      dailyStats: [], // Placeholder
    );

    _lastStatsUpdate = DateTime.now();
    return _cachedStats!;
  }

  // Refresh statistics
  static Future<void> refreshStats() async {
    _cachedStats = null;
    _lastStatsUpdate = null;
    getSystemStats();
  }

  // Update last active timestamp
  static Future<void> updateLastActive(String userId) async {
    final admin = getAdminByUserId(userId);
    if (admin == null) return;

    final updatedAdmin = admin.copyWith(lastActiveAt: DateTime.now());
    await updateAdmin(updatedAdmin);
  }

  // Create initial super admin (for setup)
  static Future<AdminProfile?> createInitialSuperAdmin(String userId) async {
    // Only allow if no admins exist
    if (_admins.isNotEmpty) {
      if (kDebugMode) {
        print('Cannot create initial super admin - admins already exist');
      }
      return null;
    }

    return await createAdmin(
      userId: userId,
      level: AdminLevel.superAdmin,
      createdBy: 'system',
    );
  }

  // Deactivate admin account (remove from active admins)
  static Future<bool> deactivateAdmin(String adminId) async {
    try {
      final admin = _admins[adminId];
      if (admin == null) return false;

      // Simply remove from active admins map
      _admins.remove(adminId);
      await _saveAdmins();

      if (kDebugMode) {
        print('Admin deactivated: $adminId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deactivating admin: $e');
      }
      return false;
    }
  }

  // Reactivate admin account
  static Future<bool> reactivateAdmin(String adminId, String userId) async {
    try {
      // Recreate admin profile
      return await createAdmin(
            userId: userId,
            level: AdminLevel.admin,
            createdBy: 'reactivation',
          ) !=
          null;
    } catch (e) {
      if (kDebugMode) {
        print('Error reactivating admin: $e');
      }
      return false;
    }
  }

  // Remove admin profile completely (when removing admin role)
  static Future<bool> removeAdminProfile(String adminId) async {
    try {
      _admins.remove(adminId);
      await _saveAdmins();

      if (kDebugMode) {
        print('Admin profile removed: $adminId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing admin profile: $e');
      }
      return false;
    }
  }
}

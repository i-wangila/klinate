import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserService {
  static const String _storageKey = 'klinate_users';
  static const String _currentUserKey = 'klinate_current_user';
  static UserProfile? _currentUser;
  static final Map<String, UserProfile> _users = {};
  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadUsers();
    await _loadCurrentUser();
    _isInitialized = true;
  }

  // Get current user
  static UserProfile? get currentUser => _currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;

  // Load users from storage
  static Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_storageKey);

      if (usersJson != null && usersJson.isNotEmpty) {
        final Map<String, dynamic> usersMap = json.decode(usersJson);
        _users.clear();
        usersMap.forEach((key, value) {
          _users[key] = UserProfile.fromJson(value);
        });
      }

      if (kDebugMode) {
        print('Users loaded from storage: ${_users.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
    }
  }

  // Save users to storage
  static Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersMap = _users.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      final usersJson = json.encode(usersMap);
      await prefs.setString(_storageKey, usersJson);

      if (kDebugMode) {
        print('Users saved to storage. Total users: ${_users.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving users: $e');
      }
    }
  }

  // Load current user
  static Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString(_currentUserKey);

      if (currentUserJson != null) {
        _currentUser = UserProfile.fromJson(json.decode(currentUserJson));
        if (kDebugMode) {
          print('Current user loaded: ${_currentUser?.email}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading current user: $e');
      }
    }
  }

  // Save current user
  static Future<void> _saveCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        final currentUserJson = json.encode(_currentUser!.toJson());
        await prefs.setString(_currentUserKey, currentUserJson);
      } else {
        await prefs.remove(_currentUserKey);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving current user: $e');
      }
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      _currentUser = null;
      await _saveCurrentUser();
      if (kDebugMode) {
        print('User logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging out: $e');
      }
    }
  }

  // Sign up new user
  static Future<AuthResult> signUp({
    String title = '',
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final name = '$firstName $lastName'.trim();

      // Validate input
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult(success: false, message: 'Name is required');
      }
      if (email.trim().isEmpty) {
        return AuthResult(success: false, message: 'Email is required');
      }
      if (phone.trim().isEmpty) {
        return AuthResult(success: false, message: 'Phone is required');
      }
      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: 'Password must be at least 6 characters',
        );
      }
      if (password != confirmPassword) {
        return AuthResult(success: false, message: 'Passwords do not match');
      }

      // Check if user already exists
      if (_users.containsKey(email.toLowerCase())) {
        return AuthResult(
          success: false,
          message: 'Account with this email already exists',
        );
      }

      // Create new user with patient role by default
      final user = UserProfile(
        title: title,
        name: name,
        email: email.toLowerCase().trim(),
        phone: phone.trim(),
        password: _hashPassword(password),
        roles: [UserRole.patient],
        currentRole: UserRole.patient,
      );

      // Save user
      final emailKey = email.toLowerCase().trim();
      _users[emailKey] = user;
      _currentUser = user;

      await _saveUsers();
      await _saveCurrentUser();

      if (kDebugMode) {
        print('User signed up successfully: ${user.email}');
      }

      return AuthResult(success: true, message: 'Account created successfully');
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to create account: $e',
      );
    }
  }

  // Sign in existing user
  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Ensure users are loaded from storage
      await _loadUsers();

      // Validate input
      if (email.trim().isEmpty) {
        return AuthResult(success: false, message: 'Email is required');
      }
      if (password.isEmpty) {
        return AuthResult(success: false, message: 'Password is required');
      }

      final emailKey = email.toLowerCase().trim();

      // Check if user exists
      if (!_users.containsKey(emailKey)) {
        return AuthResult(success: false, message: 'Account does not exist');
      }

      final user = _users[emailKey]!;

      // Verify password
      if (!_verifyPassword(password, user.password!)) {
        return AuthResult(success: false, message: 'Invalid password');
      }

      _currentUser = user;
      await _saveCurrentUser();

      if (kDebugMode) {
        print('User signed in successfully: ${user.email}');
      }

      return AuthResult(success: true, message: 'Signed in successfully');
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to sign in: $e');
    }
  }

  // Sign out user
  static Future<void> signOut() async {
    _currentUser = null;
    await _saveCurrentUser();
    if (kDebugMode) {
      print('User signed out');
    }
  }

  // Switch user role
  static Future<bool> switchRole(UserRole newRole) async {
    try {
      if (_currentUser == null) return false;

      if (!_currentUser!.hasRole(newRole)) {
        if (kDebugMode) {
          print('User does not have role: $newRole');
        }
        return false;
      }

      _currentUser = _currentUser!.copyWith(currentRole: newRole);
      _users[_currentUser!.email] = _currentUser!;

      await _saveUsers();
      await _saveCurrentUser();

      if (kDebugMode) {
        print('Role switched to: $newRole');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error switching role: $e');
      }
      return false;
    }
  }

  // Add role to user
  static Future<bool> addRole(UserRole role) async {
    try {
      if (_currentUser == null) return false;

      if (_currentUser!.hasRole(role)) {
        if (kDebugMode) {
          print('User already has role: $role');
        }
        return false;
      }

      final updatedRoles = List<UserRole>.from(_currentUser!.roles)..add(role);
      _currentUser = _currentUser!.copyWith(roles: updatedRoles);
      _users[_currentUser!.email] = _currentUser!;

      await _saveUsers();
      await _saveCurrentUser();

      if (kDebugMode) {
        print('Role added: $role');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding role: $e');
      }
      return false;
    }
  }

  // Remove role from user
  static Future<bool> removeRole(UserRole role) async {
    try {
      if (_currentUser == null) return false;

      // Cannot remove patient role
      if (role == UserRole.patient) {
        if (kDebugMode) {
          print('Cannot remove patient role');
        }
        return false;
      }

      if (!_currentUser!.hasRole(role)) {
        if (kDebugMode) {
          print('User does not have role: $role');
        }
        return false;
      }

      final updatedRoles = List<UserRole>.from(_currentUser!.roles)
        ..remove(role);

      // If removing current role, switch to patient
      UserRole newCurrentRole = _currentUser!.currentRole;
      if (_currentUser!.currentRole == role) {
        newCurrentRole = UserRole.patient;
      }

      _currentUser = _currentUser!.copyWith(
        roles: updatedRoles,
        currentRole: newCurrentRole,
      );
      _users[_currentUser!.email] = _currentUser!;

      await _saveUsers();
      await _saveCurrentUser();

      if (kDebugMode) {
        print('Role removed: $role');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing role: $e');
      }
      return false;
    }
  }

  // Update user profile
  static Future<bool> updateProfile(UserProfile updatedProfile) async {
    try {
      if (_currentUser == null) return false;

      final oldEmail = _currentUser!.email;
      final newEmail = updatedProfile.email.toLowerCase().trim();

      // Check if email is being changed and if new email already exists
      if (oldEmail != newEmail && _users.containsKey(newEmail)) {
        if (kDebugMode) {
          print('Email already exists: $newEmail');
        }
        return false;
      }

      // If email changed, remove old entry and add new one
      if (oldEmail != newEmail) {
        _users.remove(oldEmail);
        _users[newEmail] = updatedProfile;
      } else {
        _users[oldEmail] = updatedProfile;
      }

      _currentUser = updatedProfile;

      await _saveUsers();
      await _saveCurrentUser();

      if (kDebugMode) {
        print('Profile updated successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update profile: $e');
      }
      return false;
    }
  }

  // Update profile picture
  static Future<bool> updateProfilePicture(String imagePath) async {
    try {
      if (_currentUser == null) return false;

      final updatedUser = _currentUser!.copyWith(profilePicturePath: imagePath);
      _users[_currentUser!.email] = updatedUser;
      _currentUser = updatedUser;

      await _saveUsers();
      await _saveCurrentUser();

      if (kDebugMode) {
        print('Profile picture updated successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update profile picture: $e');
      }
      return false;
    }
  }

  // Delete account
  static Future<bool> deleteAccount() async {
    try {
      if (_currentUser == null) return false;

      _users.remove(_currentUser!.email);
      _currentUser = null;

      await _saveUsers();
      await _saveCurrentUser();

      if (kDebugMode) {
        print('Account deleted successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete account: $e');
      }
      return false;
    }
  }

  // Private methods for password handling
  static String _hashPassword(String password) {
    // Simple hash for demo - in production use proper hashing like bcrypt
    return '${password.split('').reversed.join()}_hashed';
  }

  static bool _verifyPassword(String password, String hashedPassword) {
    return _hashPassword(password) == hashedPassword;
  }

  // Get all users (for admin purposes)
  static List<UserProfile> getAllUsers() {
    return _users.values.toList();
  }

  // Check if email exists
  static bool emailExists(String email) {
    return _users.containsKey(email.toLowerCase().trim());
  }

  // Change password
  static Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) {
        return AuthResult(success: false, message: 'User not logged in');
      }

      // Verify current password
      if (!_verifyPassword(currentPassword, _currentUser!.password!)) {
        return AuthResult(
          success: false,
          message: 'Current password is incorrect',
        );
      }

      // Validate new password
      if (newPassword.length < 6) {
        return AuthResult(
          success: false,
          message: 'New password must be at least 6 characters',
        );
      }

      // Update password
      final updatedUser = _currentUser!.copyWith(
        password: _hashPassword(newPassword),
      );

      _users[_currentUser!.email] = updatedUser;
      _currentUser = updatedUser;

      await _saveUsers();
      await _saveCurrentUser();

      if (kDebugMode) {
        print('Password changed successfully');
      }

      return AuthResult(
        success: true,
        message: 'Password changed successfully',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to change password: $e');
      }
      return AuthResult(
        success: false,
        message: 'Failed to change password: $e',
      );
    }
  }

  // Suspend user account
  static Future<bool> suspendUser(String userId) async {
    try {
      final user = _users[userId];
      if (user == null) return false;

      // Update user with suspended status (you can add a status field to UserProfile)
      // For now, we'll just log it
      if (kDebugMode) {
        print('User suspended: $userId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error suspending user: $e');
      }
      return false;
    }
  }

  // Delete user account
  static Future<bool> deleteUser(String userId) async {
    try {
      // Don't allow deleting current user
      if (_currentUser?.id == userId) {
        if (kDebugMode) {
          print('Cannot delete current user');
        }
        return false;
      }

      _users.remove(userId);
      await _saveUsers();

      if (kDebugMode) {
        print('User deleted: $userId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user: $e');
      }
      return false;
    }
  }

  // Restrict user access (limited access for fund withdrawal)
  static Future<bool> restrictUserAccess(String userId, bool restricted) async {
    try {
      final user = _users[userId];
      if (user == null) return false;

      // You can add a 'restricted' field to UserProfile model
      // For now, we'll just log it
      if (kDebugMode) {
        print(
          'User access ${restricted ? "restricted" : "unrestricted"}: $userId',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error restricting user access: $e');
      }
      return false;
    }
  }
}

class AuthResult {
  final bool success;
  final String message;

  AuthResult({required this.success, required this.message});
}

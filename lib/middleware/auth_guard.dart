import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

class AuthGuard {
  /// Check if user is authenticated
  static bool isAuthenticated() {
    return UserService.currentUser != null;
  }

  /// Check if current user is admin
  static bool isAdmin() {
    final user = UserService.currentUser;
    if (user == null) return false;
    return user.hasRole(UserRole.admin);
  }

  /// Check if current user is provider
  static bool isProvider() {
    final user = UserService.currentUser;
    if (user == null) return false;
    return user.currentRole.isProvider;
  }

  /// Redirect to login if not authenticated
  static void requireAuth(BuildContext context) {
    if (!isAuthenticated()) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  /// Redirect to home if not admin
  static void requireAdmin(BuildContext context) {
    if (!isAuthenticated()) {
      Navigator.pushReplacementNamed(context, '/auth');
      return;
    }

    if (!isAdmin()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⛔ Admin access required'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// Redirect to home if not provider
  static void requireProvider(BuildContext context) {
    if (!isAuthenticated()) {
      Navigator.pushReplacementNamed(context, '/auth');
      return;
    }

    if (!isProvider()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⛔ Provider access required'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}

import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  bool _isLoading = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    await AdminService.initialize();
    final user = UserService.currentUser;
    if (user != null) {
      setState(() {
        _isAdmin = user.hasRole(UserRole.admin);
      });
    }
  }

  Future<void> _makeAdmin() async {
    setState(() => _isLoading = true);

    try {
      final user = UserService.currentUser;
      if (user == null) {
        _showError('Please sign in first');
        return;
      }

      // Create super admin profile
      final adminProfile = await AdminService.createInitialSuperAdmin(user.id);

      if (adminProfile != null) {
        // Switch to admin role
        await UserService.switchRole(UserRole.admin);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ You are now a Super Administrator!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to admin dashboard
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        }
      } else {
        _showError('Failed to create admin account. Admins may already exist.');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Setup'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isAdmin ? Icons.admin_panel_settings : Icons.security,
                size: 100,
                color: _isAdmin ? Colors.green : Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                _isAdmin ? 'You are an Admin!' : 'Become an Administrator',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_isAdmin)
                Text(
                  'You have administrator privileges.\nYou can manage providers, users, and system settings.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'Grant yourself administrator privileges to manage the platform.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              if (user == null)
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In First',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              else if (_isAdmin)
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/dashboard',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go to Admin Dashboard',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _isLoading ? null : _makeAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Make Me Admin',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              const SizedBox(height: 16),
              if (user != null && !_isAdmin)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

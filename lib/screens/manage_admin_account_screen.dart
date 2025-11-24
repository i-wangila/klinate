import 'package:flutter/material.dart';
import '../models/admin_profile.dart';
import '../models/user_profile.dart';
import '../services/admin_service.dart';
import '../services/user_service.dart';

class ManageAdminAccountScreen extends StatefulWidget {
  const ManageAdminAccountScreen({super.key});

  @override
  State<ManageAdminAccountScreen> createState() =>
      _ManageAdminAccountScreenState();
}

class _ManageAdminAccountScreenState extends State<ManageAdminAccountScreen> {
  AdminProfile? _adminProfile;
  UserProfile? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  Future<void> _loadAdminProfile() async {
    setState(() => _isLoading = true);

    _user = UserService.currentUser;
    if (_user != null) {
      _adminProfile = AdminService.getAdminByUserId(_user!.id);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Admin Account Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountOverview(),
                  const SizedBox(height: 16),
                  _buildAdminInformation(),
                  const SizedBox(height: 16),
                  _buildRoleAndPermissions(),
                  const SizedBox(height: 16),
                  _buildActivitySummary(),
                  const SizedBox(height: 16),
                  _buildDangerZone(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.purple[700],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Platform Administrator',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.name ?? 'Admin',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Level',
                _getAdminLevelNumber(_adminProfile?.level),
              ),
              _buildStatItem(
                'Permissions',
                _adminProfile?.permissions.length.toString() ?? '0',
              ),
              _buildStatItem('Since', _formatDate(_adminProfile?.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAdminInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Admin Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _editAdminInformation,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', _user?.name ?? 'N/A'),
          _buildInfoRow('Email', _user?.email ?? 'N/A'),
          _buildInfoRow('Phone', _user?.phone ?? 'N/A'),
          _buildInfoRow('Admin ID', _adminProfile?.id ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildRoleAndPermissions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Role & Permissions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Role', 'Platform Administrator'),
          _buildInfoRow(
            'Level',
            _adminProfile?.level.displayName ?? 'Administrator',
          ),
          _buildInfoRow('Seniority', _getSeniorityLevel(_adminProfile?.level)),
          const SizedBox(height: 16),
          const Text(
            'Permissions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildPermissionChip('Approve Providers', true),
          _buildPermissionChip('Manage Users', true),
          _buildPermissionChip('View Reports', true),
          _buildPermissionChip('System Settings', true),
          _buildPermissionChip('Audit Logs', true),
        ],
      ),
    );
  }

  Widget _buildActivitySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Permissions',
            '${_adminProfile?.permissions.length ?? 0} granted',
          ),
          _buildInfoRow(
            'Last Active',
            _formatDateTime(_adminProfile?.lastActiveAt),
          ),
          _buildInfoRow(
            'Account Created',
            _formatDateTime(_adminProfile?.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'These actions will affect your admin privileges and access.',
            style: TextStyle(fontSize: 14, color: Colors.red[800]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deactivateAdminAccount,
              icon: const Icon(Icons.pause_circle_outline),
              label: const Text('Deactivate Admin Account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange[700],
                side: BorderSide(color: Colors.orange[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _removeAdminRole,
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('Remove Admin Role'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(String label, bool granted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
        ],
      ),
    );
  }

  String _getAdminLevelNumber(AdminLevel? level) {
    if (level == null) return '1';
    switch (level) {
      case AdminLevel.superAdmin:
        return '3';
      case AdminLevel.admin:
        return '2';
      case AdminLevel.moderator:
        return '1';
    }
  }

  String _getSeniorityLevel(AdminLevel? level) {
    if (level == null) return 'New Administrator';
    switch (level) {
      case AdminLevel.superAdmin:
        return 'Super Administrator';
      case AdminLevel.admin:
        return 'Standard Administrator';
      case AdminLevel.moderator:
        return 'Moderator';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editAdminInformation() {
    final nameController = TextEditingController(text: _user?.name ?? '');
    final emailController = TextEditingController(text: _user?.email ?? '');
    final phoneController = TextEditingController(text: _user?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Admin Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update user profile
              if (_user != null) {
                final updatedUser = _user!.copyWith(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                );

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                final success = await UserService.updateProfile(updatedUser);

                if (!mounted) return;

                if (success) {
                  setState(() {
                    _user = updatedUser;
                  });

                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Admin information updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update information'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deactivateAdminAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pause_circle_outline, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Deactivate Admin Account'),
          ],
        ),
        content: const Text(
          'Your admin account will be temporarily deactivated. You can reactivate it later.\n\n'
          'During deactivation:\n'
          '• You will lose admin privileges\n'
          '• You cannot approve applications\n'
          '• You cannot manage users\n'
          '• Your general account remains active',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeactivation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _removeAdminRole() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.remove_circle_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Remove Admin Role'),
          ],
        ),
        content: const Text(
          'This will permanently remove your admin role!\n\n'
          'You will:\n'
          '• Lose all admin privileges\n'
          '• No longer access admin dashboard\n'
          '• Cannot approve applications\n'
          '• Cannot manage users or system\n\n'
          'Your general user account will remain active.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmRemoveAdminRole();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text('Remove Role'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveAdminRole() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'This action is permanent. Type "REMOVE" to confirm removal of admin role.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRoleRemoval();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text('Confirm Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeactivation() async {
    try {
      if (_adminProfile != null) {
        await AdminService.deactivateAdmin(_adminProfile!.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin account deactivated successfully'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _performRoleRemoval() async {
    try {
      // Remove admin role from user
      await UserService.removeRole(UserRole.admin);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin role removed successfully'),
          backgroundColor: Colors.red,
        ),
      );
      // Navigate back to settings
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

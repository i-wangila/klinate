import 'package:flutter/material.dart';
import '../models/admin_profile.dart';
import '../models/user_profile.dart';
import '../services/admin_service.dart';
import '../services/user_service.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<AdminProfile> _admins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() => _isLoading = true);

    await AdminService.initialize();
    _admins = AdminService.getAllAdmins();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAdminDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _admins.isEmpty
          ? _buildEmptyState()
          : _buildAdminList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No admins found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _admins.length,
      itemBuilder: (context, index) {
        final admin = _admins[index];
        return _buildAdminCard(admin);
      },
    );
  }

  Widget _buildAdminCard(AdminProfile admin) {
    final user = UserService.getAllUsers().firstWhere(
      (u) => u.id == admin.userId,
      orElse: () => UserProfile(
        id: admin.userId,
        name: 'Unknown User',
        email: '',
        phone: '',
      ),
    );

    final isCurrentUser = UserService.currentUser?.id == admin.userId;
    final isSuperAdmin = admin.level == AdminLevel.superAdmin;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSuperAdmin ? Colors.purple[100] : Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuperAdmin ? Icons.shield : Icons.admin_panel_settings,
            color: isSuperAdmin ? Colors.purple[700] : Colors.blue[700],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (isSuperAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'SUPER ADMIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ),
            if (isCurrentUser)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'YOU',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 4),
            Text(
              'Level: ${admin.level.displayName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Created: ${admin.createdAt.toString().split(' ')[0]}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: !isCurrentUser
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleAdminAction(value, admin),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'permissions',
                    child: Row(
                      children: [
                        Icon(Icons.security, size: 20),
                        SizedBox(width: 8),
                        Text('Manage Permissions'),
                      ],
                    ),
                  ),
                  if (!isSuperAdmin)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(
                            Icons.remove_circle,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Remove Admin'),
                        ],
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }

  void _handleAdminAction(String action, AdminProfile admin) {
    switch (action) {
      case 'permissions':
        _showPermissionsDialog(admin);
        break;
      case 'remove':
        _removeAdmin(admin);
        break;
    }
  }

  void _showPermissionsDialog(AdminProfile admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Permissions'),
        content: const Text('Permission management coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _removeAdmin(AdminProfile admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Admin'),
        content: const Text(
          'Are you sure you want to remove this admin? They will lose all admin privileges.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AdminService.deleteAdmin(admin.userId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAdmins();
      }
    }
  }

  void _showAddAdminDialog() {
    final users = UserService.getAllUsers();
    final nonAdminUsers = users
        .where((u) => !u.hasRole(UserRole.admin))
        .toList();

    if (nonAdminUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users available to make admin')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select User to Make Admin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: nonAdminUsers.length,
            itemBuilder: (context, index) {
              final user = nonAdminUsers[index];
              return ListTile(
                leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () {
                  Navigator.pop(context);
                  _showAdminRoleSelectionDialog(user);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<AdminPermission> _getDefaultPermissionsForLevel(AdminLevel level) {
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

  void _showAdminRoleSelectionDialog(UserProfile user) {
    AdminLevel selectedLevel = AdminLevel.admin;
    List<AdminPermission> selectedPermissions = _getDefaultPermissionsForLevel(
      AdminLevel.admin,
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Admin Role to ${user.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Admin Level:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...AdminLevel.values.map(
                  (level) => RadioListTile<AdminLevel>(
                    title: Text(level.displayName),
                    subtitle: Text(level.description),
                    value: level,
                    groupValue: selectedLevel,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedLevel = value;
                          selectedPermissions = _getDefaultPermissionsForLevel(
                            value,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...AdminPermission.values.map(
                  (permission) => CheckboxListTile(
                    title: Text(permission.displayName),
                    value: selectedPermissions.contains(permission),
                    onChanged: (checked) {
                      setDialogState(() {
                        if (checked == true) {
                          selectedPermissions.add(permission);
                        } else {
                          selectedPermissions.remove(permission);
                        }
                      });
                    },
                    dense: true,
                  ),
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
                Navigator.pop(context);
                await _makeUserAdmin(user, selectedLevel, selectedPermissions);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign Role'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeUserAdmin(
    UserProfile user,
    AdminLevel level,
    List<AdminPermission> permissions,
  ) async {
    final admin = await AdminService.createAdmin(
      userId: user.id,
      level: level,
      permissions: permissions,
    );

    if (admin != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} is now a ${level.displayName}'),
          backgroundColor: Colors.green,
        ),
      );
      _loadAdmins();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create admin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

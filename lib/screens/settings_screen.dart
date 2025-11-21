import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import 'manage_my_accounts_screen.dart';
import '../services/notification_preferences_service.dart';
import '../services/admin_service.dart';
import '../services/document_service.dart';
import '../models/document.dart';
import 'admin_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hasAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    // Ensure AdminService is initialized and loaded from storage
    await AdminService.initialize();
    setState(() {
      _hasAdmin = AdminService.hasAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
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
      body: ListView(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.manage_accounts,
            title: 'Manage My Accounts',
            subtitle: 'View and manage all your account types',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageMyAccountsScreen(),
                ),
              );
            },
          ),
          if (!_hasAdmin)
            _buildSettingsItem(
              context,
              icon: Icons.admin_panel_settings,
              title: 'Become Admin',
              subtitle: 'Set up admin account for system management',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminSetupScreen(),
                  ),
                );
                // Refresh the admin status when returning
                if (mounted) {
                  await _checkAdminStatus();
                }
              },
              isHighlighted: true,
            ),
          _buildSettingsItem(
            context,
            icon: Icons.notifications,
            title: 'Manage Notifications',
            subtitle: 'Control your notification preferences',
            onTap: () {
              _showNotificationSettings(context);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Security'),
          _buildBiometricSettingItem(context),
          _buildSettingsItem(
            context,
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          _buildTwoFactorSettingItem(context),
          _buildSettingsItem(
            context,
            icon: Icons.devices,
            title: 'Active Sessions',
            subtitle: 'Manage devices logged into your account',
            onTap: () {
              _showActiveSessionsDialog(context);
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.history,
            title: 'Login History',
            subtitle: 'View recent login activity',
            onTap: () {
              _showLoginHistoryDialog(context);
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Settings',
            subtitle: 'Control who can see your information',
            onTap: () {
              _showPrivacySettingsDialog(context);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          _buildThemeSettingItem(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Data & Privacy'),
          _buildSettingsItem(
            context,
            icon: Icons.download,
            title: 'Download My Data',
            subtitle: 'Export your personal data',
            onTap: () {
              _showDownloadDataDialog(context);
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.delete_forever,
            title: 'Delete/Deactivate Account',
            subtitle:
                'Permanently delete or temporarily deactivate your account',
            onTap: () {
              _showDeleteDeactivateDialog(context);
            },
            isDestructive: true,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Developer Options'),
          _buildSettingsItem(
            context,
            icon: Icons.science,
            title: 'Test Provider Report',
            subtitle: 'Simulate a healthcare provider sending a medical report',
            onTap: () {
              _showTestProviderReportDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
        ),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? Colors.red[200]!
                : isHighlighted
                ? Colors.blue[300]!
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red[50]
                    : isHighlighted
                    ? Colors.blue[100]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? Colors.red[700]
                    : isHighlighted
                    ? Colors.blue[700]
                    : Colors.grey[700],
                size: 24,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        16,
                      ),
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red[700]
                          : isHighlighted
                          ? Colors.blue[900]
                          : Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 4),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        13,
                      ),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBiometricSettingItem(BuildContext context) {
    bool biometricEnabled = false;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.fingerprint, color: Colors.grey[700], size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biometric Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Use fingerprint or face ID to login',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: biometricEnabled,
              onChanged: (value) {
                setState(() => biometricEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Biometric login enabled'
                          : 'Biometric login disabled',
                    ),
                    backgroundColor: Colors.black,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoFactorSettingItem(BuildContext context) {
    bool twoFactorEnabled = false;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.security, color: Colors.grey[700], size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-Factor Authentication',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add an extra layer of security',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: twoFactorEnabled,
              onChanged: (value) {
                if (value) {
                  _showTwoFactorSetupDialog(context, (enabled) {
                    setState(() => twoFactorEnabled = enabled);
                  });
                } else {
                  setState(() => twoFactorEnabled = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Two-factor authentication disabled'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
                    ),
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
              onPressed: () {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.palette, color: Colors.grey[700], size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose your preferred theme',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: 'Light',
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Light', child: Text('Light')),
              DropdownMenuItem(value: 'Dark', child: Text('Dark')),
            ],
            onChanged: (value) {
              // Theme change logic will be implemented later
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$value theme selected (Coming soon)'),
                  backgroundColor: Colors.black,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download My Data'),
        content: const Text(
          'Your personal data will be exported and sent to your registered email address. This may take a few minutes.\n\nDo you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Data export initiated. You will receive an email shortly.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) async {
    // Load current preferences
    final prefs = await NotificationPreferencesService.getAllPreferences();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool pushNotifications = prefs['push'] ?? true;
            bool emailNotifications = prefs['email'] ?? true;
            bool smsNotifications = prefs['sms'] ?? false;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notification Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive app notifications'),
                    value: pushNotifications,
                    activeColor: Colors.grey[700],
                    onChanged: (value) {
                      setState(() => pushNotifications = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive notifications via email'),
                    value: emailNotifications,
                    activeColor: Colors.grey[700],
                    onChanged: (value) {
                      setState(() => emailNotifications = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('SMS Notifications'),
                    subtitle: const Text('Receive notifications via SMS'),
                    value: smsNotifications,
                    activeColor: Colors.grey[700],
                    onChanged: (value) {
                      setState(() => smsNotifications = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Save preferences
                        await NotificationPreferencesService.setPushNotifications(
                          pushNotifications,
                        );
                        await NotificationPreferencesService.setEmailNotifications(
                          emailNotifications,
                        );
                        await NotificationPreferencesService.setSmsNotifications(
                          smsNotifications,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification settings saved'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Account Management',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Warning: You will lose access to all your accounts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose an option:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _buildOptionCard(
                  icon: Icons.pause_circle_outline,
                  title: 'Deactivate Account',
                  description:
                      'Temporarily disable your account. If you don\'t log in within 3 months, it will be permanently deleted.',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildOptionCard(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  description:
                      'Schedule permanent deletion in 30 days. You can cancel by logging in during this period.',
                  color: Colors.red,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeactivateConfirmation(context);
              },
              child: const Text(
                'Deactivate',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivateConfirmation(BuildContext context) {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.pause_circle_outline,
                    color: Colors.orange[700],
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Deactivate Account',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Important Information',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Your account will be temporarily deactivated\n'
                            '• You will lose access to all your accounts\n'
                            '• You can reactivate by logging in again\n'
                            '• If you don\'t log in within 3 months, your account will be permanently deleted',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter your password to confirm:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => obscurePassword = !obscurePassword,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    passwordController.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your password'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    passwordController.dispose();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Account deactivated. You have 3 months to reactivate by logging in.',
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Deactivate Account'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red[700], size: 28),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Critical Warning',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Your account will be scheduled for deletion in 30 days\n'
                            '• You will lose access to all your accounts immediately\n'
                            '• All your data will be permanently deleted after 30 days\n'
                            '• You can cancel deletion by logging in within 30 days\n'
                            '• This action cannot be undone after 30 days',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter your password to confirm:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => obscurePassword = !obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Type "DELETE" to confirm:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      decoration: const InputDecoration(
                        labelText: 'Type DELETE',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    passwordController.dispose();
                    confirmController.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your password'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (confirmController.text != 'DELETE') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please type DELETE to confirm'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    passwordController.dispose();
                    confirmController.dispose();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Account scheduled for deletion in 30 days. Log in to cancel.',
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete Account'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTwoFactorSetupDialog(
    BuildContext context,
    Function(bool) onEnabled,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Two-Factor Authentication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your preferred 2FA method:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.blue),
                title: const Text('SMS'),
                subtitle: const Text('Receive codes via text message'),
                onTap: () {
                  Navigator.pop(context);
                  _showSmsVerificationDialog(context, onEnabled);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text('Email'),
                subtitle: const Text('Receive codes via email'),
                onTap: () {
                  Navigator.pop(context);
                  _showEmailVerificationDialog(context, onEnabled);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android, color: Colors.blue),
                title: const Text('Authenticator App'),
                subtitle: const Text('Use Google Authenticator or similar'),
                onTap: () {
                  Navigator.pop(context);
                  _showAuthenticatorSetupDialog(context, onEnabled);
                },
              ),
            ],
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

  void _showSmsVerificationDialog(
    BuildContext context,
    Function(bool) onEnabled,
  ) {
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SMS Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your phone number to receive verification codes:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: '+1 (555) 123-4567',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onEnabled(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SMS 2FA enabled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showEmailVerificationDialog(
    BuildContext context,
    Function(bool) onEnabled,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Verification codes will be sent to your registered email address.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onEnabled(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email 2FA enabled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showAuthenticatorSetupDialog(
    BuildContext context,
    Function(bool) onEnabled,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authenticator App Setup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan this QR code with your authenticator app:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 150, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Or enter this code manually:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ABCD EFGH IJKL MNOP',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
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
            onPressed: () {
              Navigator.pop(context);
              onEnabled(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authenticator 2FA enabled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog(BuildContext context) {
    final sessions = [
      {
        'device': 'iPhone 13 Pro',
        'location': 'New York, USA',
        'lastActive': '2 minutes ago',
        'current': true,
      },
      {
        'device': 'Chrome on Windows',
        'location': 'New York, USA',
        'lastActive': '1 hour ago',
        'current': false,
      },
      {
        'device': 'Safari on MacBook',
        'location': 'Boston, USA',
        'lastActive': '2 days ago',
        'current': false,
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    session['current'] as bool
                        ? Icons.phone_android
                        : Icons.computer,
                    color: Colors.blue,
                  ),
                  title: Text(session['device'] as String),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session['location'] as String),
                      Text(
                        'Last active: ${session['lastActive']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: session['current'] as bool
                      ? const Chip(
                          label: Text(
                            'Current',
                            style: TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      : IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Logged out from ${session['device']}',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out from all other devices'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Log Out All Others',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistoryDialog(BuildContext context) {
    final loginHistory = [
      {
        'device': 'iPhone 13 Pro',
        'location': 'New York, USA',
        'time': '2 minutes ago',
        'status': 'success',
      },
      {
        'device': 'Chrome on Windows',
        'location': 'New York, USA',
        'time': '1 hour ago',
        'status': 'success',
      },
      {
        'device': 'Unknown Device',
        'location': 'London, UK',
        'time': '3 hours ago',
        'status': 'failed',
      },
      {
        'device': 'Safari on MacBook',
        'location': 'Boston, USA',
        'time': '2 days ago',
        'status': 'success',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: loginHistory.length,
            itemBuilder: (context, index) {
              final login = loginHistory[index];
              final isSuccess = login['status'] == 'success';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                  title: Text(login['device'] as String),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(login['location'] as String),
                      Text(
                        login['time'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      isSuccess ? 'Success' : 'Failed',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettingsDialog(BuildContext context) {
    bool profileVisible = true;
    bool showEmail = false;
    bool showPhone = false;
    bool allowMessages = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Privacy Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Profile Visible'),
                  subtitle: const Text('Allow others to view your profile'),
                  value: profileVisible,
                  onChanged: (value) => setState(() => profileVisible = value),
                ),
                SwitchListTile(
                  title: const Text('Show Email'),
                  subtitle: const Text('Display email on your profile'),
                  value: showEmail,
                  onChanged: (value) => setState(() => showEmail = value),
                ),
                SwitchListTile(
                  title: const Text('Show Phone Number'),
                  subtitle: const Text('Display phone on your profile'),
                  value: showPhone,
                  onChanged: (value) => setState(() => showPhone = value),
                ),
                SwitchListTile(
                  title: const Text('Allow Messages'),
                  subtitle: const Text('Let other users message you'),
                  value: allowMessages,
                  onChanged: (value) => setState(() => allowMessages = value),
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
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings saved'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestProviderReportDialog(BuildContext context) {
    String selectedProvider = 'Nairobi Hospital';
    String selectedReportType = 'Prescription';

    final providers = [
      'Nairobi Hospital',
      'Dr. James Kiprotich',
      'Dr. Sarah Mwangi',
      'Lancet Kenya Lab',
      'Nairobi Radiology Center',
      'Aga Khan Hospital',
    ];

    final reportTypes = [
      'Prescription',
      'Lab Results',
      'X-Ray Report',
      'Medical Report',
      'Discharge Summary',
      'Vaccination Record',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.science, color: Colors.blue),
              SizedBox(width: 8),
              Text('Test Provider Report'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This will simulate a healthcare provider sending you a medical report',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Provider:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedProvider,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  items: providers.map((provider) {
                    return DropdownMenuItem(
                      value: provider,
                      child: Text(provider),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedProvider = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Report Type:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedReportType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  items: reportTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedReportType = value!);
                  },
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

                // Simulate provider sending report
                await DocumentService.simulateProviderSendingReport(
                  providerName: selectedProvider,
                  reportName: '$selectedReportType from $selectedProvider',
                  reportType: _getDocumentType(selectedReportType),
                  notes: _getReportNotes(selectedProvider, selectedReportType),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$selectedProvider sent you a $selectedReportType! Check your inbox.',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'View',
                        textColor: Colors.white,
                        onPressed: () {
                          // Navigate to inbox
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Report'),
            ),
          ],
        ),
      ),
    );
  }

  DocumentType _getDocumentType(String reportType) {
    switch (reportType) {
      case 'Prescription':
        return DocumentType.prescription;
      case 'Lab Results':
        return DocumentType.bloodTestReport;
      case 'X-Ray Report':
        return DocumentType.xrayReport;
      case 'Medical Report':
        return DocumentType.medicalReport;
      case 'Discharge Summary':
        return DocumentType.dischargeSummary;
      case 'Vaccination Record':
        return DocumentType.vaccinationRecord;
      default:
        return DocumentType.medicalReport;
    }
  }

  String _getReportNotes(String provider, String reportType) {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)}, ${now.year}';

    switch (reportType) {
      case 'Prescription':
        return 'Prescribed by: $provider\nDate: $date\nPharmacy: City Pharmacy\n\nMedications:\n• Amoxicillin 500mg - 14 tablets\n• Ibuprofen 400mg - 20 tablets';
      case 'Lab Results':
        return 'Lab: $provider\nTest Date: $date\nDoctor: Dr. Test Provider\n\nResults:\n• All values within normal range\n• Hemoglobin: 14.5 g/dL\n• White Blood Cells: 7,200/μL';
      case 'X-Ray Report':
        return 'Provider: $provider\nExam Date: $date\nRadiologist: Dr. Test Radiologist\n\nFindings:\n• Clear lung fields\n• Normal cardiac silhouette\n• No acute abnormalities detected';
      case 'Medical Report':
        return 'Provider: $provider\nDate: $date\nDoctor: Dr. Test Provider\n\nSummary:\n• General health assessment completed\n• All vital signs normal\n• No immediate concerns identified';
      case 'Discharge Summary':
        return 'Provider: $provider\nDischarge Date: $date\nAttending Physician: Dr. Test Provider\n\nSummary:\n• Patient recovered well\n• Follow-up in 2 weeks recommended\n• Medications prescribed';
      case 'Vaccination Record':
        return 'Provider: $provider\nVaccination Date: $date\nVaccine: COVID-19 Booster\n\nDetails:\n• Vaccine administered successfully\n• No adverse reactions observed\n• Next dose: Not required';
      default:
        return 'Provider: $provider\nDate: $date\n\nReport details available in the attached document.';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

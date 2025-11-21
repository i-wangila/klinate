import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/provider_profile.dart';
import '../services/user_service.dart';
import '../services/provider_service.dart';
import 'manage_account_screen.dart';
import 'manage_provider_account_screen.dart';
import 'manage_admin_account_screen.dart';

class ManageMyAccountsScreen extends StatefulWidget {
  const ManageMyAccountsScreen({super.key});

  @override
  State<ManageMyAccountsScreen> createState() => _ManageMyAccountsScreenState();
}

class _ManageMyAccountsScreenState extends State<ManageMyAccountsScreen> {
  UserProfile? _user;
  List<ProviderProfile> _providerProfiles = [];
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    _user = UserService.currentUser;

    if (_user != null) {
      // Load provider profiles (only approved ones)
      final allProviders = ProviderService.getProvidersByUserId(_user!.id);
      _providerProfiles = allProviders
          .where((p) => p.status == ProviderStatus.approved)
          .toList();

      // Check if user is admin
      _isAdmin = _user!.hasRole(UserRole.admin);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Manage My Accounts',
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
          : RefreshIndicator(
              onRefresh: _loadAccounts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Accounts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your different account types and privileges',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Horizontal scrollable account cards
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // General Account - Always visible (left)
                          _buildAccountCard(
                            icon: Icons.person,
                            title: 'General Account',
                            subtitle: _user?.name ?? 'User',
                            description: 'Personal information',
                            color: Colors.blue,
                            badge: null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ManageAccountScreen(),
                                ),
                              );
                            },
                          ),

                          // Business Accounts - Only if approved (middle)
                          if (_providerProfiles.isNotEmpty)
                            ..._providerProfiles.map(
                              (profile) => _buildAccountCard(
                                icon: Icons.business,
                                title: 'Business Account',
                                subtitle: profile.providerType.displayName,
                                description:
                                    profile.specialization ?? 'Healthcare',
                                color: Colors.green,
                                badge: 'APPROVED',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManageProviderAccountScreen(
                                            providerProfile: profile,
                                          ),
                                    ),
                                  );
                                  // Reload accounts after returning
                                  _loadAccounts();
                                },
                              ),
                            ),

                          // Admin Account - Only if admin (right)
                          if (_isAdmin)
                            _buildAccountCard(
                              icon: Icons.admin_panel_settings,
                              title: 'Admin Account',
                              subtitle: 'Platform Administrator',
                              description: 'Admin settings',
                              color: Colors.purple,
                              badge: 'ADMIN',
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ManageAdminAccountScreen(),
                                  ),
                                );
                                // Reload accounts after returning
                                _loadAccounts();
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info section
                    _buildInfoSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAccountCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Color.lerp(color, Colors.black, 0.3),
                        size: 40,
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color.lerp(color, Colors.black, 0.4),
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Account Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            '👤 General Account',
            'Your personal profile and basic settings',
          ),
          if (_providerProfiles.isNotEmpty)
            _buildInfoItem(
              '🏥 Business Account',
              'Manage your healthcare services and appointments',
            ),
          if (_isAdmin)
            _buildInfoItem(
              '🛡️ Admin Account',
              'Manage admin settings, role, and permissions',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.blue[700]),
          ),
        ],
      ),
    );
  }
}

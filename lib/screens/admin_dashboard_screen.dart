import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/system_stats.dart';
import '../models/admin_action.dart';
import '../services/admin_service.dart';
import '../services/audit_service.dart';
import '../services/user_service.dart';
import '../widgets/role_switcher.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  SystemStats? _stats;
  List<AdminAction> _recentActions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    await AdminService.initialize();
    await AuditService.initialize();

    _stats = AdminService.getSystemStats();
    _recentActions = AuditService.getRecentActions(limit: 5);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          RoleSwitcher(
            onRoleChanged: (role) {
              if (role == UserRole.patient) {
                Navigator.pushReplacementNamed(context, '/home');
              } else if (role.isProvider) {
                Navigator.pushReplacementNamed(context, '/provider-dashboard');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildRecentActivity(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    final user = UserService.currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.black,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.name ?? "Admin"}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Platform Administrator',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending Approvals',
                _stats!.pendingProviders.toString(),
                Icons.pending_actions,
                Colors.orange,
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    '/admin/pending-providers',
                  );
                  // Refresh dashboard when returning
                  _loadDashboardData();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active Providers',
                _stats!.activeProviders.toString(),
                Icons.verified_user,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Patients',
                _stats!.totalPatients.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Users',
                _stats!.totalUsers.toString(),
                Icons.person,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Appointments',
                _stats!.totalAppointments.toString(),
                Icons.calendar_today,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Average Rating',
                _stats!.averageRating.toStringAsFixed(1),
                Icons.star,
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final pendingCount = _stats?.pendingProviders ?? 0;
    final approvedCount = _stats?.approvedProviders ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Pending Approvals',
          Icons.pending_actions,
          Colors.orange,
          badge: pendingCount > 0 ? pendingCount.toString() : null,
          onTap: () async {
            await Navigator.pushNamed(context, '/admin/pending-providers');
            // Refresh dashboard when returning
            _loadDashboardData();
          },
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          'Approved Business Accounts',
          Icons.check_circle,
          Colors.green,
          badge: approvedCount > 0 ? approvedCount.toString() : null,
          onTap: () =>
              Navigator.pushNamed(context, '/admin/approved-providers'),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          'Manage Admins',
          Icons.shield,
          Colors.purple,
          onTap: () => Navigator.pushNamed(context, '/admin/admin-management'),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          'Manage Users',
          Icons.people_alt,
          Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/admin/user-management'),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          'View Reports',
          Icons.assessment,
          Colors.green,
          onTap: () => Navigator.pushNamed(context, '/admin/reports'),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          'Activity Log',
          Icons.history,
          Colors.purple,
          onTap: () => Navigator.pushNamed(context, '/admin/activity-log'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color, {
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_recentActions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No recent activity',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActions.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final action = _recentActions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActionColor(
                      action.type,
                    ).withValues(alpha: 0.1),
                    child: Text(
                      action.type.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    action.type.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${action.targetName} • ${action.formattedTimestamp}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    action.adminName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Color _getActionColor(AdminActionType type) {
    switch (type) {
      case AdminActionType.providerApproved:
      case AdminActionType.providerReactivated:
      case AdminActionType.userReactivated:
      case AdminActionType.documentApproved:
        return Colors.green;
      case AdminActionType.providerRejected:
      case AdminActionType.documentRejected:
        return Colors.red;
      case AdminActionType.providerSuspended:
      case AdminActionType.userSuspended:
        return Colors.orange;
      case AdminActionType.notificationSent:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

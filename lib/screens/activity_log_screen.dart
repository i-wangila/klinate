import 'package:flutter/material.dart';
import '../models/admin_action.dart';
import '../services/audit_service.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  List<AdminAction> _actions = [];
  bool _isLoading = true;
  AdminActionType? _filterType;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    setState(() => _isLoading = true);

    await AuditService.initialize();
    _actions = AuditService.getRecentActions(limit: 100);

    setState(() => _isLoading = false);
  }

  List<AdminAction> get _filteredActions {
    if (_filterType == null) return _actions;
    return _actions.where((a) => a.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Activity Log'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadActions),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredActions.isEmpty
                ? _buildEmptyState()
                : _buildActivityList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null),
            const SizedBox(width: 8),
            _buildFilterChip('Approvals', AdminActionType.providerApproved),
            const SizedBox(width: 8),
            _buildFilterChip('Rejections', AdminActionType.providerRejected),
            const SizedBox(width: 8),
            _buildFilterChip('Suspensions', AdminActionType.providerSuspended),
            const SizedBox(width: 8),
            _buildFilterChip('Documents', AdminActionType.documentApproved),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AdminActionType? type) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = selected ? type : null);
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[800],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No activity recorded',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredActions.length,
      itemBuilder: (context, index) {
        final action = _filteredActions[index];
        return _buildActivityCard(action);
      },
    );
  }

  Widget _buildActivityCard(AdminAction action) {
    final color = _getActionColor(action.type);

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
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(action.type.icon, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          action.type.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Target: ${action.targetName}'),
            Text('Admin: ${action.adminName}'),
            if (action.details['reason'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Reason: ${action.details['reason']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              action.formattedTimestamp,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
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

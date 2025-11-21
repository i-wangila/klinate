import 'package:flutter/material.dart';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';
import '../services/provider_service.dart';
import '../services/user_service.dart';
import '../services/approval_service.dart';

class ApprovedProvidersScreen extends StatefulWidget {
  const ApprovedProvidersScreen({super.key});

  @override
  State<ApprovedProvidersScreen> createState() =>
      _ApprovedProvidersScreenState();
}

class _ApprovedProvidersScreenState extends State<ApprovedProvidersScreen> {
  List<ProviderProfile> _approvedProviders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovedProviders();
  }

  Future<void> _loadApprovedProviders() async {
    setState(() => _isLoading = true);

    await ProviderService.initialize();
    _approvedProviders = ProviderService.getApprovedProviders();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Approved Business Accounts',
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
              onRefresh: _loadApprovedProviders,
              child: _approvedProviders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _approvedProviders.length,
                      itemBuilder: (context, index) {
                        return _buildProviderCard(_approvedProviders[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Approved Business Accounts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Approved business accounts will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ProviderProfile provider) {
    final users = UserService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.id == provider.userId,
      orElse: () => UserProfile(
        id: provider.userId,
        name: 'Unknown',
        email: '',
        phone: '',
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.medical_services,
                    color: Colors.green[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.providerType.displayName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'APPROVED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.specialization != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.medical_information,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.specialization!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Approved: ${_formatDate(provider.verifiedAt)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _suspendProvider(provider),
                    icon: const Icon(Icons.pause_circle_outline, size: 18),
                    label: const Text('Suspend'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange[700],
                      side: BorderSide(color: Colors.orange[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDetails(provider),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      side: BorderSide(color: Colors.blue[300]!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _suspendProvider(ProviderProfile provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend Business Account'),
        content: const Text(
          'Are you sure you want to suspend this business account? They will lose access to their business dashboard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              await ApprovalService.suspendProvider(
                provider.id,
                UserService.currentUser!.id,
                'Suspended by admin',
              );
              _loadApprovedProviders();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Business account suspended successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _viewDetails(ProviderProfile provider) {
    // Navigate to provider profile or details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('View business account details - Coming soon'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';
import '../models/document.dart';
import '../services/approval_service.dart';
import '../services/user_service.dart';
import '../services/provider_service.dart';
import '../services/document_service.dart';

class PendingProvidersScreen extends StatefulWidget {
  const PendingProvidersScreen({super.key});

  @override
  State<PendingProvidersScreen> createState() => _PendingProvidersScreenState();
}

class _PendingProvidersScreenState extends State<PendingProvidersScreen> {
  List<ProviderProfile> _providers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);

    _providers = ApprovalService.getPendingProviders();

    setState(() => _isLoading = false);
  }

  List<ProviderProfile> get _filteredProviders {
    if (_searchQuery.isEmpty) return _providers;

    final query = _searchQuery.toLowerCase();
    return _providers.where((p) {
      final name = ProviderService.getProviderDisplayName(p.id);
      final email = ProviderService.getProviderEmail(p.id);
      return name.toLowerCase().contains(query) ||
          email.toLowerCase().contains(query) ||
          (p.specialization?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _approveProvider(ProviderProfile provider) async {
    final user = UserService.currentUser;
    if (user == null) return;

    final providerName = ProviderService.getProviderDisplayName(provider.id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Business Account'),
        content: Text('Are you sure you want to approve $providerName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApprovalService.approveProvider(
        provider.id,
        user.id,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $providerName approved'),
              backgroundColor: Colors.green,
            ),
          );
          _loadProviders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to approve business account'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectProvider(ProviderProfile provider) async {
    final user = UserService.currentUser;
    if (user == null) return;

    final providerName = ProviderService.getProviderDisplayName(provider.id);
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Business Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject $providerName?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.trim().isNotEmpty) {
      final success = await ApprovalService.rejectProvider(
        provider.id,
        user.id,
        reasonController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $providerName rejected'),
              backgroundColor: Colors.red,
            ),
          );
          _loadProviders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject business account'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Pending Approvals (${_providers.length})'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search business accounts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Providers list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProviders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No pending approvals'
                              : 'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProviders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredProviders.length,
                      itemBuilder: (context, index) {
                        final provider = _filteredProviders[index];
                        return _buildProviderCard(provider);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ProviderProfile provider) {
    final providerName = ProviderService.getProviderDisplayName(provider.id);
    final providerEmail = ProviderService.getProviderEmail(provider.id);
    final providerPhone = ProviderService.getProviderPhone(provider.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getProviderColor(
                    provider.providerType,
                  ).withValues(alpha: 0.1),
                  child: Icon(
                    _getProviderIcon(provider.providerType),
                    color: _getProviderColor(provider.providerType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
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
              ],
            ),
            const SizedBox(height: 12),
            if (provider.specialization != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
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
                  providerEmail,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  providerPhone,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDocumentReviewSection(provider),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectProvider(provider),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveProvider(provider),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildDocumentReviewSection(ProviderProfile provider) {
    // Get only provider verification documents (not patient medical records)
    final allDocuments = DocumentService.getAllDocuments();
    final documents = allDocuments
        .where((doc) => _isProviderVerificationDocument(doc.type))
        .toList();
    final totalDocs = documents.length;
    final approvedDocs = documents
        .where((d) => d.status == DocumentStatus.approved)
        .length;
    final pendingDocs = documents
        .where((d) => d.status == DocumentStatus.pending)
        .length;
    final rejectedDocs = documents
        .where((d) => d.status == DocumentStatus.rejected)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Document Statistics Cards
        Row(
          children: [
            Expanded(
              child: _buildDocStatCard(
                'Total',
                totalDocs.toString(),
                Icons.description,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDocStatCard(
                'Approved',
                approvedDocs.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDocStatCard(
                'Pending',
                pendingDocs.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDocStatCard(
                'Rejected',
                rejectedDocs.toString(),
                Icons.cancel,
                Colors.red,
              ),
            ),
          ],
        ),
        if (documents.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Pending Review',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pendingDocs.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...documents.map((doc) => _buildDocumentCard(doc)),
        ],
      ],
    );
  }

  Widget _buildDocStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getDocumentStatusColor(document.status).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDocumentStatusColor(
            document.status,
          ).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Document Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description, color: Colors.orange[700], size: 24),
          ),
          const SizedBox(width: 12),
          // Document Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.typeDisplayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  document.name,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getDocumentStatusColor(document.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        document.statusText,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Uploaded ${DateFormat('MMM dd, yyyy').format(document.uploadedAt)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Download Button
              IconButton(
                onPressed: () => _downloadDocument(document),
                icon: const Icon(Icons.download),
                iconSize: 20,
                color: Colors.grey[700],
                tooltip: 'Download',
              ),
              if (document.status == DocumentStatus.pending) ...[
                // Approve Button
                IconButton(
                  onPressed: () => _approveDocument(document),
                  icon: const Icon(Icons.check),
                  iconSize: 20,
                  color: Colors.green,
                  tooltip: 'Approve',
                ),
                // Reject Button
                IconButton(
                  onPressed: () => _rejectDocument(document),
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  color: Colors.red,
                  tooltip: 'Reject',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getDocumentStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.rejected:
        return Colors.red;
      case DocumentStatus.expired:
        return Colors.grey;
    }
  }

  Future<void> _approveDocument(Document document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Document'),
        content: Text('Approve ${document.typeDisplayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DocumentService.updateDocumentStatus(
        document.id,
        DocumentStatus.approved,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${document.typeDisplayName} approved'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _loadProviders();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to approve document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectDocument(Document document) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject ${document.typeDisplayName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.trim().isNotEmpty) {
      final success = await DocumentService.updateDocumentStatus(
        document.id,
        DocumentStatus.rejected,
        rejectionReason: reasonController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${document.typeDisplayName} rejected'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _loadProviders();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _downloadDocument(Document document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${document.name}...'),
        backgroundColor: Colors.blue,
      ),
    );
    // TODO: Implement actual download functionality
  }

  IconData _getProviderIcon(UserRole type) {
    if (type.isInstitution) {
      return Icons.business;
    }
    return Icons.person;
  }

  Color _getProviderColor(UserRole type) {
    if (type.isInstitution) {
      return Colors.blue;
    }
    return Colors.green;
  }

  // Helper method to identify provider verification documents (not patient medical records)
  bool _isProviderVerificationDocument(DocumentType type) {
    // Only show business verification documents in admin dashboard
    const providerDocTypes = [
      DocumentType.medicalLicense,
      DocumentType.professionalCertification,
      DocumentType.validId,
      DocumentType.nursingLicense,
      DocumentType.professionalLicense,
      DocumentType.certification,
      DocumentType.nutritionCertification,
      DocumentType.caregiverCertification,
      DocumentType.backgroundCheck,
    ];
    return providerDocTypes.contains(type);
  }
}

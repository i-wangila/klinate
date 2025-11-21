import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../utils/responsive_utils.dart';
import 'document_viewer_screen.dart';

class DocumentManagementScreen extends StatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  State<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  List<Document> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    await DocumentService.initialize();

    setState(() {
      _documents = DocumentService.getAllDocuments();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadDocuments,
                child: _documents.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 60),
                          _buildEmptyState(),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 60,
                          ),
                        ],
                      )
                    : _buildDocumentsList(),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ResponsiveUtils.flexibleContainer(
        context: context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: ResponsiveUtils.isSmallScreen(context) ? 60 : 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            ResponsiveUtils.safeText(
              'No medical records yet',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ResponsiveUtils.safeText(
                'Medical records from your healthcare providers will appear here',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    // Show only approved medical records (all from verified providers are auto-approved)
    final approvedDocs = _documents
        .where((doc) => doc.status == DocumentStatus.approved)
        .toList();
    final expiringDocs = approvedDocs
        .where((doc) => doc.needsRenewal || doc.isExpired)
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: ResponsiveUtils.getResponsivePadding(context).add(
        EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expiringDocs.isNotEmpty) ...[
            _buildSectionHeader(
              'Expiring Soon',
              Colors.orange,
              expiringDocs.length,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            ...expiringDocs.map((doc) => _buildDocumentCard(doc)),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          ],
          if (approvedDocs.isNotEmpty) ...[
            _buildSectionHeader(
              'Medical Records',
              Colors.green,
              approvedDocs.length,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            ...approvedDocs.map((doc) => _buildDocumentCard(doc)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
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
      child: ListTile(
        contentPadding: ResponsiveUtils.getResponsivePadding(context),
        leading: _buildDocumentIcon(document),
        title: ResponsiveUtils.safeText(
          document.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          ),
          maxLines: 2,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            ResponsiveUtils.safeText(
              document.typeDisplayName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
              maxLines: 1,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildStatusChip(document.status),
                if (!ResponsiveUtils.isSmallScreen(context))
                  ResponsiveUtils.safeText(
                    'Uploaded ${DateFormat('MMM dd, yyyy').format(document.uploadedAt)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        12,
                      ),
                    ),
                    maxLines: 1,
                  ),
              ],
            ),
            if (ResponsiveUtils.isSmallScreen(context)) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 2),
              ),
              ResponsiveUtils.safeText(
                'Uploaded ${DateFormat('MMM dd').format(document.uploadedAt)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                ),
                maxLines: 1,
              ),
            ],
            if (document.expiryDate != null) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 4),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: ResponsiveUtils.isSmallScreen(context) ? 10 : 12,
                    color: document.isExpired
                        ? Colors.red
                        : document.needsRenewal
                        ? Colors.orange
                        : Colors.grey[500],
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 4),
                  ),
                  Flexible(
                    child: ResponsiveUtils.safeText(
                      'Expires ${DateFormat(ResponsiveUtils.isSmallScreen(context) ? 'MMM dd' : 'MMM dd, yyyy').format(document.expiryDate!)}',
                      style: TextStyle(
                        color: document.isExpired
                            ? Colors.red
                            : document.needsRenewal
                            ? Colors.orange
                            : Colors.grey[500],
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          12,
                        ),
                        fontWeight: document.isExpired || document.needsRenewal
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
            if (document.status == DocumentStatus.rejected &&
                document.rejectionReason != null) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 4),
              ),
              ResponsiveUtils.safeText(
                'Reason: ${document.rejectionReason}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _downloadDocument(document),
          tooltip: 'Download',
        ),
        onTap: () => _viewDocument(document),
      ),
    );
  }

  Widget _buildDocumentIcon(Document document) {
    Color iconColor;
    IconData iconData;

    switch (document.status) {
      case DocumentStatus.approved:
        iconColor = Colors.green;
        break;
      case DocumentStatus.rejected:
        iconColor = Colors.red;
        break;
      case DocumentStatus.expired:
        iconColor = Colors.grey;
        break;
      default:
        iconColor = Colors.orange;
    }

    if (document.isPdf) {
      iconData = Icons.picture_as_pdf;
    } else if (document.isImage) {
      iconData = Icons.image;
    } else {
      iconData = Icons.description;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildStatusChip(DocumentStatus status) {
    Color color;
    String text;

    switch (status) {
      case DocumentStatus.approved:
        color = Colors.green;
        text = 'Approved';
        break;
      case DocumentStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case DocumentStatus.expired:
        color = Colors.grey;
        text = 'Expired';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Removed - patients cannot upload medical records
  // Medical records are only received from healthcare providers

  // Removed - patients cannot upload medical records

  void _viewDocument(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(document: document),
      ),
    );
  }

  void _downloadDocument(Document document) {
    // In a real app, this would download the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${document.name}...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

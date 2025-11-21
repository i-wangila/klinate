import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';

class DocumentViewerScreen extends StatelessWidget {
  final Document document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showDocumentInfo(context),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDocumentHeader(),
          Expanded(child: _buildDocumentContent()),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.typeDisplayName,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 12),
          _buildDocumentDetails(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    Color color;
    IconData icon;

    switch (document.status) {
      case DocumentStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DocumentStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case DocumentStatus.expired:
        color = Colors.grey;
        icon = Icons.schedule;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String text;

    switch (document.status) {
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
        text = 'Pending Review';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDocumentDetails() {
    return Column(
      children: [
        _buildDetailRow(
          'Uploaded',
          DateFormat('MMM dd, yyyy at HH:mm').format(document.uploadedAt),
          Icons.upload,
        ),
        if (document.expiryDate != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            'Expires',
            DateFormat('MMM dd, yyyy').format(document.expiryDate!),
            Icons.schedule,
            textColor: document.isExpired
                ? Colors.red
                : document.needsRenewal
                ? Colors.orange
                : null,
          ),
        ],
        const SizedBox(height: 8),
        _buildDetailRow('File Size', document.fileSizeFormatted, Icons.storage),
        if (document.notes != null && document.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow('Notes', document.notes!, Icons.note),
        ],
        if (document.status == DocumentStatus.rejected &&
            document.rejectionReason != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            'Rejection Reason',
            document.rejectionReason!,
            Icons.error,
            textColor: Colors.red,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: textColor ?? Colors.black,
              fontWeight: textColor != null
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentContent() {
    if (document.isImage) {
      return _buildImageViewer();
    } else if (document.isPdf) {
      return _buildPdfViewer();
    } else {
      return _buildUnsupportedFileViewer();
    }
  }

  Widget _buildImageViewer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4.0,
        child: kIsWeb
            ? Image.network(
                document.filePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget('Failed to load image');
                },
              )
            : Image.file(
                File(document.filePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget('Failed to load image');
                },
              ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'PDF Document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            document.fileName,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'PDF viewer not implemented yet.\nFile is stored securely.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedFileViewer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Unsupported File Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            document.fileName,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDocumentInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Document Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildInfoItem('Document ID', document.id),
            _buildInfoItem('File Name', document.fileName),
            _buildInfoItem(
              'File Extension',
              document.fileExtension.toUpperCase(),
            ),
            _buildInfoItem('File Size', document.fileSizeFormatted),
            _buildInfoItem(
              'Upload Date',
              DateFormat('MMM dd, yyyy at HH:mm').format(document.uploadedAt),
            ),
            if (document.expiryDate != null)
              _buildInfoItem(
                'Expiry Date',
                DateFormat('MMM dd, yyyy').format(document.expiryDate!),
              ),
            _buildInfoItem('Status', document.statusText),
            if (document.notes != null && document.notes!.isNotEmpty)
              _buildInfoItem('Notes', document.notes!),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';
import '../services/document_service.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final String? highlightDocumentId;

  const MedicalRecordsScreen({super.key, this.highlightDocumentId});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Prescriptions',
    'Lab Tests',
    'Imaging',
    'Reports',
    'Plans',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Medical Records',
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
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(child: _buildDocumentsList()),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[800],
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue[800] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentsList() {
    final allDocuments = DocumentService.getAllDocuments();
    final filteredDocuments = _filterDocuments(allDocuments);

    if (filteredDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No medical records found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = filteredDocuments[index];
        final isHighlighted = document.id == widget.highlightDocumentId;
        return _buildDocumentCard(document, isHighlighted);
      },
    );
  }

  List<Document> _filterDocuments(List<Document> documents) {
    // Filter medical documents only - exclude all business verification documents
    final medicalDocs = documents.where((doc) {
      return doc.type == DocumentType.prescription ||
          doc.type == DocumentType.labResults ||
          doc.type == DocumentType.xrayReport ||
          doc.type == DocumentType.medicalReport ||
          doc.type == DocumentType.dischargeSummary ||
          doc.type == DocumentType.vaccinationRecord ||
          doc.type == DocumentType.ctScanReport ||
          doc.type == DocumentType.mriReport ||
          doc.type == DocumentType.ultrasoundReport ||
          doc.type == DocumentType.ecgReport ||
          doc.type == DocumentType.nutritionPlan ||
          doc.type == DocumentType.physiotherapyReport ||
          doc.type == DocumentType.dentalReport ||
          doc.type == DocumentType.eyeExamReport ||
          doc.type == DocumentType.bloodTestReport ||
          doc.type == DocumentType.urineTestReport ||
          doc.type == DocumentType.biopsyReport ||
          doc.type == DocumentType.pathologyReport;
    }).toList();

    if (_selectedCategory == 'All') {
      return medicalDocs;
    } else if (_selectedCategory == 'Prescriptions') {
      return medicalDocs
          .where((doc) => doc.type == DocumentType.prescription)
          .toList();
    } else if (_selectedCategory == 'Lab Tests') {
      return medicalDocs
          .where(
            (doc) =>
                doc.type == DocumentType.labResults ||
                doc.type == DocumentType.bloodTestReport ||
                doc.type == DocumentType.urineTestReport ||
                doc.type == DocumentType.biopsyReport ||
                doc.type == DocumentType.pathologyReport,
          )
          .toList();
    } else if (_selectedCategory == 'Imaging') {
      return medicalDocs
          .where(
            (doc) =>
                doc.type == DocumentType.xrayReport ||
                doc.type == DocumentType.ctScanReport ||
                doc.type == DocumentType.mriReport ||
                doc.type == DocumentType.ultrasoundReport,
          )
          .toList();
    } else if (_selectedCategory == 'Reports') {
      return medicalDocs
          .where(
            (doc) =>
                doc.type == DocumentType.medicalReport ||
                doc.type == DocumentType.dischargeSummary ||
                doc.type == DocumentType.ecgReport ||
                doc.type == DocumentType.physiotherapyReport ||
                doc.type == DocumentType.dentalReport ||
                doc.type == DocumentType.eyeExamReport,
          )
          .toList();
    } else if (_selectedCategory == 'Plans') {
      return medicalDocs
          .where((doc) => doc.type == DocumentType.nutritionPlan)
          .toList();
    } else {
      return medicalDocs
          .where((doc) => doc.type == DocumentType.vaccinationRecord)
          .toList();
    }
  }

  Widget _buildDocumentCard(Document document, bool isHighlighted) {
    final statusColor = _getStatusColor(document);
    final statusText = _getStatusText(document);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewDocument(document),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        document.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (statusText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                if (document.notes != null) ...[
                  const SizedBox(height: 16),
                  ..._parseNotes(document.notes!),
                ],
                // PDF Attachment indicator
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 20,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        document.fileName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.download, size: 20, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(Document document) {
    if (document.isExpired) {
      return Colors.red;
    } else if (document.status == DocumentStatus.approved) {
      return Colors.green;
    } else if (document.status == DocumentStatus.rejected) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  String? _getStatusText(Document document) {
    if (document.isExpired) {
      return 'Expired';
    } else if (document.status == DocumentStatus.approved) {
      return 'Collected';
    } else if (document.status == DocumentStatus.rejected) {
      return 'Rejected';
    } else if (document.status == DocumentStatus.pending) {
      return 'Pending';
    }
    return null;
  }

  List<Widget> _parseNotes(String notes) {
    final lines = notes.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      '${parts[0].trim()}:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      parts[1].trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          );
        }
      } else if (line.startsWith('•') || line.startsWith('-')) {
        // Handle medication list items
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.medication, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.replaceFirst(RegExp(r'^[•\-]\s*'), ''),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  void _viewDocument(Document document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document.typeDisplayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Document: ${document.name}'),
              const SizedBox(height: 8),
              Text(
                'Uploaded: ${DateFormat('MMM dd, yyyy - h:mm a').format(document.uploadedAt)}',
              ),
              if (document.notes != null) ...[
                const SizedBox(height: 8),
                Text('Notes: ${document.notes}'),
              ],
              const SizedBox(height: 16),
              const Text(
                'Document preview and download functionality will be implemented here.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading ${document.name}...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

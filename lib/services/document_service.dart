import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document.dart';
import '../models/message.dart';
import 'message_service.dart';

class DocumentService {
  static const String _storageKey = 'klinate_documents';
  static final List<Document> _documents = [];
  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadDocuments();

    // No sample data - documents will be added by providers in real-time

    _isInitialized = true;
  }

  // Load documents from storage
  static Future<void> _loadDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getString(_storageKey);

      if (documentsJson != null) {
        final List<dynamic> documentsList = json.decode(documentsJson);
        _documents.clear();
        _documents.addAll(
          documentsList.map((json) => Document.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      // Handle loading error silently
    }
  }

  // Save documents to storage
  static Future<void> _saveDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = json.encode(
        _documents.map((doc) => doc.toJson()).toList(),
      );
      await prefs.setString(_storageKey, documentsJson);
    } catch (e) {
      // Handle save error silently
    }
  }

  // Upload a new document
  static Future<bool> uploadDocument({
    required String name,
    required DocumentType type,
    required String filePath,
    DateTime? expiryDate,
    String? notes,
  }) async {
    try {
      String finalFilePath = filePath;
      String fileName = filePath.split('/').last;
      String fileExtension = fileName.split('.').last;
      int fileSize = 0;

      // For non-web platforms, copy the file
      try {
        final file = File(filePath);
        if (await file.exists()) {
          // Copy file to app documents directory
          final appDir = await getApplicationDocumentsDirectory();
          final newFileName =
              'doc_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
          final newFilePath = '${appDir.path}/documents/$newFileName';

          // Create documents directory if it doesn't exist
          final documentsDir = Directory('${appDir.path}/documents');
          if (!await documentsDir.exists()) {
            await documentsDir.create(recursive: true);
          }

          // Copy file
          final newFile = await file.copy(newFilePath);
          final fileStats = await newFile.stat();
          finalFilePath = newFilePath;
          fileSize = fileStats.size;
        } else {
          // For web or if file doesn't exist, use the path as-is
          finalFilePath = filePath;
          fileSize = 0;
        }
      } catch (e) {
        // If file operations fail (e.g., on web), use the path as-is
        finalFilePath = filePath;
        fileSize = 0;
      }

      final document = Document(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: type,
        filePath: finalFilePath,
        fileName: fileName,
        fileExtension: fileExtension,
        fileSizeBytes: fileSize,
        uploadedAt: DateTime.now(),
        expiryDate: expiryDate,
        status: DocumentStatus.pending,
        notes: notes,
      );

      _documents.add(document);
      await _saveDocuments();

      // Send notification for medical documents
      await _sendMedicalDocumentNotification(document);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Send notification when medical document is uploaded
  static Future<void> _sendMedicalDocumentNotification(
    Document document,
  ) async {
    // Only send notifications for medical documents
    if (!_isMedicalDocument(document.type)) return;

    final messageType = _getMessageTypeForDocument(document.type);
    final providerName = _getProviderNameForDocument(document.type);
    final content = _getNotificationContent(document);

    await MessageService.createMedicalRecordNotification(
      providerName: providerName,
      recordType: messageType,
      content: content,
      documentId: document.id,
    );
  }

  static bool _isMedicalDocument(DocumentType type) {
    return type == DocumentType.prescription ||
        type == DocumentType.labResults ||
        type == DocumentType.xrayReport ||
        type == DocumentType.medicalReport ||
        type == DocumentType.dischargeSummary ||
        type == DocumentType.vaccinationRecord;
  }

  static MessageType _getMessageTypeForDocument(DocumentType type) {
    switch (type) {
      case DocumentType.prescription:
        return MessageType.prescription;
      case DocumentType.labResults:
        return MessageType.labResults;
      case DocumentType.xrayReport:
        return MessageType.xrayReport;
      case DocumentType.medicalReport:
        return MessageType.medicalReport;
      case DocumentType.dischargeSummary:
        return MessageType.dischargeSummary;
      case DocumentType.vaccinationRecord:
        return MessageType.vaccinationRecord;
      default:
        return MessageType.medicalReport;
    }
  }

  static String _getProviderNameForDocument(DocumentType type) {
    switch (type) {
      case DocumentType.prescription:
        return 'Healthcare Provider';
      case DocumentType.labResults:
        return 'Laboratory';
      case DocumentType.xrayReport:
        return 'Radiology Department';
      case DocumentType.medicalReport:
        return 'Medical Center';
      default:
        return 'Healthcare Provider';
    }
  }

  static String _getNotificationContent(Document document) {
    switch (document.type) {
      case DocumentType.prescription:
        return 'New prescription has been sent to you. Tap to view details.';
      case DocumentType.labResults:
        return 'Your lab results are ready. Tap to view your test results.';
      case DocumentType.xrayReport:
        return 'Your X-ray report is available. Tap to view the report.';
      case DocumentType.medicalReport:
        return 'New medical report has been uploaded. Tap to view.';
      case DocumentType.dischargeSummary:
        return 'Your discharge summary is ready. Tap to view details.';
      case DocumentType.vaccinationRecord:
        return 'Vaccination record has been updated. Tap to view.';
      default:
        return 'New medical document available. Tap to view.';
    }
  }

  // Get all documents
  static List<Document> getAllDocuments() {
    return List.from(_documents);
  }

  // Get documents by type
  static List<Document> getDocumentsByType(DocumentType type) {
    return _documents.where((doc) => doc.type == type).toList();
  }

  // Get documents by status
  static List<Document> getDocumentsByStatus(DocumentStatus status) {
    return _documents.where((doc) => doc.status == status).toList();
  }

  // Get pending documents
  static List<Document> getPendingDocuments() {
    return getDocumentsByStatus(DocumentStatus.pending);
  }

  // Get approved documents
  static List<Document> getApprovedDocuments() {
    return getDocumentsByStatus(DocumentStatus.approved);
  }

  // Get expired or expiring documents
  static List<Document> getExpiringDocuments() {
    return _documents
        .where((doc) => doc.isExpired || doc.needsRenewal)
        .toList();
  }

  // Update document status
  static Future<bool> updateDocumentStatus(
    String documentId,
    DocumentStatus status, {
    String? rejectionReason,
  }) async {
    try {
      final index = _documents.indexWhere((doc) => doc.id == documentId);
      if (index == -1) return false;

      _documents[index] = _documents[index].copyWith(
        status: status,
        rejectionReason: rejectionReason,
      );

      await _saveDocuments();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Replace/update an existing document
  static Future<bool> replaceDocument({
    required String documentId,
    required String filePath,
    String? notes,
    DateTime? expiryDate,
  }) async {
    try {
      final index = _documents.indexWhere((doc) => doc.id == documentId);
      if (index == -1) return false;

      final oldDocument = _documents[index];

      // Try to delete old file
      try {
        final oldFile = File(oldDocument.filePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        // Ignore deletion errors
      }

      String finalFilePath = filePath;
      String fileName = filePath.split('/').last;
      String fileExtension = fileName.split('.').last;
      int fileSize = 0;

      // Try to copy new file
      try {
        final file = File(filePath);
        if (await file.exists()) {
          final appDir = await getApplicationDocumentsDirectory();
          final newFileName =
              'doc_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
          final newFilePath = '${appDir.path}/documents/$newFileName';

          final newFile = await file.copy(newFilePath);
          final fileStats = await newFile.stat();
          finalFilePath = newFilePath;
          fileSize = fileStats.size;
        } else {
          finalFilePath = filePath;
          fileSize = 0;
        }
      } catch (e) {
        // Use the path as-is if copy fails
        finalFilePath = filePath;
        fileSize = 0;
      }

      _documents[index] = oldDocument.copyWith(
        filePath: finalFilePath,
        fileName: fileName,
        fileExtension: fileExtension,
        fileSizeBytes: fileSize,
        uploadedAt: DateTime.now(),
        expiryDate: expiryDate,
        status: DocumentStatus.pending,
        notes: notes,
        rejectionReason: null,
      );

      await _saveDocuments();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete a document
  static Future<bool> deleteDocument(String documentId) async {
    try {
      final index = _documents.indexWhere((doc) => doc.id == documentId);
      if (index == -1) return false;

      final document = _documents[index];

      // Try to delete file
      try {
        final file = File(document.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore file deletion errors
      }

      _documents.removeAt(index);
      await _saveDocuments();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get document by ID
  static Document? getDocumentById(String documentId) {
    try {
      return _documents.firstWhere((doc) => doc.id == documentId);
    } catch (e) {
      return null;
    }
  }

  // Get documents by provider ID
  static List<Document> getDocumentsByProviderId(String providerId) {
    return _documents.where((doc) => doc.providerId == providerId).toList();
  }

  // Check if document type already exists and is approved
  static bool hasApprovedDocument(DocumentType type) {
    return _documents.any(
      (doc) => doc.type == type && doc.status == DocumentStatus.approved,
    );
  }

  // Get the latest document of a specific type
  static Document? getLatestDocumentByType(DocumentType type) {
    final docs = getDocumentsByType(type);
    if (docs.isEmpty) return null;

    docs.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return docs.first;
  }

  // Simulate admin approval (for demo purposes)
  static Future<void> simulateAdminReview(String documentId) async {
    await Future.delayed(const Duration(seconds: 2));

    // Randomly approve or reject for demo
    final isApproved = DateTime.now().millisecond % 2 == 0;

    if (isApproved) {
      await updateDocumentStatus(documentId, DocumentStatus.approved);
    } else {
      await updateDocumentStatus(
        documentId,
        DocumentStatus.rejected,
        rejectionReason:
            'Document quality is not clear enough. Please upload a clearer image.',
      );
    }
  }

  // Get document statistics
  static Map<String, int> getDocumentStats() {
    return {
      'total': _documents.length,
      'pending': getPendingDocuments().length,
      'approved': getApprovedDocuments().length,
      'rejected': getDocumentsByStatus(DocumentStatus.rejected).length,
      'expiring': getExpiringDocuments().length,
    };
  }

  // Clear all documents (for testing)
  static Future<void> clearAllDocuments() async {
    // Delete all files
    for (final doc in _documents) {
      try {
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Continue even if file deletion fails
      }
    }

    _documents.clear();
    await _saveDocuments();
  }

  // Send medical report from approved provider to patient
  static Future<bool> sendMedicalReportFromProvider({
    required String providerName,
    required String providerId,
    required String patientId,
    required String reportName,
    required DocumentType reportType,
    required String filePath,
    String? notes,
    bool isProviderApproved = true,
  }) async {
    // Only approved providers can send reports
    if (!isProviderApproved) {
      return false;
    }

    try {
      // Create the document with APPROVED status (auto-approved from verified providers)
      final document = Document(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        name: reportName,
        type: reportType,
        filePath: filePath,
        fileName: filePath.split('/').last,
        fileExtension: filePath.split('.').last,
        fileSizeBytes: 0,
        uploadedAt: DateTime.now(),
        status:
            DocumentStatus.approved, // Auto-approved from verified providers
        notes: notes,
      );

      // Add to documents
      _documents.add(document);
      await _saveDocuments();

      // Send inbox notification to patient
      await _sendProviderReportNotification(
        providerName: providerName,
        document: document,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // Send notification when provider sends a report
  static Future<void> _sendProviderReportNotification({
    required String providerName,
    required Document document,
  }) async {
    final messageType = _getMessageTypeForDocument(document.type);
    final content = _getProviderNotificationContent(providerName, document);

    await MessageService.createMedicalRecordNotification(
      providerName: providerName,
      recordType: messageType,
      content: content,
      documentId: document.id,
    );
  }

  // Get notification content for provider-sent reports
  static String _getProviderNotificationContent(
    String providerName,
    Document document,
  ) {
    switch (document.type) {
      case DocumentType.prescription:
        return '$providerName has sent you a new prescription. Tap to view in Medical Records.';
      case DocumentType.labResults:
      case DocumentType.bloodTestReport:
      case DocumentType.urineTestReport:
      case DocumentType.biopsyReport:
      case DocumentType.pathologyReport:
        return '$providerName has shared your lab test results. Tap to view in Medical Records.';
      case DocumentType.xrayReport:
      case DocumentType.ctScanReport:
      case DocumentType.mriReport:
      case DocumentType.ultrasoundReport:
        return '$providerName has uploaded your imaging report. Tap to view in Medical Records.';
      case DocumentType.medicalReport:
        return '$providerName has shared your medical report. Tap to view in Medical Records.';
      case DocumentType.dischargeSummary:
        return '$providerName has sent your discharge summary. Tap to view in Medical Records.';
      case DocumentType.vaccinationRecord:
        return '$providerName has updated your vaccination record. Tap to view in Medical Records.';
      case DocumentType.ecgReport:
        return '$providerName has shared your ECG report. Tap to view in Medical Records.';
      case DocumentType.nutritionPlan:
        return '$providerName has created a nutrition plan for you. Tap to view in Medical Records.';
      case DocumentType.physiotherapyReport:
        return '$providerName has shared your physiotherapy report. Tap to view in Medical Records.';
      case DocumentType.dentalReport:
        return '$providerName has sent your dental report. Tap to view in Medical Records.';
      case DocumentType.eyeExamReport:
        return '$providerName has shared your eye examination report. Tap to view in Medical Records.';
      default:
        return '$providerName has sent you a new medical document. Tap to view in Medical Records.';
    }
  }

  // Demo: Simulate provider sending a report (for testing)
  static Future<void> simulateProviderSendingReport({
    required String providerName,
    required String reportName,
    required DocumentType reportType,
    String? notes,
  }) async {
    await sendMedicalReportFromProvider(
      providerName: providerName,
      providerId: 'provider_${DateTime.now().millisecondsSinceEpoch}',
      patientId: 'current_patient',
      reportName: reportName,
      reportType: reportType,
      filePath: 'sample/${reportName.toLowerCase().replaceAll(' ', '_')}.pdf',
      notes: notes,
      isProviderApproved: true,
    );
  }
}

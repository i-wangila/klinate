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

    // Add sample medical records if none exist
    if (_documents.isEmpty) {
      await _addSampleMedicalRecords();
    }

    _isInitialized = true;
  }

  // Add sample medical records for demonstration
  static Future<void> _addSampleMedicalRecords() async {
    final now = DateTime.now();

    // Sample Prescriptions
    final prescriptions = [
      Document(
        id: 'doc_prescription_1',
        name: 'Prescription #88065',
        type: DocumentType.prescription,
        filePath: 'sample/prescription_1.pdf',
        fileName: 'prescription_88065.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 245000,
        uploadedAt: now.subtract(const Duration(days: 2)),
        status: DocumentStatus.approved,
        notes:
            'Prescribed by: Dr. James Kiprotich\nDate: Nov 01, 2025\nPharmacy: Haltons Pharmacy - CBD\n\nMedications:\n• Lisinopril 10mg - 30 tablets',
      ),
      Document(
        id: 'doc_prescription_2',
        name: 'Prescription #88064',
        type: DocumentType.prescription,
        filePath: 'sample/prescription_2.pdf',
        fileName: 'prescription_88064.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 238000,
        uploadedAt: now.subtract(const Duration(days: 15)),
        status: DocumentStatus.approved,
        notes:
            'Prescribed by: Dr. Grace Wanjiku\nDate: Oct 16, 2025\nPharmacy: Mediplus Pharmacy\n\nMedications:\n• Metformin 500mg - 60 tablets\n• Aspirin 75mg - 30 tablets',
      ),
      Document(
        id: 'doc_prescription_3',
        name: 'Prescription #88063',
        type: DocumentType.prescription,
        filePath: 'sample/prescription_3.pdf',
        fileName: 'prescription_88063.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 252000,
        uploadedAt: now.subtract(const Duration(days: 30)),
        status: DocumentStatus.approved,
        notes:
            'Prescribed by: Dr. Sarah Mwangi\nDate: Oct 01, 2025\nPharmacy: City Pharmacy\n\nMedications:\n• Amoxicillin 500mg - 21 tablets\n• Paracetamol 500mg - 10 tablets',
      ),
    ];

    // Sample Lab Results
    final labResults = [
      Document(
        id: 'doc_lab_1',
        name: 'Complete Blood Count (CBC)',
        type: DocumentType.bloodTestReport,
        filePath: 'sample/lab_cbc.pdf',
        fileName: 'cbc_report.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 312000,
        uploadedAt: now.subtract(const Duration(days: 5)),
        status: DocumentStatus.approved,
        notes:
            'Lab: Nairobi Diagnostics Center\nTest Date: ${_formatDate(now.subtract(const Duration(days: 5)))}\nDoctor: Dr. Peter Omondi\n\nResults:\n• All values within normal range\n• Hemoglobin: 14.2 g/dL\n• White Blood Cells: 7,500/μL',
      ),
      Document(
        id: 'doc_lab_2',
        name: 'Lipid Profile Test',
        type: DocumentType.bloodTestReport,
        filePath: 'sample/lab_lipid.pdf',
        fileName: 'lipid_profile.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 298000,
        uploadedAt: now.subtract(const Duration(days: 12)),
        status: DocumentStatus.approved,
        notes:
            'Lab: Lancet Kenya\nTest Date: ${_formatDate(now.subtract(const Duration(days: 12)))}\nDoctor: Dr. Mary Njeri\n\nResults:\n• Total Cholesterol: 180 mg/dL\n• HDL: 55 mg/dL\n• LDL: 110 mg/dL',
      ),
      Document(
        id: 'doc_lab_3',
        name: 'Urine Analysis',
        type: DocumentType.urineTestReport,
        filePath: 'sample/lab_urine.pdf',
        fileName: 'urine_analysis.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 275000,
        uploadedAt: now.subtract(const Duration(days: 20)),
        status: DocumentStatus.approved,
        notes:
            'Lab: Pathcare Kenya\nTest Date: ${_formatDate(now.subtract(const Duration(days: 20)))}\nResults: Normal findings',
      ),
    ];

    // Sample Imaging Reports
    final imagingReports = [
      Document(
        id: 'doc_xray_1',
        name: 'Chest X-Ray Report',
        type: DocumentType.xrayReport,
        filePath: 'sample/xray_chest.pdf',
        fileName: 'chest_xray.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 1250000,
        uploadedAt: now.subtract(const Duration(days: 7)),
        status: DocumentStatus.approved,
        notes:
            'Facility: Nairobi Radiology Center\nExam Date: ${_formatDate(now.subtract(const Duration(days: 7)))}\nFindings: Clear lung fields, normal cardiac silhouette',
      ),
      Document(
        id: 'doc_ultrasound_1',
        name: 'Abdominal Ultrasound',
        type: DocumentType.ultrasoundReport,
        filePath: 'sample/ultrasound_abdomen.pdf',
        fileName: 'abdominal_ultrasound.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 1580000,
        uploadedAt: now.subtract(const Duration(days: 25)),
        status: DocumentStatus.approved,
        notes:
            'Facility: Aga Khan Imaging\nExam Date: ${_formatDate(now.subtract(const Duration(days: 25)))}\nFindings: Normal liver, kidneys, and spleen',
      ),
      Document(
        id: 'doc_mri_1',
        name: 'Brain MRI Scan',
        type: DocumentType.mriReport,
        filePath: 'sample/mri_brain.pdf',
        fileName: 'brain_mri.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 2150000,
        uploadedAt: now.subtract(const Duration(days: 45)),
        status: DocumentStatus.approved,
        notes:
            'Facility: Nairobi Hospital Imaging\nExam Date: ${_formatDate(now.subtract(const Duration(days: 45)))}\nFindings: No abnormalities detected',
      ),
    ];

    // Sample Medical Reports
    final medicalReports = [
      Document(
        id: 'doc_report_1',
        name: 'Annual Physical Examination',
        type: DocumentType.medicalReport,
        filePath: 'sample/physical_exam.pdf',
        fileName: 'annual_physical.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 425000,
        uploadedAt: now.subtract(const Duration(days: 10)),
        status: DocumentStatus.approved,
        notes:
            'Provider: Dr. John Kamau\nDate: ${_formatDate(now.subtract(const Duration(days: 10)))}\nSummary: Overall good health, blood pressure normal, weight stable',
      ),
      Document(
        id: 'doc_report_2',
        name: 'Cardiology Consultation Report',
        type: DocumentType.medicalReport,
        filePath: 'sample/cardiology_report.pdf',
        fileName: 'cardiology_consultation.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 385000,
        uploadedAt: now.subtract(const Duration(days: 35)),
        status: DocumentStatus.approved,
        notes:
            'Cardiologist: Dr. Mary Njeri\nDate: ${_formatDate(now.subtract(const Duration(days: 35)))}\nDiagnosis: Mild hypertension, lifestyle modifications recommended',
      ),
      Document(
        id: 'doc_ecg_1',
        name: 'ECG Report',
        type: DocumentType.ecgReport,
        filePath: 'sample/ecg_report.pdf',
        fileName: 'ecg_test.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 295000,
        uploadedAt: now.subtract(const Duration(days: 35)),
        status: DocumentStatus.approved,
        notes:
            'Facility: Heart Care Clinic\nTest Date: ${_formatDate(now.subtract(const Duration(days: 35)))}\nResults: Normal sinus rhythm',
      ),
    ];

    // Sample Other Records
    final otherRecords = [
      Document(
        id: 'doc_vaccine_1',
        name: 'COVID-19 Vaccination Record',
        type: DocumentType.vaccinationRecord,
        filePath: 'sample/covid_vaccine.pdf',
        fileName: 'covid_vaccination.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 185000,
        uploadedAt: now.subtract(const Duration(days: 180)),
        status: DocumentStatus.approved,
        notes:
            'Vaccine: Pfizer-BioNTech\nDose: Booster (3rd dose)\nDate: ${_formatDate(now.subtract(const Duration(days: 180)))}\nLocation: Nairobi Health Center',
      ),
      Document(
        id: 'doc_discharge_1',
        name: 'Hospital Discharge Summary',
        type: DocumentType.dischargeSummary,
        filePath: 'sample/discharge_summary.pdf',
        fileName: 'discharge_summary.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 445000,
        uploadedAt: now.subtract(const Duration(days: 90)),
        status: DocumentStatus.approved,
        notes:
            'Hospital: Kenyatta National Hospital\nAdmission: ${_formatDate(now.subtract(const Duration(days: 93)))}\nDischarge: ${_formatDate(now.subtract(const Duration(days: 90)))}\nReason: Minor surgery - successful recovery',
      ),
      Document(
        id: 'doc_nutrition_1',
        name: 'Nutrition Plan',
        type: DocumentType.nutritionPlan,
        filePath: 'sample/nutrition_plan.pdf',
        fileName: 'nutrition_plan.pdf',
        fileExtension: 'pdf',
        fileSizeBytes: 325000,
        uploadedAt: now.subtract(const Duration(days: 14)),
        status: DocumentStatus.approved,
        notes:
            'Nutritionist: Jane Wambui\nDate: ${_formatDate(now.subtract(const Duration(days: 14)))}\nPlan: Balanced diet for weight management and cholesterol control',
      ),
    ];

    // Add all sample documents
    _documents.addAll(prescriptions);
    _documents.addAll(labResults);
    _documents.addAll(imagingReports);
    _documents.addAll(medicalReports);
    _documents.addAll(otherRecords);

    await _saveDocuments();

    // Send notifications for recent documents (simulating provider-sent reports)
    await _sendProviderReportNotification(
      providerName: 'Dr. James Kiprotich',
      document: prescriptions[0],
    );
    await _sendProviderReportNotification(
      providerName: 'Nairobi Diagnostics Center',
      document: labResults[0],
    );
    await _sendProviderReportNotification(
      providerName: 'Nairobi Radiology Center',
      document: imagingReports[0],
    );
  }

  static String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
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

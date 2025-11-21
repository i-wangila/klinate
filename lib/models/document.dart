enum DocumentType {
  // Patient medical records (from healthcare providers)
  labResults,
  prescription,
  medicalReport,
  xrayReport,
  dischargeSummary,
  vaccinationRecord,
  ctScanReport,
  mriReport,
  ultrasoundReport,
  ecgReport,
  nutritionPlan,
  physiotherapyReport,
  dentalReport,
  eyeExamReport,
  bloodTestReport,
  urineTestReport,
  biopsyReport,
  pathologyReport,

  // Business account verification documents (for business account registration)
  medicalLicense,
  professionalCertification,
  validId,
  insurance,
  nursingLicense,
  professionalLicense,
  certification,
  nutritionCertification,
  caregiverCertification,
  backgroundCheck,
  hospitalLicense,
  accreditation,
  businessRegistration,
  clinicLicense,
  medicalPermits,
  pharmacyLicense,
  pharmacistLicense,
  laboratoryLicense,
  qualityCertification,
  dentalLicense,
  practiceLicense,
  businessLicense,
  healthPermits,

  other,
}

enum DocumentStatus { pending, approved, rejected, expired }

class Document {
  final String id;
  final String name;
  final DocumentType type;
  final String filePath;
  final String fileName;
  final String fileExtension;
  final int fileSizeBytes;
  final DateTime uploadedAt;
  final DateTime? expiryDate;
  final DocumentStatus status;
  final String? rejectionReason;
  final String? notes;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.filePath,
    required this.fileName,
    required this.fileExtension,
    required this.fileSizeBytes,
    required this.uploadedAt,
    this.expiryDate,
    this.status = DocumentStatus.pending,
    this.rejectionReason,
    this.notes,
  });

  // Helper methods
  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension.toLowerCase());
  bool get isPdf => fileExtension.toLowerCase() == 'pdf';
  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get needsRenewal =>
      expiryDate != null &&
      DateTime.now().add(const Duration(days: 30)).isAfter(expiryDate!);

  String get statusText {
    switch (status) {
      case DocumentStatus.pending:
        return 'Pending Review';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.expired:
        return 'Expired';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case DocumentType.labResults:
        return 'Lab Results';
      case DocumentType.prescription:
        return 'Prescription';
      case DocumentType.medicalReport:
        return 'Medical Report';
      case DocumentType.xrayReport:
        return 'X-ray/Imaging Report';
      case DocumentType.dischargeSummary:
        return 'Discharge Summary';
      case DocumentType.vaccinationRecord:
        return 'Vaccination Record';
      case DocumentType.ctScanReport:
        return 'CT Scan Report';
      case DocumentType.mriReport:
        return 'MRI Report';
      case DocumentType.ultrasoundReport:
        return 'Ultrasound Report';
      case DocumentType.ecgReport:
        return 'ECG/EKG Report';
      case DocumentType.nutritionPlan:
        return 'Nutrition Plan';
      case DocumentType.physiotherapyReport:
        return 'Physiotherapy Report';
      case DocumentType.dentalReport:
        return 'Dental Report';
      case DocumentType.eyeExamReport:
        return 'Eye Examination Report';
      case DocumentType.bloodTestReport:
        return 'Blood Test Report';
      case DocumentType.urineTestReport:
        return 'Urine Test Report';
      case DocumentType.biopsyReport:
        return 'Biopsy Report';
      case DocumentType.pathologyReport:
        return 'Pathology Report';
      case DocumentType.medicalLicense:
        return 'Medical License';
      case DocumentType.professionalCertification:
        return 'Professional Certification';
      case DocumentType.validId:
        return 'Valid ID';
      case DocumentType.insurance:
        return 'Insurance Certificate';
      case DocumentType.nursingLicense:
        return 'Nursing License';
      case DocumentType.professionalLicense:
        return 'Professional License';
      case DocumentType.certification:
        return 'Certification';
      case DocumentType.nutritionCertification:
        return 'Nutrition Certification';
      case DocumentType.caregiverCertification:
        return 'Caregiver Certification';
      case DocumentType.backgroundCheck:
        return 'Background Check';
      case DocumentType.hospitalLicense:
        return 'Hospital License';
      case DocumentType.accreditation:
        return 'Accreditation';
      case DocumentType.businessRegistration:
        return 'Business Registration';
      case DocumentType.clinicLicense:
        return 'Clinic License';
      case DocumentType.medicalPermits:
        return 'Medical Permits';
      case DocumentType.pharmacyLicense:
        return 'Pharmacy License';
      case DocumentType.pharmacistLicense:
        return 'Pharmacist License';
      case DocumentType.laboratoryLicense:
        return 'Laboratory License';
      case DocumentType.qualityCertification:
        return 'Quality Certification';
      case DocumentType.dentalLicense:
        return 'Dental License';
      case DocumentType.practiceLicense:
        return 'Practice License';
      case DocumentType.businessLicense:
        return 'Business License';
      case DocumentType.healthPermits:
        return 'Health Permits';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'filePath': filePath,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'fileSizeBytes': fileSizeBytes,
      'uploadedAt': uploadedAt.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'status': status.toString(),
      'rejectionReason': rejectionReason,
      'notes': notes,
    };
  }

  // Create from JSON
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      type: DocumentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => DocumentType.other,
      ),
      filePath: json['filePath'],
      fileName: json['fileName'],
      fileExtension: json['fileExtension'],
      fileSizeBytes: json['fileSizeBytes'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => DocumentStatus.pending,
      ),
      rejectionReason: json['rejectionReason'],
      notes: json['notes'],
    );
  }

  // Copy with method for updates
  Document copyWith({
    String? id,
    String? name,
    DocumentType? type,
    String? filePath,
    String? fileName,
    String? fileExtension,
    int? fileSizeBytes,
    DateTime? uploadedAt,
    DateTime? expiryDate,
    DocumentStatus? status,
    String? rejectionReason,
    String? notes,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
    );
  }
}

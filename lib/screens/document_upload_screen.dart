import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document.dart';
import '../services/document_service.dart';

class DocumentUploadScreen extends StatefulWidget {
  final DocumentType documentType;
  final String? documentId; // For updating existing documents

  const DocumentUploadScreen({
    super.key,
    required this.documentType,
    this.documentId,
  });

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedFilePath;
  String? _selectedFileName;
  DateTime? _expiryDate;
  bool _isLoading = false;
  bool _hasExpiryDate = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.documentId != null) {
      // Load existing document for editing
      final document = DocumentService.getDocumentById(widget.documentId!);
      if (document != null) {
        _nameController.text = document.name;
        _notesController.text = document.notes ?? '';
        _selectedFilePath = document.filePath;
        _selectedFileName = document.fileName;
        _expiryDate = document.expiryDate;
        _hasExpiryDate = document.expiryDate != null;
      }
    } else {
      // Set default name based on document type
      _nameController.text = widget.documentType.typeDisplayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.documentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Update Document' : 'Upload Document'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocumentTypeHeader(),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildFileUploadSection(),
              const SizedBox(height: 16),
              _buildExpiryDateSection(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTypeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(_getDocumentIcon(), color: Colors.blue[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.documentType.typeDisplayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDocumentDescription(),
                  style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Document Name',
        hintText: 'Enter a name for this document',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.label),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a document name';
        }
        return null;
      },
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload File',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (_selectedFilePath != null) ...[
          _buildSelectedFilePreview(),
          const SizedBox(height: 16),
        ],
        _buildFileUploadOptions(),
      ],
    );
  }

  Widget _buildSelectedFilePreview() {
    final file = File(_selectedFilePath!);
    final isImage =
        _selectedFileName!.toLowerCase().endsWith('.jpg') ||
        _selectedFileName!.toLowerCase().endsWith('.jpeg') ||
        _selectedFileName!.toLowerCase().endsWith('.png');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            _selectedFilePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, size: 30);
                            },
                          )
                        : Image.file(
                            file,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, size: 30);
                            },
                          ),
                  )
                : const Icon(Icons.picture_as_pdf, size: 30, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFileName!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getFileSize(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedFilePath = null;
                _selectedFileName = null;
              });
            },
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildUploadOption(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: _pickImageFromCamera,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildUploadOption(
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: _pickImageFromGallery,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildUploadOption(
            icon: Icons.picture_as_pdf,
            label: 'PDF File',
            onTap: _pickPdfFile,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('This document has an expiry date'),
          value: _hasExpiryDate,
          onChanged: (value) {
            setState(() {
              _hasExpiryDate = value ?? false;
              if (!_hasExpiryDate) {
                _expiryDate = null;
              }
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        if (_hasExpiryDate) ...[
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Expiry Date',
              hintText: 'Select expiry date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: _expiryDate != null
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _expiryDate = null;
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            controller: TextEditingController(
              text: _expiryDate != null
                  ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                  : '',
            ),
            onTap: _selectExpiryDate,
            validator: _hasExpiryDate
                ? (value) {
                    if (_expiryDate == null) {
                      return 'Please select an expiry date';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional notes about this document',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.note),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading || _selectedFilePath == null
            ? null
            : _submitDocument,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(
                widget.documentId != null
                    ? 'Update Document'
                    : 'Upload Document',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFilePath = image.path;
          _selectedFileName = image.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image from camera');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (kIsWeb) {
            // For web, use the path directly (it's a blob URL)
            _selectedFilePath = image.path;
          } else {
            // For mobile, use the file path
            _selectedFilePath = image.path;
          }
          _selectedFileName = image.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery: ${e.toString()}');
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: kIsWeb, // For web, we need the bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          if (kIsWeb) {
            // For web, we'll use the bytes later
            _selectedFilePath = file.name; // Store name temporarily
          } else {
            _selectedFilePath = file.path;
          }
          _selectedFileName = file.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick PDF file: ${e.toString()}');
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _submitDocument() async {
    if (!_formKey.currentState!.validate() || _selectedFilePath == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;

      if (widget.documentId != null) {
        // Update existing document
        success = await DocumentService.replaceDocument(
          documentId: widget.documentId!,
          filePath: _selectedFilePath!,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          expiryDate: _expiryDate,
        );
      } else {
        // Upload new document
        success = await DocumentService.uploadDocument(
          name: _nameController.text.trim(),
          type: widget.documentType,
          filePath: _selectedFilePath!,
          expiryDate: _expiryDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.documentId != null
                  ? 'Document updated successfully'
                  : 'Document uploaded successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        _showErrorSnackBar(
          widget.documentId != null
              ? 'Failed to update document'
              : 'Failed to upload document',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _getFileSize() {
    if (_selectedFilePath == null) return '';

    try {
      final file = File(_selectedFilePath!);
      final bytes = file.lengthSync();

      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return '';
    }
  }

  IconData _getDocumentIcon() {
    switch (widget.documentType) {
      case DocumentType.labResults:
      case DocumentType.bloodTestReport:
      case DocumentType.urineTestReport:
        return Icons.science;
      case DocumentType.prescription:
        return Icons.medication;
      case DocumentType.medicalReport:
      case DocumentType.pathologyReport:
      case DocumentType.biopsyReport:
        return Icons.description;
      case DocumentType.xrayReport:
      case DocumentType.ctScanReport:
      case DocumentType.mriReport:
      case DocumentType.ultrasoundReport:
        return Icons.medical_information;
      case DocumentType.dischargeSummary:
        return Icons.local_hospital;
      case DocumentType.vaccinationRecord:
        return Icons.vaccines;
      case DocumentType.ecgReport:
        return Icons.monitor_heart;
      case DocumentType.nutritionPlan:
        return Icons.restaurant_menu;
      case DocumentType.physiotherapyReport:
        return Icons.accessibility_new;
      case DocumentType.dentalReport:
        return Icons.medical_services;
      case DocumentType.eyeExamReport:
        return Icons.visibility;
      case DocumentType.medicalLicense:
      case DocumentType.nursingLicense:
      case DocumentType.professionalLicense:
      case DocumentType.hospitalLicense:
      case DocumentType.clinicLicense:
      case DocumentType.pharmacyLicense:
      case DocumentType.pharmacistLicense:
      case DocumentType.laboratoryLicense:
      case DocumentType.dentalLicense:
      case DocumentType.practiceLicense:
      case DocumentType.businessLicense:
        return Icons.medical_services;
      case DocumentType.professionalCertification:
      case DocumentType.certification:
      case DocumentType.nutritionCertification:
      case DocumentType.caregiverCertification:
      case DocumentType.accreditation:
      case DocumentType.qualityCertification:
        return Icons.verified;
      case DocumentType.validId:
        return Icons.badge;
      case DocumentType.insurance:
        return Icons.security;
      case DocumentType.backgroundCheck:
        return Icons.verified_user;
      case DocumentType.businessRegistration:
        return Icons.business;
      case DocumentType.medicalPermits:
      case DocumentType.healthPermits:
        return Icons.assignment;
      case DocumentType.other:
        return Icons.description;
    }
  }

  String _getDocumentDescription() {
    switch (widget.documentType) {
      case DocumentType.labResults:
        return 'Laboratory test results';
      case DocumentType.bloodTestReport:
        return 'Blood test results';
      case DocumentType.urineTestReport:
        return 'Urine test results';
      case DocumentType.biopsyReport:
        return 'Biopsy examination results';
      case DocumentType.pathologyReport:
        return 'Pathology examination results';
      case DocumentType.prescription:
        return 'Medication prescriptions';
      case DocumentType.medicalReport:
        return 'Medical examination reports';
      case DocumentType.xrayReport:
        return 'X-ray imaging reports';
      case DocumentType.ctScanReport:
        return 'CT scan imaging reports';
      case DocumentType.mriReport:
        return 'MRI imaging reports';
      case DocumentType.ultrasoundReport:
        return 'Ultrasound imaging reports';
      case DocumentType.ecgReport:
        return 'ECG/EKG test results';
      case DocumentType.dischargeSummary:
        return 'Hospital discharge summaries';
      case DocumentType.vaccinationRecord:
        return 'Vaccination certificates';
      case DocumentType.nutritionPlan:
        return 'Nutrition and diet plans';
      case DocumentType.physiotherapyReport:
        return 'Physiotherapy session reports';
      case DocumentType.dentalReport:
        return 'Dental examination reports';
      case DocumentType.eyeExamReport:
        return 'Eye examination reports';
      case DocumentType.medicalLicense:
        return 'Upload your medical license for verification';
      case DocumentType.nursingLicense:
        return 'Upload your nursing license for verification';
      case DocumentType.professionalLicense:
        return 'Upload your professional license for verification';
      case DocumentType.professionalCertification:
        return 'Upload professional certifications';
      case DocumentType.certification:
        return 'Upload relevant certifications';
      case DocumentType.nutritionCertification:
        return 'Upload your nutrition certification';
      case DocumentType.caregiverCertification:
        return 'Upload your caregiver certification';
      case DocumentType.backgroundCheck:
        return 'Upload background check document';
      case DocumentType.validId:
        return 'Upload a valid government-issued ID';
      case DocumentType.insurance:
        return 'Upload insurance certificate';
      case DocumentType.hospitalLicense:
        return 'Upload hospital operating license';
      case DocumentType.accreditation:
        return 'Upload accreditation certificate';
      case DocumentType.businessRegistration:
        return 'Upload business registration documents';
      case DocumentType.clinicLicense:
        return 'Upload clinic operating license';
      case DocumentType.medicalPermits:
        return 'Upload medical permits';
      case DocumentType.pharmacyLicense:
        return 'Upload pharmacy license';
      case DocumentType.pharmacistLicense:
        return 'Upload pharmacist license';
      case DocumentType.laboratoryLicense:
        return 'Upload laboratory license';
      case DocumentType.qualityCertification:
        return 'Upload quality certification';
      case DocumentType.dentalLicense:
        return 'Upload dental practice license';
      case DocumentType.practiceLicense:
        return 'Upload practice license';
      case DocumentType.businessLicense:
        return 'Upload business license';
      case DocumentType.healthPermits:
        return 'Upload health permits';
      case DocumentType.other:
        return 'Other documents';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

extension on DocumentType {
  String get typeDisplayName {
    switch (this) {
      case DocumentType.labResults:
        return 'Lab Results';
      case DocumentType.bloodTestReport:
        return 'Blood Test Report';
      case DocumentType.urineTestReport:
        return 'Urine Test Report';
      case DocumentType.biopsyReport:
        return 'Biopsy Report';
      case DocumentType.pathologyReport:
        return 'Pathology Report';
      case DocumentType.prescription:
        return 'Prescription';
      case DocumentType.medicalReport:
        return 'Medical Report';
      case DocumentType.xrayReport:
        return 'X-ray Report';
      case DocumentType.ctScanReport:
        return 'CT Scan Report';
      case DocumentType.mriReport:
        return 'MRI Report';
      case DocumentType.ultrasoundReport:
        return 'Ultrasound Report';
      case DocumentType.ecgReport:
        return 'ECG/EKG Report';
      case DocumentType.dischargeSummary:
        return 'Discharge Summary';
      case DocumentType.vaccinationRecord:
        return 'Vaccination Record';
      case DocumentType.nutritionPlan:
        return 'Nutrition Plan';
      case DocumentType.physiotherapyReport:
        return 'Physiotherapy Report';
      case DocumentType.dentalReport:
        return 'Dental Report';
      case DocumentType.eyeExamReport:
        return 'Eye Examination Report';
      case DocumentType.medicalLicense:
        return 'Medical License';
      case DocumentType.nursingLicense:
        return 'Nursing License';
      case DocumentType.professionalLicense:
        return 'Professional License';
      case DocumentType.professionalCertification:
        return 'Professional Certification';
      case DocumentType.certification:
        return 'Certification';
      case DocumentType.nutritionCertification:
        return 'Nutrition Certification';
      case DocumentType.caregiverCertification:
        return 'Caregiver Certification';
      case DocumentType.backgroundCheck:
        return 'Background Check';
      case DocumentType.validId:
        return 'Valid ID';
      case DocumentType.insurance:
        return 'Insurance Certificate';
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
}

import 'package:flutter/material.dart';
import '../models/provider_type.dart';
import '../models/document.dart';
import '../models/user_profile.dart';
import '../models/provider_profile.dart';
import '../models/academic_qualification.dart';
import '../models/work_experience.dart';
import '../services/healthcare_provider_service.dart';
import '../services/document_service.dart';
import '../services/user_service.dart';
import '../services/provider_service.dart';
import '../services/message_service.dart';
import '../models/message.dart';
import 'document_upload_screen.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  final ProviderType providerType;

  const ProviderRegistrationScreen({super.key, required this.providerType});

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends State<ProviderRegistrationScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 8;
  bool _isLoading = false;

  // Form controllers
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _aboutFormKey = GlobalKey<FormState>();
  final _experienceFormKey = GlobalKey<FormState>();
  final _educationFormKey = GlobalKey<FormState>();
  final _certificationsFormKey = GlobalKey<FormState>();
  final _servicesFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

  // Step 1: Basic Information (Name, Title, Location)
  final _nameController = TextEditingController();
  final _headlineController = TextEditingController(); // Professional headline
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  // Step 2: About (Professional Summary)
  final _bioController = TextEditingController();

  // Step 3: Experience (Work History)
  final _jobTitleController = TextEditingController();
  final _organizationController = TextEditingController();
  final _locationController = TextEditingController();
  final _startMonthController = TextEditingController();
  final _startYearController = TextEditingController();
  final _endMonthController = TextEditingController();
  final _endYearController = TextEditingController();
  final _experienceDescriptionController = TextEditingController();
  bool _isCurrentPosition = false;
  final List<WorkExperience> _workExperiences = [];

  // Step 4: Education (Academic Qualifications)
  String _selectedTitle = 'Dr.';
  String _selectedEducationLevel = 'Bachelor\'s Degree';
  String _selectedSpecialization = 'General Practitioner';
  final _institutionController = TextEditingController();
  final _yearCompletedController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final List<AcademicQualification> _academicQualifications = [];

  // Step 5: Licenses & Certifications
  final _certificationNameController = TextEditingController();
  final _certificationIssuerController = TextEditingController();
  final _certificationYearController = TextEditingController();
  final List<Map<String, String>> _certifications = [];

  // Step 6: Services & Skills
  final _servicesDescriptionController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final List<String> _selectedServices = [];
  final List<String> _selectedLanguages = [];
  final List<String> _selectedInsurance = [];
  final List<String> _selectedPaymentMethods = [];
  final List<String> _workingDays = [];
  final Map<String, Map<String, String>> _workingHours = {};

  // Step 7: Contact Information
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _physicalAddressController = TextEditingController();
  final _poBoxController = TextEditingController();

  // Payment details
  final _mpesaPaybillController = TextEditingController();
  final _mpesaAccountController = TextEditingController();
  final _mpesaTillController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();

  // Step 8: Documents
  final List<Document> _uploadedDocuments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDocumentService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload documents when app resumes
      _loadUploadedDocuments();
    }
  }

  Future<void> _initializeDocumentService() async {
    await DocumentService.initialize();
    await _loadUploadedDocuments();
  }

  Future<void> _loadUploadedDocuments() async {
    final documents = DocumentService.getAllDocuments();
    if (mounted) {
      setState(() {
        _uploadedDocuments.clear();
        _uploadedDocuments.addAll(documents);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Register as ${widget.providerType.name}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildAboutStep(),
                _buildExperienceStep(),
                _buildEducationStep(),
                _buildCertificationsStep(),
                _buildServicesStep(),
                _buildContactStep(),
                _buildDocumentsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < _totalSteps - 1 ? 8 : 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isCompleted || isCurrent
                                ? Colors.black
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _basicInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s start with your basic details',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Dr. John Doe',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _headlineController,
              label: 'Professional Headline',
              hint: 'e.g., Specialist in Cardiology at City Hospital',
              icon: Icons.work_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your professional headline';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _cityController,
              label: 'City',
              hint: 'Nairobi',
              icon: Icons.location_city,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _countryController,
              label: 'Country',
              hint: 'Kenya',
              icon: Icons.public,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your country';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _aboutFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Write a professional summary about yourself',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _bioController,
              label: 'Professional Summary',
              hint:
                  'Dedicated healthcare professional committed to providing quality care...',
              icon: Icons.description,
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your professional summary';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _experienceFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Experience',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your work experience',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _jobTitleController,
              label: 'Job Title',
              hint: 'e.g., Senior Consultant - Cardiology',
              icon: Icons.work,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _organizationController,
              label: 'Organization',
              hint: 'e.g., City Hospital',
              icon: Icons.business,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _locationController,
              label: 'Location (Optional)',
              hint: 'e.g., Nairobi, Kenya',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _startMonthController,
                    label: 'Start Month',
                    hint: 'MM',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _startYearController,
                    label: 'Start Year',
                    hint: 'YYYY',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('I currently work here'),
              value: _isCurrentPosition,
              onChanged: (value) {
                setState(() {
                  _isCurrentPosition = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isCurrentPosition) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _endMonthController,
                      label: 'End Month',
                      hint: 'MM',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _endYearController,
                      label: 'End Year',
                      hint: 'YYYY',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            _buildTextField(
              controller: _experienceDescriptionController,
              label: 'Description (Optional)',
              hint: 'Describe your responsibilities and achievements...',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addExperience,
                icon: const Icon(Icons.add),
                label: const Text('Add Experience'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  side: const BorderSide(color: Colors.black, width: 1),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            if (_workExperiences.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Added Experience',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._workExperiences.map((exp) => _buildExperienceCard(exp)),
            ],
          ],
        ),
      ),
    );
  }

  void _addExperience() {
    if (_jobTitleController.text.trim().isEmpty ||
        _organizationController.text.trim().isEmpty) {
      _showSnackBar('Please enter job title and organization');
      return;
    }

    try {
      final startMonth = int.parse(_startMonthController.text.trim());
      final startYear = int.parse(_startYearController.text.trim());

      DateTime? endDate;
      if (!_isCurrentPosition) {
        final endMonth = int.parse(_endMonthController.text.trim());
        final endYear = int.parse(_endYearController.text.trim());
        endDate = DateTime(endYear, endMonth);
      }

      final experience = WorkExperience(
        jobTitle: _jobTitleController.text.trim(),
        organization: _organizationController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        startDate: DateTime(startYear, startMonth),
        endDate: endDate,
        description: _experienceDescriptionController.text.trim().isEmpty
            ? null
            : _experienceDescriptionController.text.trim(),
        isCurrentPosition: _isCurrentPosition,
      );

      setState(() {
        _workExperiences.add(experience);
        _jobTitleController.clear();
        _organizationController.clear();
        _locationController.clear();
        _startMonthController.clear();
        _startYearController.clear();
        _endMonthController.clear();
        _endYearController.clear();
        _experienceDescriptionController.clear();
        _isCurrentPosition = false;
      });

      _showSnackBar('Experience added successfully');
    } catch (e) {
      _showSnackBar('Please enter valid dates');
    }
  }

  Widget _buildExperienceCard(WorkExperience exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.work, color: Colors.blue[600], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.jobTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exp.organization,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 2),
                Text(
                  exp.duration,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _workExperiences.remove(exp);
              });
              _showSnackBar('Experience removed');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEducationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _educationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Qualifications',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about your academic background and achievements',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildDropdownField(
              label: 'Professional Title',
              value: _selectedTitle,
              items: ['Dr.', 'Prof.', 'Mr.', 'Mrs.', 'Ms.', 'N/A'],
              onChanged: (value) {
                setState(() {
                  _selectedTitle = value!;
                });
              },
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Education Level',
              value: _selectedEducationLevel,
              items: [
                'Certificate',
                'Diploma',
                'Bachelor\'s Degree',
                'Master\'s Degree',
                'PhD',
                'N/A',
              ],
              onChanged: (value) {
                setState(() {
                  _selectedEducationLevel = value!;
                });
              },
              icon: Icons.school,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Specialization',
              value: _selectedSpecialization,
              items: [
                'General Practitioner',
                'Pathology',
                'Cardiology',
                'Dermatology',
                'Pediatrics',
                'General Surgery',
                'Psychiatry',
                'Radiology',
                'Anesthesiology',
                'Oncology',
                'Neurology',
                'Orthopedic Surgery',
                'Gynecology',
                'Ophthalmology',
                'N/A',
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSpecialization = value!;
                });
              },
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _fieldOfStudyController,
              label: 'Field of Study (Optional)',
              hint: 'e.g., Medicine, Nursing, Public Health',
              icon: Icons.book,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _institutionController,
              label: 'Institution/University (Optional)',
              hint: 'e.g., University of Nairobi',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _yearCompletedController,
              label: 'Year Completed (Optional)',
              hint: 'e.g., 2020',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addQualification,
                icon: const Icon(Icons.add),
                label: const Text('Add Qualification'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  side: const BorderSide(color: Colors.black, width: 1),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            if (_academicQualifications.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Added Qualifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._academicQualifications.map(
                (qual) => _buildQualificationCard(qual),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addQualification() {
    final qualification = AcademicQualification(
      title: _selectedTitle,
      educationLevel: _selectedEducationLevel,
      specialization: _selectedSpecialization,
      institution: _institutionController.text.trim().isEmpty
          ? null
          : _institutionController.text.trim(),
      yearCompleted: _yearCompletedController.text.trim().isEmpty
          ? null
          : int.tryParse(_yearCompletedController.text.trim()),
      fieldOfStudy: _fieldOfStudyController.text.trim().isEmpty
          ? null
          : _fieldOfStudyController.text.trim(),
    );

    setState(() {
      _academicQualifications.add(qualification);
      // Clear optional fields
      _institutionController.clear();
      _yearCompletedController.clear();
      _fieldOfStudyController.clear();
    });

    _showSnackBar('Qualification added successfully');
  }

  Widget _buildQualificationCard(AcademicQualification qual) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school, color: Colors.blue[600], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${qual.title} - ${qual.educationLevel}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Specialization: ${qual.specialization}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                if (qual.fieldOfStudy != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Field: ${qual.fieldOfStudy}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
                if (qual.institution != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    qual.institution!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
                if (qual.yearCompleted != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Completed: ${qual.yearCompleted}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _academicQualifications.remove(qual);
              });
              _showSnackBar('Qualification removed');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCertificationsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _certificationsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Certifications & Accreditations',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your professional certifications and accreditations',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _certificationNameController,
              label: 'Certification/Accreditation Name',
              hint: 'e.g., Board Certified in Internal Medicine',
              icon: Icons.verified,
              validator: (value) {
                if (_certifications.isEmpty &&
                    (value == null || value.isEmpty)) {
                  return 'Please add at least one certification';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _certificationIssuerController,
              label: 'Issuing Organization',
              hint: 'e.g., Medical Board of Kenya',
              icon: Icons.business,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _certificationYearController,
              label: 'Year Obtained',
              hint: 'e.g., 2020',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addCertification,
                icon: const Icon(Icons.add),
                label: const Text('Add Certification'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  side: const BorderSide(color: Colors.black, width: 1),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            if (_certifications.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Added Certifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._certifications.map((cert) => _buildCertificationCard(cert)),
            ],
          ],
        ),
      ),
    );
  }

  void _addCertification() {
    if (_certificationNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter certification name');
      return;
    }

    final certification = {
      'name': _certificationNameController.text.trim(),
      'issuer': _certificationIssuerController.text.trim(),
      'year': _certificationYearController.text.trim(),
    };

    setState(() {
      _certifications.add(certification);
      _certificationNameController.clear();
      _certificationIssuerController.clear();
      _certificationYearController.clear();
    });

    _showSnackBar('Certification added successfully');
  }

  Widget _buildCertificationCard(Map<String, String> cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.verified, color: Colors.green[600], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert['name']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (cert['issuer']!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    cert['issuer']!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
                if (cert['year']!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Year: ${cert['year']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _certifications.remove(cert);
              });
              _showSnackBar('Certification removed');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServicesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _servicesFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services & Skills',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about the services you offer',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _consultationFeeController,
              label: 'Consultation Fee (KES)',
              hint: '2000',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your consultation fee';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _bioController,
              label: 'Professional Bio',
              hint: 'Tell patients about your experience and approach...',
              icon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your bio';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildServicesSection(),
            const SizedBox(height: 24),
            _buildLanguagesSection(),
            const SizedBox(height: 24),
            _buildInsuranceSection(),
            const SizedBox(height: 24),
            _buildPaymentMethodsSection(),
            const SizedBox(height: 24),
            _buildWorkingDaysSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _contactFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide your contact details',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'john.doe@example.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+254740109195',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _physicalAddressController,
              label: 'Physical Address',
              hint: 'Building name, Street, Area',
              icon: Icons.location_on,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your physical address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _poBoxController,
              label: 'P.O. Box Number (Optional)',
              hint: 'P.O. Box 12345-00100',
              icon: Icons.markunread_mailbox,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Documents',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload required documents for verification',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ...widget.providerType.requirements.map((requirement) {
            return _buildDocumentUploadCard(requirement);
          }),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Document Guidelines',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Documents should be clear and legible\n'
                  '• Accepted formats: PDF, JPG, PNG\n'
                  '• Maximum file size: 5MB per document\n'
                  '• All documents will be verified within 24-48 hours',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review & Submit',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before submitting',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _buildAcademicQualificationsReviewSection(),
          const SizedBox(height: 20),
          _buildCertificationsReviewSection(),
          const SizedBox(height: 20),
          _buildReviewSection('Services & Skills', [
            'Consultation Fee: KES ${_consultationFeeController.text}',
            'Services: ${_selectedServices.join(', ')}',
            'Languages: ${_selectedLanguages.join(', ')}',
            'Working Days: ${_workingDays.join(', ')}',
          ]),
          const SizedBox(height: 20),
          _buildWorkingHoursReviewSection(),
          const SizedBox(height: 20),
          _buildReviewSection('Address Information', [
            'Name: ${_nameController.text}',
            'Email: ${_emailController.text}',
            'Phone: ${_phoneController.text}',
            'Physical Address: ${_physicalAddressController.text}',
            'City: ${_cityController.text}',
            if (_poBoxController.text.isNotEmpty)
              'P.O. Box: ${_poBoxController.text}',
          ]),
          const SizedBox(height: 20),
          _buildReviewSection('Documents', [
            'Uploaded: ${_uploadedDocuments.length}/${widget.providerType.requirements.length} documents',
            'Approved: ${_uploadedDocuments.where((doc) => doc.status == DocumentStatus.approved).length} documents',
            'Pending: ${_uploadedDocuments.where((doc) => doc.status == DocumentStatus.pending).length} documents',
          ]),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Next Steps',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '1. Your application will be reviewed within 24-48 hours\n'
                  '2. You\'ll receive an email notification about the status\n'
                  '3. Once approved, you can start accepting patients\n'
                  '4. Set up your availability and start earning',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildServicesSection() {
    final availableServices = _getAvailableServices();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services Offered',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableServices.map((service) {
            final isSelected = _selectedServices.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedServices.add(service);
                  } else {
                    _selectedServices.remove(service);
                  }
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[800],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _servicesDescriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Detailed Service Description',
            hintText:
                'Describe your services in detail, including specialties, procedures, treatments, equipment, and any other relevant information...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.description),
            helperText:
                'Provide as much detail as you want about your services',
            helperMaxLines: 2,
          ),
          validator: (value) {
            if ((value == null || value.trim().isEmpty) &&
                _selectedServices.isEmpty) {
              return 'Please select services or provide a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLanguagesSection() {
    final availableLanguages = [
      'English',
      'Swahili',
      'Kikuyu',
      'Luo',
      'Kalenjin',
      'Kamba',
      'Luhya',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Languages Spoken',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableLanguages.map((language) {
            final isSelected = _selectedLanguages.contains(language);
            return FilterChip(
              label: Text(language),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLanguages.add(language);
                  } else {
                    _selectedLanguages.remove(language);
                  }
                });
              },
              selectedColor: Colors.green[100],
              checkmarkColor: Colors.green[800],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<String> _buildPaymentMethodsString() {
    final methods = List<String>.from(_selectedPaymentMethods);

    // Add M-Pesa details if provided
    if (_selectedPaymentMethods.contains('M-Pesa')) {
      if (_mpesaPaybillController.text.isNotEmpty) {
        methods.add(
          'M-Pesa Paybill: ${_mpesaPaybillController.text}${_mpesaAccountController.text.isNotEmpty ? ' (Acc: ${_mpesaAccountController.text})' : ''}',
        );
      }
      if (_mpesaTillController.text.isNotEmpty) {
        methods.add('M-Pesa Till: ${_mpesaTillController.text}');
      }
    }

    // Add Bank details if provided
    if (_selectedPaymentMethods.contains('Bank Transfer')) {
      if (_bankNameController.text.isNotEmpty &&
          _bankAccountController.text.isNotEmpty) {
        methods.add(
          'Bank: ${_bankNameController.text} - ${_bankAccountController.text}',
        );
      }
    }

    return methods;
  }

  Widget _buildInsuranceSection() {
    final availableInsurance = [
      'NHIF',
      'AAR Insurance',
      'Jubilee Insurance',
      'CIC Insurance',
      'Madison Insurance',
      'Britam',
      'APA Insurance',
      'GA Insurance',
      'Old Mutual',
      'Liberty Life',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insurance Accepted',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Select insurance providers you accept',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableInsurance.map((insurance) {
            final isSelected = _selectedInsurance.contains(insurance);
            return FilterChip(
              label: Text(insurance),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInsurance.add(insurance);
                  } else {
                    _selectedInsurance.remove(insurance);
                  }
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[800],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    final paymentOptions = [
      'M-Pesa',
      'Bank Transfer',
      'Credit/Debit Card',
      'Insurance',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Methods Accepted',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Select payment methods you accept',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: paymentOptions.map((method) {
            final isSelected = _selectedPaymentMethods.contains(method);
            return FilterChip(
              label: Text(method),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPaymentMethods.add(method);
                  } else {
                    _selectedPaymentMethods.remove(method);
                  }
                });
              },
              selectedColor: Colors.green[100],
              checkmarkColor: Colors.green[800],
            );
          }).toList(),
        ),
        // M-Pesa Details
        if (_selectedPaymentMethods.contains('M-Pesa')) ...[
          const SizedBox(height: 20),
          const Text(
            'M-Pesa Payment Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _mpesaPaybillController,
            label: 'Paybill Number (Optional)',
            hint: 'Enter paybill number',
            icon: Icons.payment,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _mpesaAccountController,
            label: 'Account Number (Optional)',
            hint: 'Enter account number for paybill',
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _mpesaTillController,
            label: 'Till Number (Optional)',
            hint: 'Enter till number',
            icon: Icons.store,
            keyboardType: TextInputType.number,
          ),
        ],
        // Bank Transfer Details
        if (_selectedPaymentMethods.contains('Bank Transfer')) ...[
          const SizedBox(height: 20),
          const Text(
            'Bank Transfer Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bankNameController,
            label: 'Bank Name',
            hint: 'e.g., Equity Bank',
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bankAccountController,
            label: 'Account Number',
            hint: 'Enter account number',
            icon: Icons.numbers,
            keyboardType: TextInputType.number,
          ),
        ],
      ],
    );
  }

  Widget _buildWorkingDaysSection() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Working Days & Hours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select your working days and set hours for each day',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: days.map((day) {
              final isSelected = _workingDays.contains(day);
              final hours = _workingHours[day];
              final startTime = hours?['start'] ?? '08:00 AM';
              final endTime = hours?['end'] ?? '10:00 PM';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue[200]! : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _workingDays.add(day);
                                // Set default hours if not already set
                                if (!_workingHours.containsKey(day)) {
                                  _workingHours[day] = {
                                    'start': '08:00 AM',
                                    'end': '10:00 PM',
                                  };
                                }
                              } else {
                                _workingDays.remove(day);
                                _workingHours.remove(day);
                              }
                            });
                          },
                          activeColor: Colors.blue[600],
                        ),
                        Expanded(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Text(
                            '$startTime - $endTime',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeSelector(
                              label: 'Start Time',
                              value: startTime,
                              onTap: () => _selectTime(day, 'start', startTime),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimeSelector(
                              label: 'End Time',
                              value: endTime,
                              onTap: () => _selectTime(day, 'end', endTime),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(String day, String type, String currentTime) async {
    // Parse current time
    final parts = currentTime.split(' ');
    final timeParts = parts[0].split(':');
    final isPM = parts[1] == 'PM';
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Convert to 24-hour format for TimeOfDay
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Convert to 12-hour format
      final hour12 = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final formattedTime =
          '${hour12.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';

      setState(() {
        if (!_workingHours.containsKey(day)) {
          _workingHours[day] = {'start': '08:00 AM', 'end': '10:00 PM'};
        }
        _workingHours[day]![type] = formattedTime;
      });
    }
  }

  Widget _buildDocumentUploadCard(String documentType) {
    // Find all documents for this type
    final documents = _uploadedDocuments
        .where(
          (doc) =>
              doc.typeDisplayName.toLowerCase() == documentType.toLowerCase(),
        )
        .toList();

    final hasDocuments = documents.isNotEmpty;
    final approvedCount = documents
        .where((doc) => doc.status == DocumentStatus.approved)
        .length;
    final pendingCount = documents
        .where((doc) => doc.status == DocumentStatus.pending)
        .length;
    final rejectedCount = documents
        .where((doc) => doc.status == DocumentStatus.rejected)
        .length;

    Color statusColor = Colors.grey[600]!;
    String statusText = 'No documents uploaded';
    IconData statusIcon = Icons.upload_file;

    if (hasDocuments) {
      if (approvedCount > 0) {
        statusColor = Colors.green[600]!;
        statusText = '$approvedCount approved';
        statusIcon = Icons.check_circle;
      } else if (pendingCount > 0) {
        statusColor = Colors.orange[600]!;
        statusText = '$pendingCount pending review';
        statusIcon = Icons.pending;
      } else if (rejectedCount > 0) {
        statusColor = Colors.red[600]!;
        statusText = '$rejectedCount rejected';
        statusIcon = Icons.cancel;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDocuments
              ? statusColor.withValues(alpha: 0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documentType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasDocuments
                          ? '$statusText (${documents.length} total)'
                          : statusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _uploadDocument(documentType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text('Add Document'),
              ),
            ],
          ),
          if (documents.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...documents.map((doc) => _buildDocumentListItem(doc)),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentListItem(Document document) {
    Color statusColor = Colors.grey[600]!;
    IconData statusIcon = Icons.pending;

    switch (document.status) {
      case DocumentStatus.approved:
        statusColor = Colors.green[600]!;
        statusIcon = Icons.check_circle;
        break;
      case DocumentStatus.pending:
        statusColor = Colors.orange[600]!;
        statusIcon = Icons.pending;
        break;
      case DocumentStatus.rejected:
        statusColor = Colors.red[600]!;
        statusIcon = Icons.cancel;
        break;
      case DocumentStatus.expired:
        statusColor = Colors.grey[600]!;
        statusIcon = Icons.schedule;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${document.statusText} • ${document.fileSizeFormatted}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red[400],
            onPressed: () => _deleteDocument(document.id),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DocumentService.deleteDocument(documentId);
      if (success) {
        await _loadUploadedDocuments();
        _showSnackBar('Document deleted successfully');
      } else {
        _showSnackBar('Failed to delete document');
      }
    }
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicQualificationsReviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Academic Qualifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_academicQualifications.isEmpty)
            Text(
              'No qualifications added',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          else
            ..._academicQualifications.map((qual) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${qual.title} - ${qual.educationLevel}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Specialization: ${qual.specialization}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    if (qual.fieldOfStudy != null)
                      Text(
                        'Field: ${qual.fieldOfStudy}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    if (qual.institution != null)
                      Text(
                        qual.institution!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    if (qual.yearCompleted != null)
                      Text(
                        'Completed: ${qual.yearCompleted}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCertificationsReviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Certifications & Accreditations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_certifications.isEmpty)
            Text(
              'No certifications added',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          else
            ..._certifications.map((cert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (cert['issuer']!.isNotEmpty)
                      Text(
                        cert['issuer']!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    if (cert['year']!.isNotEmpty)
                      Text(
                        'Year: ${cert['year']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursReviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Working Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_workingDays.isEmpty)
            Text(
              'No working days selected',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          else
            ..._workingDays.map((day) {
              final hours = _workingHours[day];
              final timeRange = hours != null
                  ? '${hours['start']} - ${hours['end']}'
                  : 'Not set';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        timeRange,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black, width: 1),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Back', style: TextStyle(color: Colors.grey)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      _currentStep == _totalSteps - 1
                          ? 'Submit Application'
                          : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      // Validate current step
      bool isValid = false;
      switch (_currentStep) {
        case 0: // Basic Information
          isValid = _basicInfoFormKey.currentState?.validate() ?? false;
          break;
        case 1: // About
          isValid = _aboutFormKey.currentState?.validate() ?? false;
          break;
        case 2: // Experience
          isValid = _experienceFormKey.currentState?.validate() ?? false;
          // Experience is optional, so no validation needed
          break;
        case 3: // Education
          isValid = _educationFormKey.currentState?.validate() ?? false;
          if (isValid && _academicQualifications.isEmpty) {
            _showSnackBar('Please add at least one academic qualification');
            isValid = false;
          }
          break;
        case 4: // Certifications
          isValid = _certificationsFormKey.currentState?.validate() ?? false;
          if (isValid && _certifications.isEmpty) {
            _showSnackBar('Please add at least one certification');
            isValid = false;
          }
          break;
        case 5: // Services & Skills
          isValid = _servicesFormKey.currentState?.validate() ?? false;
          if (isValid &&
              _selectedServices.isEmpty &&
              _servicesDescriptionController.text.trim().isEmpty) {
            _showSnackBar(
              'Please select services or provide a detailed description',
            );
            isValid = false;
          }
          if (isValid && _selectedLanguages.isEmpty) {
            _showSnackBar('Please select at least one language');
            isValid = false;
          }
          if (isValid && _workingDays.isEmpty) {
            _showSnackBar('Please select at least one working day');
            isValid = false;
          }
          break;
        case 6: // Contact Information
          isValid = _contactFormKey.currentState?.validate() ?? false;
          break;
        case 7: // Documents
          // Check if at least one document is uploaded for each required type
          final requiredTypes = widget.providerType.requirements;
          final missingTypes = <String>[];

          for (final requiredType in requiredTypes) {
            final hasDocument = _uploadedDocuments.any(
              (doc) =>
                  doc.typeDisplayName.toLowerCase() ==
                  requiredType.toLowerCase(),
            );
            if (!hasDocument) {
              missingTypes.add(requiredType);
            }
          }

          isValid = missingTypes.isEmpty;
          if (!isValid) {
            _showSnackBar(
              'Please upload at least one document for: ${missingTypes.join(", ")}',
            );
          }
          break;
      }

      if (isValid) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitApplication();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _uploadDocument(String documentType) async {
    // Map document type string to DocumentType enum
    DocumentType docType;
    switch (documentType.toLowerCase()) {
      case 'medical license':
        docType = DocumentType.medicalLicense;
        break;
      case 'nursing license':
        docType = DocumentType.nursingLicense;
        break;
      case 'professional license':
        docType = DocumentType.professionalLicense;
        break;
      case 'professional certification':
        docType = DocumentType.professionalCertification;
        break;
      case 'certification':
        docType = DocumentType.certification;
        break;
      case 'nutrition certification':
        docType = DocumentType.nutritionCertification;
        break;
      case 'caregiver certification':
        docType = DocumentType.caregiverCertification;
        break;
      case 'background check':
        docType = DocumentType.backgroundCheck;
        break;
      case 'valid id':
        docType = DocumentType.validId;
        break;
      case 'insurance certificate':
        docType = DocumentType.insurance;
        break;
      case 'hospital license':
        docType = DocumentType.hospitalLicense;
        break;
      case 'accreditation':
        docType = DocumentType.accreditation;
        break;
      case 'business registration':
        docType = DocumentType.businessRegistration;
        break;
      case 'clinic license':
        docType = DocumentType.clinicLicense;
        break;
      case 'medical permits':
        docType = DocumentType.medicalPermits;
        break;
      case 'pharmacy license':
        docType = DocumentType.pharmacyLicense;
        break;
      case 'pharmacist license':
        docType = DocumentType.pharmacistLicense;
        break;
      case 'laboratory license':
        docType = DocumentType.laboratoryLicense;
        break;
      case 'quality certification':
        docType = DocumentType.qualityCertification;
        break;
      case 'dental license':
        docType = DocumentType.dentalLicense;
        break;
      case 'practice license':
        docType = DocumentType.practiceLicense;
        break;
      case 'business license':
        docType = DocumentType.businessLicense;
        break;
      case 'health permits':
        docType = DocumentType.healthPermits;
        break;
      default:
        docType = DocumentType.other;
    }

    // Navigate to document upload screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentUploadScreen(documentType: docType),
      ),
    );

    if (result == true) {
      // Reload uploaded documents
      await _loadUploadedDocuments();
      _showSnackBar('$documentType uploaded successfully');
    }
  }

  void _submitApplication() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = UserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Map provider type ID to UserRole
      UserRole providerRole = _mapProviderTypeToRole(widget.providerType.id);

      // Convert working hours to the format expected by the model
      final Map<String, String> formattedWorkingHours = {};
      for (final day in _workingDays) {
        final hours = _workingHours[day];
        if (hours != null) {
          formattedWorkingHours[day] = '${hours['start']} - ${hours['end']}';
        }
      }

      // Build full address with P.O. Box if provided
      String fullAddress = _physicalAddressController.text.trim();
      if (_poBoxController.text.trim().isNotEmpty) {
        fullAddress += '\n${_poBoxController.text.trim()}';
      }

      // Convert certifications to list of strings
      final List<String> certificationsList = _certifications.map((cert) {
        String certStr = cert['name']!;
        if (cert['issuer']!.isNotEmpty) {
          certStr += ' - ${cert['issuer']}';
        }
        if (cert['year']!.isNotEmpty) {
          certStr += ' (${cert['year']})';
        }
        return certStr;
      }).toList();

      // Get primary specialization from academic qualifications
      String? primarySpecialization;
      if (_academicQualifications.isNotEmpty) {
        primarySpecialization = _academicQualifications.first.specialization;
      }

      // Create ProviderProfile
      // Calculate total experience years from work history
      int totalExperienceYears = 0;
      for (final exp in _workExperiences) {
        totalExperienceYears += (exp.totalMonths / 12).ceil();
      }

      final providerProfile = ProviderProfile(
        userId: currentUser.id,
        providerType: providerRole,
        status: ProviderStatus.pending, // Pending verification
        specialization: primarySpecialization,
        servicesOffered: _selectedServices,
        servicesDescription: _servicesDescriptionController.text.trim(),
        experienceYears: totalExperienceYears > 0 ? totalExperienceYears : null,
        bio: _bioController.text.trim(),
        workExperience: _workExperiences,
        academicQualifications: _academicQualifications,
        certifications: certificationsList,
        languages: _selectedLanguages,
        insuranceAccepted: _selectedInsurance,
        paymentMethods: _buildPaymentMethodsString(),
        consultationFee: double.tryParse(_consultationFeeController.text),
        workingDays: _workingDays,
        workingHours: formattedWorkingHours,
        verificationDocuments: _uploadedDocuments.map((d) => d.id).toList(),
      );

      // Save provider profile
      final savedProfile = await ProviderService.createProvider(
        providerProfile,
      );
      if (savedProfile == null) {
        throw Exception('Failed to create provider profile');
      }

      // Add provider role to user
      await UserService.addRole(providerRole);

      // Update user profile with location data
      final updatedUser = currentUser.copyWith(
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        address: fullAddress,
      );
      await UserService.updateProfile(updatedUser);

      // Also create in old services for backward compatibility
      if (widget.providerType.category == ProviderCategory.individual) {
        final newProvider =
            HealthcareProviderService.createProviderFromRegistration(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              address: fullAddress,
              specialization: primarySpecialization ?? 'General Practitioner',
              experienceYears: totalExperienceYears,
              bio: _bioController.text,
              consultationFee:
                  double.tryParse(_consultationFeeController.text) ?? 0.0,
              services: _selectedServices,
              languages: _selectedLanguages,
              workingDays: _workingDays,
              providerType: widget.providerType.name,
              profileImagePath:
                  currentUser.profilePicturePath ??
                  'https://via.placeholder.com/200',
            );
        await HealthcareProviderService.addNewProvider(newProvider);
      }

      // Simulate processing time
      await Future.delayed(const Duration(seconds: 1));

      // Send notification to user's inbox
      await MessageService.addMessage(
        senderId: 'system',
        senderName: 'Klinate System',
        content:
            'Your provider application has been submitted successfully! Our team will review your documents and notify you once the verification is complete. Thank you for joining Klinate.',
        type: MessageType.system,
        category: MessageCategory.systemNotification,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Registration failed: ${e.toString()}');
      }
    }
  }

  UserRole _mapProviderTypeToRole(String providerTypeId) {
    switch (providerTypeId) {
      case 'doctor':
        return UserRole.doctor;
      case 'nurse':
        return UserRole.nurse;
      case 'therapist':
        return UserRole.therapist;
      case 'nutritionist':
        return UserRole.nutritionist;
      case 'home_care':
        return UserRole.homecare;
      default:
        return UserRole.doctor;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Documents Submitted Successfully!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your documents have been submitted successfully and will be reviewed by our team. We will notify you once the review is complete.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Close dialog first
                  Navigator.of(context).pop();

                  // Navigate back to home screen, clearing all previous routes
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);

                  // Capture context before async gap
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // Show success snackbar
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Application submitted successfully! You will be notified once reviewed.',
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<String> _getAvailableServices() {
    switch (widget.providerType.id) {
      case 'doctor':
        return [
          'Consultation',
          'Diagnosis',
          'Treatment',
          'Follow-up',
          'Emergency Care',
        ];
      case 'nurse':
        return [
          'Patient Care',
          'Health Education',
          'Medication Administration',
          'Wound Care',
          'Home Visits',
        ];
      case 'therapist':
        return [
          'Physical Therapy',
          'Mental Health Counseling',
          'Rehabilitation',
          'Group Therapy',
          'Assessment',
        ];
      case 'nutritionist':
        return [
          'Diet Planning',
          'Nutrition Counseling',
          'Weight Management',
          'Sports Nutrition',
          'Health Assessment',
        ];
      case 'home_care':
        return [
          'Personal Care',
          'Medical Assistance',
          'Companionship',
          'Medication Reminders',
          'Mobility Support',
        ];
      case 'hospital':
        return [
          'Emergency Services',
          'Surgery',
          'Inpatient Care',
          'Outpatient Services',
          'Diagnostic Services',
        ];
      case 'clinic':
        return [
          'General Consultation',
          'Specialist Services',
          'Preventive Care',
          'Health Screenings',
          'Vaccinations',
        ];
      case 'pharmacy':
        return [
          'Prescription Dispensing',
          'Medication Counseling',
          'Health Products',
          'Vaccination Services',
          'Health Screenings',
        ];
      case 'laboratory':
        return [
          'Blood Tests',
          'Imaging Services',
          'Pathology',
          'Diagnostic Tests',
          'Health Screenings',
        ];
      case 'dental':
        return [
          'General Dentistry',
          'Teeth Cleaning',
          'Oral Surgery',
          'Orthodontics',
          'Cosmetic Dentistry',
        ];
      case 'wellness':
        return [
          'Wellness Programs',
          'Fitness Training',
          'Stress Management',
          'Nutrition Guidance',
          'Health Coaching',
        ];
      default:
        return ['General Services'];
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _nameController.dispose();
    _headlineController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _jobTitleController.dispose();
    _organizationController.dispose();
    _locationController.dispose();
    _startMonthController.dispose();
    _startYearController.dispose();
    _endMonthController.dispose();
    _endYearController.dispose();
    _experienceDescriptionController.dispose();
    _institutionController.dispose();
    _yearCompletedController.dispose();
    _fieldOfStudyController.dispose();
    _certificationNameController.dispose();
    _certificationIssuerController.dispose();
    _certificationYearController.dispose();
    _servicesDescriptionController.dispose();
    _consultationFeeController.dispose();
    _mpesaPaybillController.dispose();
    _mpesaAccountController.dispose();
    _mpesaTillController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _physicalAddressController.dispose();
    _poBoxController.dispose();
    super.dispose();
  }
}

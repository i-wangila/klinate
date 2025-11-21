import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../utils/responsive_utils.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  String _selectedGender = '';
  String _selectedBloodType = '';
  bool _isLoading = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
    'Other',
  ];

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profile = UserService.currentUser;
    if (profile != null && mounted) {
      // Split the full name into first and last name
      final nameParts = profile.name.split(' ');
      setState(() {
        if (nameParts.isNotEmpty) {
          _firstNameController.text = nameParts[0];
          if (nameParts.length > 1) {
            _lastNameController.text = nameParts.sublist(1).join(' ');
          }
        }
        _emailController.text = profile.email;
        _phoneController.text = profile.phone;
        _addressController.text = profile.address;
        _dateOfBirthController.text = profile.dateOfBirth;
        _selectedGender = profile.gender;
        _selectedBloodType = profile.bloodType;
        _weightController.text = profile.weight ?? '';
        _heightController.text = profile.height ?? '';
        _allergiesController.text = profile.allergies.join(', ');
        _medicalConditionsController.text = profile.medicalConditions.join(
          ', ',
        );
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Manage Account',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              Text(
                'Update your personal details below',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 24),
              ),
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 3,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 32),
              ),
              Text(
                'Medical Information (Optional)',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              Text(
                'This information helps healthcare providers serve you better',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildDropdownField(
                value: _selectedGender.isEmpty ? null : _selectedGender,
                label: 'Gender',
                icon: Icons.person_outline,
                items: _genderOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value ?? '';
                  });
                },
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildDateField(
                controller: _dateOfBirthController,
                label: 'Date of Birth',
                icon: Icons.cake,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildDropdownField(
                value: _selectedBloodType.isEmpty ? null : _selectedBloodType,
                label: 'Blood Type',
                icon: Icons.bloodtype,
                items: _bloodTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value ?? '';
                  });
                },
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies',
                icon: Icons.warning_amber,
                maxLines: 2,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                child: Text(
                  'Separate multiple allergies with commas',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              _buildTextField(
                controller: _medicalConditionsController,
                label: 'Medical Conditions',
                icon: Icons.medical_information,
                maxLines: 2,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                child: Text(
                  'Separate multiple conditions with commas',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 32),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        16,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.grey[700],
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              16,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        ),
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        ),
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
        color: Colors.black,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        ),
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: controller.text.isNotEmpty
              ? DateTime.tryParse(controller.text) ?? DateTime.now()
              : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black,
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
          setState(() {
            controller.text = picked.toIso8601String().split('T')[0];
          });
        }
      },
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current profile
      final currentProfile = UserService.currentUser;

      if (currentProfile != null) {
        // Combine first and last name
        final fullName =
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

        // Parse allergies and medical conditions
        final allergiesList = _allergiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final medicalConditionsList = _medicalConditionsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // Create updated profile
        final updatedProfile = currentProfile.copyWith(
          name: fullName,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          gender: _selectedGender,
          dateOfBirth: _dateOfBirthController.text.trim(),
          bloodType: _selectedBloodType,
          weight: _weightController.text.trim().isEmpty
              ? null
              : _weightController.text.trim(),
          height: _heightController.text.trim().isEmpty
              ? null
              : _heightController.text.trim(),
          allergies: allergiesList,
          medicalConditions: medicalConditionsList,
        );

        // Update profile
        final success = await UserService.updateProfile(updatedProfile);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Return true to indicate successful update
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update account'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

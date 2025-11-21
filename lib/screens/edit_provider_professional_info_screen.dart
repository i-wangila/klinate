import 'package:flutter/material.dart';
import '../models/provider_profile.dart';
import '../services/provider_service.dart';

class EditProviderProfessionalInfoScreen extends StatefulWidget {
  final ProviderProfile providerProfile;

  const EditProviderProfessionalInfoScreen({
    super.key,
    required this.providerProfile,
  });

  @override
  State<EditProviderProfessionalInfoScreen> createState() =>
      _EditProviderProfessionalInfoScreenState();
}

class _EditProviderProfessionalInfoScreenState
    extends State<EditProviderProfessionalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _licenseController;
  late TextEditingController _experienceController;
  late TextEditingController _consultationFeeController;
  late TextEditingController _bioController;
  final List<String> _selectedLanguages = [];
  bool _isLoading = false;

  final List<String> _availableLanguages = [
    'English',
    'Swahili',
    'French',
    'Spanish',
    'Arabic',
    'Kikuyu',
    'Luo',
    'Luhya',
    'Kamba',
  ];

  @override
  void initState() {
    super.initState();
    _licenseController = TextEditingController(
      text: widget.providerProfile.licenseNumber ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.providerProfile.experienceYears?.toString() ?? '',
    );
    _consultationFeeController = TextEditingController(
      text: widget.providerProfile.consultationFee?.toString() ?? '',
    );
    _bioController = TextEditingController(
      text: widget.providerProfile.bio ?? '',
    );
    _selectedLanguages.addAll(widget.providerProfile.languages);
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _experienceController.dispose();
    _consultationFeeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Professional Information',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _licenseController,
                      label: 'License Number',
                      hint: 'Enter your professional license number',
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _experienceController,
                      label: 'Years of Experience',
                      hint: 'Enter years of experience',
                      icon: Icons.work,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final years = int.tryParse(value);
                          if (years == null || years < 0) {
                            return 'Enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _consultationFeeController,
                      label: 'Consultation Fee (KES)',
                      hint: 'Enter consultation fee',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final fee = double.tryParse(value);
                          if (fee == null || fee < 0) {
                            return 'Enter a valid amount';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Professional Bio',
                      hint: 'Tell patients about yourself and your practice',
                      icon: Icons.description,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Languages Spoken',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableLanguages.map((language) {
                        final isSelected = _selectedLanguages.contains(
                          language,
                        );
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
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue[700],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
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
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
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
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update provider profile
      final updatedProfile = widget.providerProfile.copyWith(
        licenseNumber: _licenseController.text.trim().isNotEmpty
            ? _licenseController.text.trim()
            : null,
        experienceYears: _experienceController.text.trim().isNotEmpty
            ? int.tryParse(_experienceController.text.trim())
            : null,
        consultationFee: _consultationFeeController.text.trim().isNotEmpty
            ? double.tryParse(_consultationFeeController.text.trim())
            : null,
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        languages: _selectedLanguages,
      );

      final success = await ProviderService.updateProvider(updatedProfile);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Professional information updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update information'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

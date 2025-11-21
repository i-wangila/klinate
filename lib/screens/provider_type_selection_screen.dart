import 'package:flutter/material.dart';
import '../models/provider_type.dart';
import 'provider_registration_screen.dart';

class ProviderTypeSelectionScreen extends StatefulWidget {
  const ProviderTypeSelectionScreen({super.key});

  @override
  State<ProviderTypeSelectionScreen> createState() =>
      _ProviderTypeSelectionScreenState();
}

class _ProviderTypeSelectionScreenState
    extends State<ProviderTypeSelectionScreen> {
  ProviderType? _selectedProviderType;

  @override
  void initState() {
    super.initState();
    // Auto-navigate to registration with Doctor/Physician type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorType = ProviderTypeService.getIndividualProviders().first;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProviderRegistrationScreen(providerType: doctorType),
        ),
      );
    });
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
        title: const Text(
          'Choose Your Service Type',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(child: _buildProviderTypesList()),
          if (_selectedProviderType != null) _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doctor/Physician Registration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Register as a licensed medical doctor or physician',
            style: TextStyle(fontSize: 14, color: Colors.blue[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTypesList() {
    final providerTypes = ProviderTypeService.getIndividualProviders();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: providerTypes.length,
      itemBuilder: (context, index) {
        final providerType = providerTypes[index];
        return _buildProviderTypeCard(providerType);
      },
    );
  }

  Widget _buildProviderTypeCard(ProviderType providerType) {
    final isSelected = _selectedProviderType?.id == providerType.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProviderType = isSelected ? null : providerType;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getProviderTypeColor(
                      providerType.id,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProviderTypeIcon(providerType.id),
                    size: 32,
                    color: _getProviderTypeColor(providerType.id),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerType.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Setup time: ${providerType.estimatedSetupTime}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              providerType.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildExamplesSection(providerType.examples),
            const SizedBox(height: 16),
            _buildRequirementsSection(providerType.requirements),
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesSection(List<String> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Examples:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: examples.take(3).map((example) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                example,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRequirementsSection(List<String> requirements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Documents:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...requirements.take(3).map((requirement) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  requirement,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContinueButton() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.green[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Selected: ${_selectedProviderType!.name}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderRegistrationScreen(
                        providerType: _selectedProviderType!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProviderTypeIcon(String id) {
    switch (id) {
      case 'doctor':
        return Icons.medical_services;
      case 'nurse':
        return Icons.healing;
      case 'therapist':
        return Icons.psychology;
      case 'nutritionist':
        return Icons.restaurant;
      case 'home_care':
        return Icons.home_work;
      case 'hospital':
        return Icons.local_hospital;
      case 'clinic':
        return Icons.business;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'laboratory':
        return Icons.science;
      case 'dental':
        return Icons.face;
      case 'wellness':
        return Icons.spa;
      default:
        return Icons.medical_services;
    }
  }

  Color _getProviderTypeColor(String id) {
    switch (id) {
      case 'doctor':
        return Colors.blue;
      case 'nurse':
        return Colors.green;
      case 'therapist':
        return Colors.purple;
      case 'nutritionist':
        return Colors.orange;
      case 'home_care':
        return Colors.teal;
      case 'hospital':
        return Colors.red;
      case 'clinic':
        return Colors.indigo;
      case 'pharmacy':
        return Colors.green;
      case 'laboratory':
        return Colors.blue;
      case 'dental':
        return Colors.cyan;
      case 'wellness':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

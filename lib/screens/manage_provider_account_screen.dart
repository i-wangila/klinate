import 'package:flutter/material.dart';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';
import '../services/provider_service.dart';
import '../services/user_service.dart';
import 'edit_provider_basic_info_screen.dart';
import 'edit_provider_professional_info_screen.dart';
import 'edit_provider_availability_screen.dart';

class ManageProviderAccountScreen extends StatefulWidget {
  final ProviderProfile providerProfile;

  const ManageProviderAccountScreen({super.key, required this.providerProfile});

  @override
  State<ManageProviderAccountScreen> createState() =>
      _ManageProviderAccountScreenState();
}

class _ManageProviderAccountScreenState
    extends State<ManageProviderAccountScreen> {
  late ProviderProfile _profile;
  late UserProfile? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.providerProfile;
    _user = UserService.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Business Account Settings',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountOverview(),
                  const SizedBox(height: 16),
                  _buildBasicInformation(),
                  const SizedBox(height: 16),
                  _buildProfessionalInformation(),
                  const SizedBox(height: 16),
                  _buildAvailabilitySettings(),
                  const SizedBox(height: 16),
                  _buildDangerZone(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Colors.green[700],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile.providerType.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.name ?? 'Provider',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'APPROVED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Rating',
                '${_profile.rating.toStringAsFixed(1)}⭐',
              ),
              _buildStatItem('Patients', '${_profile.totalPatients}'),
              _buildStatItem('Reviews', '${_profile.totalReviews}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildBasicInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _editBasicInformation,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', _user?.name ?? 'N/A'),
          _buildInfoRow('Email', _user?.email ?? 'N/A'),
          _buildInfoRow('Phone', _user?.phone ?? 'N/A'),
          _buildInfoRow('Specialization', _profile.specialization ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildProfessionalInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Professional Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _editProfessionalInformation,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('License Number', _profile.licenseNumber ?? 'N/A'),
          _buildInfoRow(
            'Experience',
            _profile.experienceYears != null
                ? '${_profile.experienceYears} years'
                : 'N/A',
          ),
          _buildInfoRow(
            'Consultation Fee',
            _profile.consultationFee != null
                ? '${_profile.currency} ${_profile.consultationFee}'
                : 'N/A',
          ),
          _buildInfoRow(
            'Languages',
            _profile.languages.isNotEmpty
                ? _profile.languages.join(', ')
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Availability Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _editAvailability,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Accepting New Patients'),
            subtitle: Text(
              _profile.acceptingNewPatients
                  ? 'You are currently accepting new patients'
                  : 'You are not accepting new patients',
            ),
            value: _profile.acceptingNewPatients,
            activeColor: Colors.green,
            onChanged: (value) {
              setState(() {
                _profile = _profile.copyWith(acceptingNewPatients: value);
                ProviderService.updateProvider(_profile);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Now accepting new patients'
                        : 'Not accepting new patients',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const Divider(),
          _buildInfoRow(
            'Working Days',
            _profile.workingDays.isNotEmpty
                ? _profile.workingDays.join(', ')
                : 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'These actions are permanent and will affect your business account.',
            style: TextStyle(fontSize: 14, color: Colors.red[800]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deactivateProviderAccount,
              icon: const Icon(Icons.pause_circle_outline),
              label: const Text('Deactivate Business Account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange[700],
                side: BorderSide(color: Colors.orange[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteProviderAccount,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete Business Account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _editBasicInformation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProviderBasicInfoScreen(providerProfile: _profile, user: _user),
      ),
    );

    // Reload profile if changes were made
    if (result == true) {
      setState(() {
        _profile = ProviderService.getProviderById(_profile.id) ?? _profile;
        _user = UserService.currentUser;
      });
    }
  }

  void _editProfessionalInformation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProviderProfessionalInfoScreen(providerProfile: _profile),
      ),
    );

    // Reload profile if changes were made
    if (result == true) {
      setState(() {
        _profile = ProviderService.getProviderById(_profile.id) ?? _profile;
      });
    }
  }

  void _editAvailability() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProviderAvailabilityScreen(providerProfile: _profile),
      ),
    );

    // Reload profile if changes were made
    if (result == true) {
      setState(() {
        _profile = ProviderService.getProviderById(_profile.id) ?? _profile;
      });
    }
  }

  void _deactivateProviderAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pause_circle_outline, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Deactivate Business Account'),
          ],
        ),
        content: const Text(
          'Your business account will be temporarily deactivated. You can reactivate it later from Settings.\n\n'
          'During deactivation:\n'
          '• Your profile will be hidden from patients\n'
          '• You won\'t receive new appointments\n'
          '• Existing appointments will remain active\n'
          '• Your data will be preserved',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeactivation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _deleteProviderAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Delete Business Account'),
          ],
        ),
        content: const Text(
          'This action is PERMANENT and cannot be undone!\n\n'
          'Deleting your business account will:\n'
          '• Remove your profile from the platform\n'
          '• Cancel all future appointments\n'
          '• Delete all your provider data\n'
          '• Remove your business information\n\n'
          'Your general user account will remain active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteProviderAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProviderAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Are you absolutely sure you want to delete your business account?\n\n'
          'Type "DELETE" to confirm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  void _performDeactivation() async {
    setState(() => _isLoading = true);

    try {
      // Update provider status to suspended
      final updatedProfile = _profile.copyWith(
        status: ProviderStatus.suspended,
      );
      ProviderService.updateProvider(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business account deactivated successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
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

  void _performDeletion() async {
    setState(() => _isLoading = true);

    try {
      // Delete provider profile
      ProviderService.deleteProvider(_profile.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business account deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate back to settings
        Navigator.popUntil(context, (route) => route.isFirst);
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

import 'package:flutter/material.dart';
import '../models/provider_profile.dart';
import '../services/provider_service.dart';

class EditProviderAvailabilityScreen extends StatefulWidget {
  final ProviderProfile providerProfile;

  const EditProviderAvailabilityScreen({
    super.key,
    required this.providerProfile,
  });

  @override
  State<EditProviderAvailabilityScreen> createState() =>
      _EditProviderAvailabilityScreenState();
}

class _EditProviderAvailabilityScreenState
    extends State<EditProviderAvailabilityScreen> {
  late bool _acceptingNewPatients;
  late Map<String, bool> _selectedDays;
  late Map<String, TimeOfDay?> _startTimes;
  late Map<String, TimeOfDay?> _endTimes;
  bool _isLoading = false;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _acceptingNewPatients = widget.providerProfile.acceptingNewPatients;

    // Initialize selected days
    _selectedDays = {};
    for (var day in _daysOfWeek) {
      _selectedDays[day] = widget.providerProfile.workingDays.contains(day);
    }

    // Initialize working hours
    _startTimes = {};
    _endTimes = {};
    for (var day in _daysOfWeek) {
      final hours = widget.providerProfile.workingHours[day];
      if (hours != null && hours.contains('-')) {
        final parts = hours.split('-');
        _startTimes[day] = _parseTime(parts[0].trim());
        _endTimes[day] = _parseTime(parts[1].trim());
      } else {
        _startTimes[day] = const TimeOfDay(hour: 9, minute: 0);
        _endTimes[day] = const TimeOfDay(hour: 17, minute: 0);
      }
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Return default time if parsing fails
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Availability',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAcceptingPatientsSection(),
            const SizedBox(height: 24),
            _buildWorkingDaysSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptingPatientsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Acceptance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Accepting New Patients',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _acceptingNewPatients
                  ? 'You are currently accepting new patients'
                  : 'You are not accepting new patients',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            value: _acceptingNewPatients,
            activeColor: Colors.green,
            onChanged: (value) {
              setState(() {
                _acceptingNewPatients = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Working Days & Hours',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your working days and set hours for each day',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ..._daysOfWeek.map((day) => _buildDayCard(day)),
      ],
    );
  }

  Widget _buildDayCard(String day) {
    final isSelected = _selectedDays[day] ?? false;
    final startTime = _startTimes[day];
    final endTime = _endTimes[day];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelected,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    _selectedDays[day] = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected) ...[
                _buildTimeButton(
                  label: _formatTime(startTime!),
                  onTap: () => _selectTime(day, true),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('-', style: TextStyle(fontSize: 18)),
                ),
                _buildTimeButton(
                  label: _formatTime(endTime!),
                  onTap: () => _selectTime(day, false),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(String day, bool isStartTime) async {
    final currentTime = isStartTime ? _startTimes[day] : _endTimes[day];

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTimes[day] = picked;
        } else {
          _endTimes[day] = picked;
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      // Build working days list
      final workingDays = _selectedDays.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Build working hours map
      final workingHours = <String, String>{};
      for (var day in workingDays) {
        final start = _startTimes[day];
        final end = _endTimes[day];
        if (start != null && end != null) {
          workingHours[day] = '${_formatTime(start)} - ${_formatTime(end)}';
        }
      }

      // Validate
      if (workingDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one working day'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Update provider profile
      final updatedProfile = widget.providerProfile.copyWith(
        acceptingNewPatients: _acceptingNewPatients,
        workingDays: workingDays,
        workingHours: workingHours,
      );

      ProviderService.updateProvider(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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

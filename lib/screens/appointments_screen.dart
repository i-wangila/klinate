import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';
import '../services/provider_availability_service.dart';
import '../services/call_service.dart';
import '../services/user_service.dart';
import '../services/provider_service.dart';
import '../services/healthcare_provider_service.dart';
import '../services/message_service.dart';
import '../models/appointment.dart';
import '../models/message.dart';
import '../utils/responsive_utils.dart';
import 'reschedule_appointment_screen.dart';
import 'rate_provider_screen.dart';
import 'book_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appointments = AppointmentService.getAllAppointments();
    final allCount = appointments.length;
    final upcomingCount = appointments
        .where(
          (apt) =>
              apt.dateTime.isAfter(DateTime.now()) &&
              apt.status != AppointmentStatus.completed &&
              apt.status != AppointmentStatus.cancelled,
        )
        .length;
    final completedCount = appointments
        .where((apt) => apt.status == AppointmentStatus.completed)
        .length;
    final cancelledCount = appointments
        .where((apt) => apt.status == AppointmentStatus.cancelled)
        .length;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        20,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'clear_completed') {
                        _showClearHistoryDialog('completed');
                      } else if (value == 'clear_cancelled') {
                        _showClearHistoryDialog('cancelled');
                      } else if (value == 'clear_all_history') {
                        _showClearHistoryDialog('all_history');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'clear_completed',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep, size: 20),
                            SizedBox(width: 8),
                            Text('Clear Completed'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_cancelled',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep, size: 20),
                            SizedBox(width: 8),
                            Text('Clear Cancelled'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_all_history',
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever, size: 20),
                            SizedBox(width: 8),
                            Text('Clear All History'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildTabBar(
                      allCount,
                      upcomingCount,
                      completedCount,
                      cancelledCount,
                    ),
                    Expanded(child: _buildTabContent()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(
    int allCount,
    int upcomingCount,
    int completedCount,
    int cancelledCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabButton('All Bookings', allCount, 0),
            const SizedBox(width: 8),
            _buildTabButton('Upcoming', upcomingCount, 1),
            const SizedBox(width: 8),
            _buildTabButton('Completed', completedCount, 2),
            const SizedBox(width: 8),
            _buildTabButton('Cancelled', cancelledCount, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int count, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.black, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final appointments = AppointmentService.getAllAppointments();
    List<Appointment> filteredAppointments;

    switch (_selectedTabIndex) {
      case 1: // Upcoming
        filteredAppointments = appointments
            .where(
              (apt) =>
                  apt.dateTime.isAfter(DateTime.now()) &&
                  apt.status != AppointmentStatus.completed &&
                  apt.status != AppointmentStatus.cancelled,
            )
            .toList();
        break;
      case 2: // Completed
        filteredAppointments = appointments
            .where((apt) => apt.status == AppointmentStatus.completed)
            .toList();
        break;
      case 3: // Cancelled
        filteredAppointments = appointments
            .where((apt) => apt.status == AppointmentStatus.cancelled)
            .toList();
        break;
      default: // All
        filteredAppointments = appointments;
    }

    if (filteredAppointments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(filteredAppointments[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_selectedTabIndex) {
      case 1:
        message = 'No upcoming appointments';
        break;
      case 2:
        message = 'No completed appointments';
        break;
      case 3:
        message = 'No cancelled appointments';
        break;
      default:
        message = 'No appointments yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isCompleted = appointment.status == AppointmentStatus.completed;
    final isUpcoming =
        appointment.dateTime.isAfter(DateTime.now()) &&
        appointment.status != AppointmentStatus.completed &&
        appointment.status != AppointmentStatus.cancelled;

    // Get the actual doctor's name from UserService
    String doctorName = appointment.providerName;
    String specialization = appointment.providerName;

    try {
      final provider = ProviderService.getProviderById(appointment.providerId);
      if (provider != null) {
        // Get specialization from provider
        specialization = provider.specialization ?? appointment.providerName;

        // Find the user by ID
        final users = UserService.getAllUsers();
        final user = users.firstWhere(
          (u) => u.id == provider.userId,
          orElse: () => throw Exception('User not found'),
        );
        doctorName = user.name;
      }
    } catch (e) {
      // If we can't find the user, fall back to providerName
      doctorName = appointment.providerName;
      specialization = appointment.providerName;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with name, ID, status, and menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialization,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${appointment.id.split('-').first}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(appointment.status),
                // Three-dot menu for upcoming appointments
                if (isUpcoming)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onSelected: (value) {
                      if (value == 'reschedule') {
                        _rescheduleAppointment(appointment);
                      } else if (value == 'cancel') {
                        _cancelAppointment(appointment);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reschedule',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 18, color: Colors.blue),
                            SizedBox(width: 12),
                            Text('Reschedule'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Cancel'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Details
            _buildDetailRow('Description', appointment.description),
            const SizedBox(height: 8),
            _buildDetailRow('Type', _getAppointmentType(appointment)),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Communication',
              _getCommunicationTypeLabel(appointment.communicationType),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Date & Time',
              DateFormat('MMM dd, yyyy - hh:mm a').format(appointment.dateTime),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Total Payment',
              'KES ${appointment.amount.toStringAsFixed(2)} (Paid)',
            ),
            const SizedBox(height: 16),
            // Action buttons
            _buildActionButtons(appointment, isUpcoming, isCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    String label;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case AppointmentStatus.scheduled:
        label = 'SCHEDULED';
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case AppointmentStatus.completed:
        label = 'COMP';
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case AppointmentStatus.cancelled:
        label = 'CANCELLED';
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case AppointmentStatus.inProgress:
        label = 'IN PROGRESS';
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case AppointmentStatus.missed:
        label = 'MISSED';
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.grey[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(maxWidth: 100),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, color: Colors.black),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getAppointmentType(Appointment appointment) {
    // Determine type based on provider name or description
    final name = appointment.providerName.toLowerCase();
    final desc = appointment.description.toLowerCase();

    if (name.contains('hospital') || name.contains('clinic')) {
      return 'Hospital Appointment';
    } else if (desc.contains('dental') || name.contains('dental')) {
      return 'Dental Appointment';
    } else {
      return 'Doctor Consultation';
    }
  }

  String _getCommunicationTypeLabel(CommunicationType type) {
    switch (type) {
      case CommunicationType.video:
        return 'VIDEO CALL';
      case CommunicationType.voice:
        return 'VOICE CALL';
      case CommunicationType.inPerson:
        return 'IN-PERSON';
      case CommunicationType.chat:
        return 'CHAT';
    }
  }

  Widget _buildActionButtons(
    Appointment appointment,
    bool isUpcoming,
    bool isCompleted,
  ) {
    if (isCompleted) {
      // Completed appointments: Book Again and Rate Provider
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _bookAgain(appointment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Book Again',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _rateProvider(appointment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.star, size: 16),
              label: const Text(
                'Rate Provider',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      );
    } else if (isUpcoming) {
      // Upcoming appointments: Action button, Reschedule, Cancel
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle action based on communication type
                if (appointment.communicationType == CommunicationType.video) {
                  _startVideoCall(appointment);
                } else if (appointment.communicationType ==
                    CommunicationType.voice) {
                  _startVoiceCall(appointment);
                } else {
                  _showAppointmentDetails(appointment);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                _getActionButtonLabel(appointment.communicationType),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _rescheduleAppointment(appointment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Reschedule',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _cancelAppointment(appointment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      );
    } else {
      // Past appointments (not completed)
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _rateProvider(appointment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Rate Provider',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      );
    }
  }

  String _getActionButtonLabel(CommunicationType type) {
    switch (type) {
      case CommunicationType.video:
        return 'Video Call';
      case CommunicationType.voice:
        return 'Voice Call';
      case CommunicationType.inPerson:
        return 'View Details';
      case CommunicationType.chat:
        return 'View Details';
    }
  }

  void _startVideoCall(Appointment appointment) async {
    try {
      final currentUser = UserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      await CallService.initiateCall(
        context: context,
        callerId: currentUser.id,
        callerName: currentUser.name,
        calleeId: appointment.providerId,
        calleeName: appointment.providerName,
        isVideoCall: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start video call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startVoiceCall(Appointment appointment) async {
    try {
      final currentUser = UserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      await CallService.initiateCall(
        context: context,
        callerId: currentUser.id,
        callerName: currentUser.name,
        calleeId: appointment.providerId,
        calleeName: appointment.providerName,
        isVideoCall: false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start voice call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Appointment Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Provider', appointment.providerName),
              _buildDetailRow(
                'Date',
                DateFormat('MMM dd, yyyy').format(appointment.dateTime),
              ),
              _buildDetailRow(
                'Time',
                DateFormat('hh:mm a').format(appointment.dateTime),
              ),
              _buildDetailRow(
                'Type',
                _getCommunicationTypeLabel(appointment.communicationType),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _rescheduleAppointment(Appointment appointment) async {
    // Show quick reschedule options first
    final shouldUseFullScreen = await _showQuickRescheduleOptions(appointment);

    if (shouldUseFullScreen == true && mounted) {
      // Use full reschedule screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RescheduleAppointmentScreen(appointment: appointment),
        ),
      );

      // If appointment was rescheduled, refresh the list and switch to upcoming tab
      if (result == true) {
        setState(() {
          _selectedTabIndex = 1; // Switch to "Upcoming" tab
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment rescheduled successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _cancelAppointment(Appointment appointment) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancel appointment with ${appointment.providerName}?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation (optional)',
                hintText: 'Please provide a reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim().isEmpty
                  ? 'No reason provided'
                  : reasonController.text.trim();

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              // Cancel the appointment
              await AppointmentService.cancelAppointment(appointment.id);

              // Send confirmation notification to patient
              await MessageService.addMessage(
                senderId: 'system',
                senderName: 'Klinate System',
                content:
                    '✓ Appointment Cancelled\n\nYou have successfully cancelled your appointment with ${appointment.providerName} scheduled for ${DateFormat('MMM dd, yyyy - h:mm a').format(appointment.dateTime)}.\n\nReason: $reason\n\nThe provider has been notified.',
                type: MessageType.appointment,
                category: MessageCategory.systemNotification,
              );

              // Send notification to provider's inbox
              await MessageService.addSystemNotification(
                '⚠️ Patient Cancelled Appointment\n\nYour patient has cancelled their appointment scheduled for ${DateFormat('MMM dd, yyyy - h:mm a').format(appointment.dateTime)}.\n\nPatient: ${UserService.currentUser?.name ?? 'Patient'}\nType: ${appointment.description}\nReason: $reason',
                MessageType.appointment,
              );

              if (mounted) {
                navigator.pop();
                setState(() {});
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }

  void _rateProvider(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateProviderScreen(appointment: appointment),
      ),
    );
  }

  Future<bool?> _showQuickRescheduleOptions(Appointment appointment) async {
    // Get available slots for the next few days
    final today = DateTime.now();
    final availableDates = <DateTime>[];

    // Check next 7 days for availability
    for (int i = 1; i <= 7; i++) {
      final date = today.add(Duration(days: i));
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        if (ProviderAvailabilityService.isProviderAvailableOnDate(
          appointment.providerId,
          date,
        )) {
          availableDates.add(date);
        }
      }
    }

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Quick Reschedule',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a new date and time for your appointment with ${appointment.providerName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Available dates and times
            Expanded(
              child: availableDates.isEmpty
                  ? _buildNoAvailabilityMessage()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: availableDates.length,
                      itemBuilder: (context, index) {
                        final date = availableDates[index];
                        return _buildQuickDateOption(appointment, date);
                      },
                    ),
            ),

            // Full calendar option
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('View Full Calendar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAvailabilityMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No quick slots available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the full calendar to find more options',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateOption(Appointment appointment, DateTime date) {
    final slots = ProviderAvailabilityService.getAvailableSlots(
      appointment.providerId,
      date,
    );

    if (slots.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM dd').format(date),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.take(6).map((slot) {
                return _buildQuickTimeSlot(appointment, slot);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTimeSlot(Appointment appointment, TimeSlot slot) {
    return GestureDetector(
      onTap: slot.isAvailable
          ? () => _quickReschedule(appointment, slot)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: slot.isAvailable ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          DateFormat('h:mm a').format(slot.dateTime),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: slot.isAvailable ? Colors.white : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  void _quickReschedule(Appointment appointment, TimeSlot slot) async {
    Navigator.pop(context); // Close bottom sheet

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Reschedule the appointment
      await AppointmentService.rescheduleAppointment(
        appointment.id,
        slot.dateTime,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Switch to upcoming tab and show success
      setState(() {
        _selectedTabIndex = 1; // Switch to "Upcoming" tab
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment rescheduled to ${DateFormat('MMM dd, yyyy - h:mm a').format(slot.dateTime)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to reschedule appointment. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _bookAgain(Appointment appointment) async {
    // Find the provider from the appointment
    final provider = HealthcareProviderService.getProviderById(
      appointment.providerId,
    );

    if (provider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Provider not found. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to book appointment screen with the same provider
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(provider: provider),
      ),
    );

    // If appointment was booked successfully, refresh the list
    if (result == true && mounted) {
      setState(() {
        _selectedTabIndex = 1; // Switch to "Upcoming" tab
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New appointment booked successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showClearHistoryDialog(String type) {
    String title;
    String message;
    Future<bool> Function() clearFunction;

    switch (type) {
      case 'completed':
        title = 'Clear Completed Appointments';
        message =
            'Are you sure you want to clear all completed appointments? This action cannot be undone.';
        clearFunction = AppointmentService.clearCompletedAppointments;
        break;
      case 'cancelled':
        title = 'Clear Cancelled Appointments';
        message =
            'Are you sure you want to clear all cancelled appointments? This action cannot be undone.';
        clearFunction = AppointmentService.clearCancelledAppointments;
        break;
      case 'all_history':
        title = 'Clear All History';
        message =
            'Are you sure you want to clear all completed and cancelled appointments? This action cannot be undone.';
        clearFunction = AppointmentService.clearAllHistory;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();
              final success = await clearFunction();
              if (mounted) {
                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('History cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {
                    // Refresh the UI
                  });
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to clear history'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import 'appointments_screen.dart';
import 'medical_records_screen.dart';

class NotificationChatScreen extends StatefulWidget {
  final Message message;

  const NotificationChatScreen({super.key, required this.message});

  @override
  State<NotificationChatScreen> createState() => _NotificationChatScreenState();
}

class _NotificationChatScreenState extends State<NotificationChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message.senderName,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              _getNotificationSubtitle(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Show calendar icon for appointment notifications
          if (widget.message.type == MessageType.appointment)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _viewAppointment(),
              tooltip: 'View Appointments',
            ),
          if (widget.message.isMedicalRecord)
            IconButton(
              icon: const Icon(Icons.medical_information),
              onPressed: () => _viewMedicalRecord(),
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_unread',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_unread, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Mark as Unread'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Notification'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[50]),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildNotificationBubble(),
                  const SizedBox(height: 20),
                  _buildNotificationInfo(),
                ],
              ),
            ),
          ),
          _buildDisabledMessageInput(),
        ],
      ),
    );
  }

  Widget _buildNotificationBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: _getNotificationColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getNotificationBorderColor(), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getNotificationIcon(),
                  size: 20,
                  color: _getNotificationIconColor(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getNotificationTitle(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _getNotificationIconColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.message.content,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                    'MMM dd, yyyy at hh:mm a',
                  ).format(widget.message.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (widget.message.type == MessageType.appointment ||
                    widget.message.isMedicalRecord)
                  _buildActionButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    String buttonText;
    VoidCallback onPressed;

    if (widget.message.type == MessageType.appointment) {
      buttonText = 'View Appointment';
      onPressed = _viewAppointment;
    } else if (widget.message.isMedicalRecord) {
      buttonText = _getMedicalRecordButtonText();
      onPressed = _viewMedicalRecord;
    } else {
      buttonText = 'View Details';
      onPressed = () {};
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _getMedicalRecordButtonText() {
    switch (widget.message.type) {
      case MessageType.prescription:
        return 'View Prescription';
      case MessageType.labResults:
        return 'View Lab Results';
      case MessageType.medicalReport:
        return 'View Medical Report';
      case MessageType.xrayReport:
        return 'View X-ray Report';
      case MessageType.dischargeSummary:
        return 'View Discharge Summary';
      case MessageType.vaccinationRecord:
        return 'View Vaccination Record';
      default:
        return 'View Record';
    }
  }

  Widget _buildDisabledMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[500], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'This is a system notification - replies are not available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.grey[500]),
              onPressed: null, // Disabled
            ),
          ),
        ],
      ),
    );
  }

  String _getNotificationSubtitle() {
    switch (widget.message.type) {
      case MessageType.appointment:
        return 'Appointment Notification';
      case MessageType.prescription:
        return 'Prescription Notification';
      case MessageType.labResults:
        return 'Lab Results Notification';
      case MessageType.medicalReport:
        return 'Medical Report Notification';
      case MessageType.xrayReport:
        return 'X-ray Report Notification';
      case MessageType.dischargeSummary:
        return 'Discharge Summary Notification';
      case MessageType.vaccinationRecord:
        return 'Vaccination Record Notification';
      case MessageType.system:
        return 'System Notification';
      default:
        return 'Notification';
    }
  }

  String _getNotificationTitle() {
    switch (widget.message.type) {
      case MessageType.appointment:
        return 'Appointment Update';
      case MessageType.prescription:
        return 'New Prescription';
      case MessageType.labResults:
        return 'Lab Results Available';
      case MessageType.medicalReport:
        return 'Medical Report Available';
      case MessageType.xrayReport:
        return 'X-ray Report Available';
      case MessageType.dischargeSummary:
        return 'Discharge Summary Available';
      case MessageType.vaccinationRecord:
        return 'Vaccination Record Available';
      case MessageType.system:
        return 'System Alert';
      default:
        return 'Notification';
    }
  }

  IconData _getNotificationIcon() {
    switch (widget.message.type) {
      case MessageType.appointment:
        return Icons.calendar_today;
      case MessageType.prescription:
        return Icons.medication;
      case MessageType.labResults:
        return Icons.science;
      case MessageType.medicalReport:
        return Icons.description;
      case MessageType.xrayReport:
        return Icons.medical_information;
      case MessageType.dischargeSummary:
        return Icons.local_hospital;
      case MessageType.vaccinationRecord:
        return Icons.vaccines;
      case MessageType.system:
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor() {
    if (widget.message.isMedicalRecord) {
      return Colors.grey[50]!;
    }
    switch (widget.message.type) {
      case MessageType.appointment:
        return Colors.grey[50]!;
      case MessageType.system:
        return Colors.grey[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getNotificationBorderColor() {
    return Colors.grey[300]!;
  }

  Color _getNotificationIconColor() {
    return Colors.grey[700]!;
  }

  void _viewAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
    );
  }

  void _viewMedicalRecord() {
    // Navigate to Medical Records Screen with highlighted document
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalRecordsScreen(
          highlightDocumentId: widget.message.documentId,
        ),
      ),
    );
  }

  Widget _buildNotificationInfo() {
    return Column(
      children: [
        // Show View Appointment button for appointment notifications
        if (widget.message.type == MessageType.appointment)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: _viewAppointment,
              icon: const Icon(Icons.calendar_today),
              label: const Text('View Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'About this notification',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This is an automated system notification. You cannot reply to this message, but you can take actions using the buttons above if available.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_unread':
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification marked as unread'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      case 'delete':
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }
}

import 'package:flutter/material.dart';
import '../models/message.dart';
import 'chat_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientName;
  final String patientId;
  final String dob;
  final String lastVisited;

  const PatientDetailScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.dob,
    required this.lastVisited,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
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
          widget.patientName,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.black),
            onPressed: _openChat,
            tooltip: 'Message Patient',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfo(),
            _buildMedicalHistory(),
            _buildAppointmentHistory(),
            _buildPrescriptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.patientName.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patientName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.patientId,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      widget.dob,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.lastVisited,
                  style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistory() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.medical_services, color: Colors.red[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Medical History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMedicalHistoryItem(
            'Hypertension',
            'Diagnosed: Jan 2020',
            'Controlled with medication',
            Colors.orange,
          ),
          _buildMedicalHistoryItem(
            'Type 2 Diabetes',
            'Diagnosed: Mar 2019',
            'Managed with diet and insulin',
            Colors.red,
          ),
          _buildMedicalHistoryItem(
            'Asthma',
            'Diagnosed: Childhood',
            'Occasional inhaler use',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryItem(
    String condition,
    String diagnosed,
    String status,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            condition,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            diagnosed,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          Text(status, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildAppointmentHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.calendar_today, color: Colors.green[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Recent Appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAppointmentItem(
            'General Checkup',
            '4th May 2021',
            'Completed',
            Colors.green,
          ),
          _buildAppointmentItem(
            'Follow-up Consultation',
            '15th Mar 2021',
            'Completed',
            Colors.green,
          ),
          _buildAppointmentItem(
            'Blood Test Review',
            '2nd Feb 2021',
            'Completed',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(
    String type,
    String date,
    String status,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.medication, color: Colors.purple[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Current Prescriptions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPrescriptionItem(
            'Lisinopril 10mg',
            'Once daily',
            'For hypertension',
          ),
          _buildPrescriptionItem(
            'Metformin 500mg',
            'Twice daily with meals',
            'For diabetes',
          ),
          _buildPrescriptionItem(
            'Albuterol Inhaler',
            'As needed',
            'For asthma',
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionItem(
    String medication,
    String dosage,
    String purpose,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.medication, color: Colors.purple[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dosage,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                Text(
                  purpose,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    final message = Message(
      id: 'patient_${widget.patientId}',
      senderId: widget.patientId,
      senderName: widget.patientName,
      content: 'Start a conversation with ${widget.patientName}',
      timestamp: DateTime.now(),
      type: MessageType.text,
      category: MessageCategory.healthcareProvider,
      isRead: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(message: message)),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/appointment_service.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';
import 'patient_detail_screen.dart';

class ProviderPatientsScreen extends StatefulWidget {
  const ProviderPatientsScreen({super.key});

  @override
  State<ProviderPatientsScreen> createState() => _ProviderPatientsScreenState();
}

class _ProviderPatientsScreenState extends State<ProviderPatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PatientCard> _patients = [];
  List<PatientCard> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() {
    final currentUser = UserService.currentUser;
    if (currentUser == null) {
      _patients = [];
      _filteredPatients = [];
      return;
    }

    // Get unique patient emails for this provider (excluding other providers)
    final patientEmails = AppointmentService.getUniquePatientEmailsForProvider(
      currentUser.email,
    );

    // Get appointments for each patient to find their last visit
    _patients = patientEmails.map((email) {
      final appointments = AppointmentService.getPatientAppointmentsForProvider(
        currentUser.email,
      ).where((apt) => apt.patientEmail == email).toList();

      // Sort by date to find most recent
      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      final lastVisit = appointments.isNotEmpty
          ? appointments.first.dateTime
          : DateTime.now();

      // Generate APID from email
      final apid = 'APID-${email.hashCode.abs().toString().substring(0, 7)}';

      return PatientCard(
        name: appointments.isNotEmpty
            ? appointments.first.patientName
            : email.split('@').first,
        apid: apid,
        dob: 'DOB: N/A', // Would need to be stored in user profile
        lastVisited: 'Last Visited On: ${_formatDate(lastVisit)}',
        imageUrl: 'https://via.placeholder.com/80',
      );
    }).toList();

    _filteredPatients = _patients;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day;
    final suffix = day == 1 || day == 21 || day == 31
        ? 'st'
        : day == 2 || day == 22
        ? 'nd'
        : day == 3 || day == 23
        ? 'rd'
        : 'th';
    return '$day$suffix ${months[date.month - 1]} ${date.year}';
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((patient) {
          final nameLower = patient.name.toLowerCase();
          final apidLower = patient.apid.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower) ||
              apidLower.contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildPatientsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search patients',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: _filterPatients,
            ),
          ),
          const Icon(Icons.search, color: Colors.black),
          const SizedBox(width: 8),
          // Three-dot menu for bulk actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteAllConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Delete All Patients',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    if (_filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No patients found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        return _buildPatientCard(_filteredPatients[index]);
      },
    );
  }

  Widget _buildPatientCard(PatientCard patient) {
    return GestureDetector(
      onTap: () => _viewPatientDetails(patient),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Patient Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${patient.apid}    ${patient.dob}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patient.lastVisited,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Message Button
            IconButton(
              onPressed: () => _openChatWithPatient(patient),
              icon: const Icon(Icons.message, color: Colors.black, size: 22),
              tooltip: 'Message ${patient.name}',
            ),
            // Delete Button
            IconButton(
              onPressed: () => _showDeletePatientConfirmation(patient),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey[700],
                size: 22,
              ),
              tooltip: 'Delete ${patient.name}',
            ),
          ],
        ),
      ),
    );
  }

  void _viewPatientDetails(PatientCard patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(
          patientName: patient.name,
          patientId: patient.apid,
          dob: patient.dob,
          lastVisited: patient.lastVisited,
        ),
      ),
    );
  }

  void _openChatWithPatient(PatientCard patient) {
    // Create a message object to open chat
    final message = Message(
      id: 'patient_${patient.apid}',
      senderId: 'patient_${patient.apid}',
      senderName: patient.name,
      content: 'Start a conversation with ${patient.name}',
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

  void _showDeletePatientConfirmation(PatientCard patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient Record'),
        content: Text(
          'Are you sure you want to delete ${patient.name}\'s medical history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePatient(patient);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePatient(PatientCard patient) {
    setState(() {
      _patients.removeWhere((p) => p.apid == patient.apid);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${patient.name}\'s record deleted'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _patients.add(patient);
            });
          },
        ),
      ),
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Delete All Patients'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete ALL patient records? This will permanently remove all medical histories and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllPatients();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _deleteAllPatients() {
    final deletedPatients = List<PatientCard>.from(_patients);

    setState(() {
      _patients.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All ${deletedPatients.length} patient records deleted'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _patients = deletedPatients;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class PatientCard {
  final String name;
  final String apid;
  final String dob;
  final String lastVisited;
  final String imageUrl;

  PatientCard({
    required this.name,
    required this.apid,
    required this.dob,
    required this.lastVisited,
    required this.imageUrl,
  });
}

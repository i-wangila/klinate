import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/healthcare_provider.dart';
import '../models/appointment.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../services/provider_availability_service.dart';
import '../services/appointment_service.dart';
import '../services/user_service.dart';
import '../services/message_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final HealthcareProvider provider;

  const BookAppointmentScreen({super.key, required this.provider});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeSlot? _selectedTimeSlot;
  CommunicationType _selectedCommunicationType = CommunicationType.video;
  List<TimeSlot> _availableSlots = [];
  bool _isLoading = false;

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadAvailableSlots(_selectedDay!);
  }

  void _loadAvailableSlots(DateTime date) {
    setState(() {
      _availableSlots = ProviderAvailabilityService.getAvailableSlots(
        widget.provider.id,
        date,
      );
      _selectedTimeSlot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Prevent providers from booking appointments for themselves (except admins)
    final currentUser = UserService.currentUser;
    if (currentUser?.isProvider == true &&
        currentUser?.currentRole != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Book Appointment'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                const Text(
                  'Providers Cannot Book Appointments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'As a healthcare provider, you cannot book appointments for yourself. This feature is only available for patients.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProviderInfo(),
                  const SizedBox(height: 24),
                  _buildCommunicationTypeSection(),
                  const SizedBox(height: 24),
                  _buildCalendarSection(),
                  const SizedBox(height: 24),
                  if (_selectedDay != null) _buildTimeSlotsSection(),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                ],
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[100],
            child: Text(
              widget.provider.name.split(' ').map((e) => e[0]).take(2).join(),
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.provider.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.provider.specialization,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'KES ${widget.provider.consultationFee.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCommunicationTypeCard(
                CommunicationType.video,
                'Video Call',
                Icons.videocam,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCommunicationTypeCard(
                CommunicationType.voice,
                'Voice Call',
                Icons.phone,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCommunicationTypeCard(
                CommunicationType.chat,
                'Chat',
                Icons.chat,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCommunicationTypeCard(
                CommunicationType.inPerson,
                'In-Person',
                Icons.person,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunicationTypeCard(
    CommunicationType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedCommunicationType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCommunicationType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? color : Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TableCalendar<TimeSlot>(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            enabledDayPredicate: (day) {
              if (day.isBefore(
                DateTime.now().subtract(const Duration(days: 1)),
              )) {
                return false;
              }
              if (day.weekday == DateTime.saturday ||
                  day.weekday == DateTime.sunday) {
                return false;
              }
              return ProviderAvailabilityService.isProviderAvailableOnDate(
                widget.provider.id,
                day,
              );
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadAvailableSlots(selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.grey[400]),
              disabledTextStyle: TextStyle(color: Colors.grey[300]),
              selectedDecoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Times - ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        if (_availableSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No available time slots',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableSlots.length,
            itemBuilder: (context, index) {
              final slot = _availableSlots[index];
              return _buildTimeSlotCard(slot);
            },
          ),
      ],
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot) {
    final isSelected = _selectedTimeSlot?.dateTime == slot.dateTime;
    final timeFormat = DateFormat('hh:mm a');

    return GestureDetector(
      onTap: slot.isAvailable
          ? () {
              setState(() {
                _selectedTimeSlot = slot;
              });
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: slot.isAvailable
              ? (isSelected ? Colors.black : Colors.white)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: slot.isAvailable
                ? (isSelected ? Colors.black : Colors.grey[300]!)
                : Colors.grey[200]!,
          ),
        ),
        child: Center(
          child: Text(
            timeFormat.format(slot.dateTime),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: slot.isAvailable
                  ? (isSelected ? Colors.white : Colors.black)
                  : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Describe Your Symptoms (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Please describe your symptoms or reason for consultation...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedTimeSlot != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Appointment: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedTimeSlot!.dateTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedTimeSlot != null
                      ? _bookAppointment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _bookAppointment() async {
    if (_selectedTimeSlot == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        providerId: widget.provider.id,
        providerName: widget.provider.name,
        providerEmail: widget.provider.email,
        patientId: 'patient_rony',
        patientName: 'Rony',
        patientEmail: 'rony@example.com',
        dateTime: _selectedTimeSlot!.dateTime,
        durationMinutes: 30,
        communicationType: _selectedCommunicationType,
        status: AppointmentStatus.scheduled,
        amount: widget.provider.consultationFee,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : '${widget.provider.specialization} consultation',
        meetingLink:
            _selectedCommunicationType == CommunicationType.video ||
                _selectedCommunicationType == CommunicationType.voice
            ? 'https://meet.klinate.com/room/${DateTime.now().millisecondsSinceEpoch}'
            : null,
        chatRoomId: _selectedCommunicationType == CommunicationType.chat
            ? 'chat_${DateTime.now().millisecondsSinceEpoch}'
            : null,
      );

      await AppointmentService.bookAppointment(appointment);

      // Send notification to provider about new appointment
      final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
      final timeFormat = DateFormat('h:mm a');
      await MessageService.addMessage(
        senderId: 'system',
        senderName: 'Klinate System',
        content:
            'New appointment booked by ${appointment.patientName} for ${dateFormat.format(appointment.dateTime)} at ${timeFormat.format(appointment.dateTime)}. Tap to view appointment details.',
        type: MessageType.appointment,
        category: MessageCategory.systemNotification,
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment booked successfully with ${widget.provider.name}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to book appointment. Please try again.'),
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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/message_service.dart';
import '../models/message.dart';

class ProviderAppointmentsScreen extends StatefulWidget {
  const ProviderAppointmentsScreen({super.key});

  @override
  State<ProviderAppointmentsScreen> createState() =>
      _ProviderAppointmentsScreenState();
}

class _ProviderAppointmentsScreenState
    extends State<ProviderAppointmentsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedFilter = 'All';
  bool _isCalendarExpanded = false;

  final List<Appointment> _appointments = [
    Appointment(
      patientName: 'Kelvin Abdallah',
      time: '9:00 - 9:30 AM',
      type: 'Annual Checkup',
      status: AppointmentStatus.now,
      appointmentType: 'Video Call',
    ),
    Appointment(
      patientName: 'Joseph Golub',
      time: '9:00 - 9:30 AM',
      type: 'Annual Checkup',
      status: AppointmentStatus.followUp,
      appointmentType: 'Voice Call',
    ),
    Appointment(
      patientName: 'Eduardo Dykes',
      time: '9:00 - 9:30 AM',
      type: 'Other Services (D)',
      status: AppointmentStatus.now,
      appointmentType: 'In-Person',
    ),
    Appointment(
      patientName: 'Thomas Vance',
      time: '9:00 - 9:30 AM',
      type: 'Annual Checkup',
      status: AppointmentStatus.followUp,
      appointmentType: 'Video Call',
    ),
    Appointment(
      patientName: 'Rena Lafontaine',
      time: '9:00 - 9:30 AM',
      type: 'Other Services (D)',
      status: AppointmentStatus.followUp,
      appointmentType: 'Voice Call',
    ),
    Appointment(
      patientName: 'Advin Markwin',
      time: '9:00 - 9:30 AM',
      type: 'Annual Checkup',
      status: AppointmentStatus.now,
      appointmentType: 'In-Person',
    ),
  ];

  List<Appointment> get _filteredAppointments {
    if (_selectedFilter == 'All') {
      return _appointments;
    }
    return _appointments
        .where((apt) => apt.appointmentType == _selectedFilter)
        .toList();
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    // For demo purposes, return appointments for today
    // In a real app, you would filter by the actual date
    if (isSameDay(day, DateTime.now())) {
      return _appointments;
    }
    // Add some appointments for other days for demo
    if (day.day == 15 || day.day == 20 || day.day == 25) {
      return [_appointments.first];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 6,
      radius: const Radius.circular(3),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildCalendar(), _buildAppointmentsList()],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('d MMMM yyyy, EEEE').format(_focusedDay),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              Row(
                children: [
                  if (_isCalendarExpanded) ...[
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedDay),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                  IconButton(
                    icon: Icon(
                      _isCalendarExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCalendarExpanded = !_isCalendarExpanded;
                      });
                    },
                    tooltip: _isCalendarExpanded
                        ? 'Collapse calendar'
                        : 'Expand calendar',
                  ),
                ],
              ),
            ],
          ),
          if (_isCalendarExpanded) ...[
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _isCalendarExpanded
                  ? CalendarFormat.month
                  : CalendarFormat.twoWeeks,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerVisible: false,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.twoWeeks: '2 weeks',
              },
              eventLoader: _getAppointmentsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                todayDecoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
                weekendDecoration: const BoxDecoration(shape: BoxShape.circle),
                outsideDecoration: const BoxDecoration(shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: const TextStyle(color: Colors.black),
                weekendTextStyle: const TextStyle(color: Colors.black),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(color: Colors.white),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredAppointments.length} Bookings for Today\'s',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              DropdownButton<String>(
                value: _selectedFilter,
                underline: const SizedBox(),
                items: ['All', 'Video Call', 'Voice Call', 'In-Person']
                    .map(
                      (filter) =>
                          DropdownMenuItem(value: filter, child: Text(filter)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFilter = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredAppointments.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildAppointmentItem(_filteredAppointments[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.time}   ${appointment.type}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildStatusButton(appointment.status, appointment),
        ],
      ),
    );
  }

  Widget _buildStatusButton(AppointmentStatus status, Appointment appointment) {
    return InkWell(
      onTap: () => _showCancelDialog(appointment),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(Appointment appointment) {
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
              'Cancel appointment with ${appointment.patientName}?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation',
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
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for cancellation'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _cancelAppointment(appointment, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Appointment appointment, String reason) async {
    // Send cancellation message to patient's inbox
    await MessageService.addSystemNotification(
      '⚠️ Appointment Cancelled\n\nYour appointment scheduled for ${appointment.time} (${appointment.type}) has been cancelled by your healthcare provider.\n\nReason: $reason\n\nPlease contact us to reschedule at your convenience.',
      MessageType.appointment,
    );

    // Send confirmation alert to provider's inbox
    await MessageService.addSystemNotification(
      '✓ Appointment Cancellation Confirmation\n\nYou have successfully cancelled the appointment with ${appointment.patientName} scheduled for ${appointment.time}.\n\nType: ${appointment.type}\nReason: $reason\n\nThe patient has been notified automatically.',
      MessageType.appointment,
    );

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment with ${appointment.patientName} cancelled. Patient has been notified.',
          ),
          backgroundColor: Colors.black,
        ),
      );
    }

    // Remove appointment from list
    setState(() {
      _appointments.remove(appointment);
    });
  }
}

class Appointment {
  final String patientName;
  final String time;
  final String type;
  final AppointmentStatus status;
  final String appointmentType;

  Appointment({
    required this.patientName,
    required this.time,
    required this.type,
    required this.status,
    required this.appointmentType,
  });
}

enum AppointmentStatus { now, followUp }

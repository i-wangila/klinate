import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/provider_availability_service.dart';
import '../services/appointment_service.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final Appointment appointment;
  final bool isBookingAgain;

  const RescheduleAppointmentScreen({
    super.key,
    required this.appointment,
    this.isBookingAgain = false,
  });

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeSlot? _selectedTimeSlot;
  List<TimeSlot> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadAvailableSlots(_selectedDay!);
  }

  void _loadAvailableSlots(DateTime date) {
    setState(() {
      _availableSlots = ProviderAvailabilityService.getAvailableSlots(
        widget.appointment.providerId,
        date,
      );
      _selectedTimeSlot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isBookingAgain
              ? 'Book New Appointment'
              : 'Reschedule Appointment',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppointmentInfo(),
                  const SizedBox(height: 16),
                  _buildBookingAgainMessage(),
                  const SizedBox(height: 8),
                  _buildCalendarSection(),
                  const SizedBox(height: 24),
                  if (_selectedDay != null) _buildTimeSlotsSection(),
                ],
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isBookingAgain
                ? 'Previous Appointment Details'
                : 'Current Appointment',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue[100],
                child: Text(
                  widget.appointment.providerName
                      .split(' ')
                      .map((e) => e[0])
                      .take(2)
                      .join(),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.providerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.appointment.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(widget.appointment.dateTime),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  Widget _buildBookingAgainMessage() {
    if (!widget.isBookingAgain) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re booking a new appointment with the same provider and service details.',
              style: TextStyle(fontSize: 14, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isBookingAgain ? 'Select Appointment Date' : 'Select New Date',
          style: const TextStyle(
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
              // Disable past dates and weekends
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
                widget.appointment.providerId,
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
              markerDecoration: const BoxDecoration(
                color: Colors.green,
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
                  const SizedBox(height: 4),
                  Text(
                    'Please select another date',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeFormat.format(slot.dateTime),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: slot.isAvailable
                      ? (isSelected ? Colors.white : Colors.black)
                      : Colors.grey[400],
                ),
              ),
              if (!slot.isAvailable && slot.reason != null)
                Text(
                  slot.reason!,
                  style: TextStyle(fontSize: 8, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
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
                      'New appointment: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedTimeSlot!.dateTime)}',
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

          // Reschedule and Back buttons
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
                    'Back',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedTimeSlot != null
                      ? _rescheduleAppointment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.isBookingAgain
                              ? 'Book Appointment'
                              : 'Reschedule',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment() async {
    if (_selectedTimeSlot == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      if (widget.isBookingAgain) {
        // Create a new appointment based on the cancelled one
        final newAppointment = Appointment(
          id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
          providerId: widget.appointment.providerId,
          providerName: widget.appointment.providerName,
          providerEmail: widget.appointment.providerEmail,
          patientId: widget.appointment.patientId,
          patientName: widget.appointment.patientName,
          patientEmail: widget.appointment.patientEmail,
          dateTime: _selectedTimeSlot!.dateTime,
          durationMinutes: widget.appointment.durationMinutes,
          communicationType: widget.appointment.communicationType,
          status: AppointmentStatus.scheduled,
          amount: widget.appointment.amount,
          description: widget.appointment.description,
          meetingLink: widget.appointment.meetingLink,
          chatRoomId: widget.appointment.chatRoomId,
        );

        // Book the new appointment
        await AppointmentService.bookAppointment(newAppointment);
      } else {
        // Update the existing appointment
        AppointmentService.rescheduleAppointment(
          widget.appointment.id,
          _selectedTimeSlot!.dateTime,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isBookingAgain
                  ? 'New appointment booked for ${DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedTimeSlot!.dateTime)}'
                  : 'Appointment rescheduled to ${DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedTimeSlot!.dateTime)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isBookingAgain
                  ? 'Failed to book new appointment. Please try again.'
                  : 'Failed to reschedule appointment. Please try again.',
            ),
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
}

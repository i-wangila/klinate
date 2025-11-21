import '../models/appointment.dart';
import 'appointment_service.dart';

class TimeSlot {
  final DateTime dateTime;
  final bool isAvailable;
  final String? reason; // Why it's not available

  TimeSlot({required this.dateTime, required this.isAvailable, this.reason});
}

class ProviderAvailabilityService {
  // Standard working hours: 9 AM to 5 PM
  static const int startHour = 9;
  static const int endHour = 17;
  static const int slotDurationMinutes = 30;

  /// Get available time slots for a provider on a specific date
  static List<TimeSlot> getAvailableSlots(String providerId, DateTime date) {
    final slots = <TimeSlot>[];

    // Only show slots for today and future dates
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return slots;
    }

    // Get existing appointments for this provider on this date
    final existingAppointments = AppointmentService.getAllAppointments()
        .where(
          (apt) =>
              apt.providerId == providerId &&
              apt.status != AppointmentStatus.cancelled &&
              _isSameDay(apt.dateTime, date),
        )
        .toList();

    // Generate time slots for the day
    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += slotDurationMinutes) {
        final slotDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        // Skip past time slots for today
        if (_isSameDay(date, DateTime.now()) &&
            slotDateTime.isBefore(
              DateTime.now().add(const Duration(hours: 1)),
            )) {
          continue;
        }

        // Check if slot is already booked
        final isBooked = existingAppointments.any(
          (apt) =>
              apt.dateTime.isAtSameMomentAs(slotDateTime) ||
              (apt.dateTime.isBefore(
                    slotDateTime.add(Duration(minutes: slotDurationMinutes)),
                  ) &&
                  apt.dateTime
                      .add(Duration(minutes: apt.durationMinutes))
                      .isAfter(slotDateTime)),
        );

        // Add some unavailable slots for realism (lunch break, meetings, etc.)
        bool isUnavailable = false;
        String? reason;

        // Lunch break: 12:00 PM - 1:00 PM
        if (hour == 12) {
          isUnavailable = true;
          reason = 'Lunch break';
        }

        // Random unavailable slots for meetings/breaks
        if ((hour == 10 && minute == 30) || (hour == 15 && minute == 0)) {
          isUnavailable = true;
          reason = 'Meeting scheduled';
        }

        slots.add(
          TimeSlot(
            dateTime: slotDateTime,
            isAvailable: !isBooked && !isUnavailable,
            reason: isBooked ? 'Already booked' : reason,
          ),
        );
      }
    }

    return slots;
  }

  /// Get available dates for the next 30 days
  static List<DateTime> getAvailableDates(String providerId) {
    final availableDates = <DateTime>[];
    final today = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = today.add(Duration(days: i));

      // Skip weekends for this example
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }

      // Check if there are any available slots on this date
      final slots = getAvailableSlots(providerId, date);
      if (slots.any((slot) => slot.isAvailable)) {
        availableDates.add(date);
      }
    }

    return availableDates;
  }

  /// Check if provider is available on a specific date
  static bool isProviderAvailableOnDate(String providerId, DateTime date) {
    // Skip weekends
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }

    final slots = getAvailableSlots(providerId, date);
    return slots.any((slot) => slot.isAvailable);
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../models/message.dart';
import 'message_service.dart';
import 'provider_service.dart';

class AppointmentService {
  static const String _storageKey = 'klinate_appointments';
  static final List<Appointment> _appointments = [];

  // Stream controller to notify listeners of appointment changes
  static final StreamController<void> _appointmentChangesController =
      StreamController<void>.broadcast();

  // Stream that other widgets can listen to for appointment updates
  static Stream<void> get appointmentChanges =>
      _appointmentChangesController.stream;

  // Load appointments from storage
  static Future<void> loadAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getString(_storageKey);

      if (appointmentsJson != null) {
        final List<dynamic> appointmentsList = json.decode(appointmentsJson);
        _appointments.clear();
        _appointments.addAll(
          appointmentsList.map((json) => Appointment.fromJson(json)).toList(),
        );
      }
      // Start with empty appointments - no sample data
    } catch (e) {
      // Error loading appointments - will use empty list
    }
  }

  // Save appointments to storage
  static Future<void> _saveAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = json.encode(
        _appointments.map((appointment) => appointment.toJson()).toList(),
      );
      await prefs.setString(_storageKey, appointmentsJson);

      // Notify listeners that appointments have changed
      _appointmentChangesController.add(null);
    } catch (e) {
      // Error saving appointments - data will not persist
    }
  }

  static List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    return _appointments.where((apt) => apt.status == status).toList();
  }

  static List<Appointment> getAllAppointments() {
    // Return all appointments sorted by date (newest first)
    final allAppointments = List<Appointment>.from(_appointments);
    allAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return allAppointments;
  }

  static List<Appointment> getUpcomingAppointments() {
    return _appointments
        .where(
          (apt) =>
              apt.status == AppointmentStatus.scheduled &&
              apt.dateTime.isAfter(DateTime.now()),
        )
        .toList();
  }

  static List<Appointment> getCompletedAppointments() {
    return _appointments
        .where((apt) => apt.status == AppointmentStatus.completed)
        .toList();
  }

  static List<Appointment> getCancelledAppointments() {
    return _appointments
        .where((apt) => apt.status == AppointmentStatus.cancelled)
        .toList();
  }

  static Future<void> bookAppointment(Appointment appointment) async {
    _appointments.add(appointment);
    await _saveAppointments();

    // Send confirmation message to patient's inbox
    await MessageService.addMessage(
      senderId: 'system',
      senderName: 'Klinate System',
      content:
          'Appointment booked with ${appointment.providerName} for ${_formatDateTime(appointment.dateTime)}. ${appointment.description}',
      type: MessageType.appointment,
      category: MessageCategory.systemNotification,
    );

    // Send notification to provider's inbox
    await MessageService.addSystemNotification(
      '📅 New Appointment Scheduled\n\nPatient: ${appointment.patientName}\nDate & Time: ${_formatDateTime(appointment.dateTime)}\nType: ${appointment.description}\nCommunication: ${_getCommunicationTypeLabel(appointment.communicationType)}\nAmount: KES ${appointment.amount.toStringAsFixed(2)}',
      MessageType.appointment,
      role: MessageRole.provider, // Send to provider inbox
    );
  }

  static String _getCommunicationTypeLabel(CommunicationType type) {
    switch (type) {
      case CommunicationType.video:
        return 'Video Call';
      case CommunicationType.voice:
        return 'Voice Call';
      case CommunicationType.inPerson:
        return 'In-Person Visit';
      case CommunicationType.chat:
        return 'Chat Consultation';
    }
  }

  static Future<void> completeAppointment(String appointmentId) async {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      final appointment = _appointments[index];
      _appointments[index] = appointment.copyWith(
        status: AppointmentStatus.completed,
        endedAt: DateTime.now(),
      );
      await _saveAppointments();
    }
  }

  static Future<void> startAppointment(String appointmentId) async {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      final appointment = _appointments[index];
      _appointments[index] = appointment.copyWith(
        status: AppointmentStatus.inProgress,
        startedAt: DateTime.now(),
      );
      await _saveAppointments();
    }
  }

  static Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
  ) async {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      final appointment = _appointments[index];
      final oldDateTime = appointment.dateTime;

      // Update appointment with new date and ensure it's scheduled
      _appointments[index] = appointment.copyWith(
        dateTime: newDateTime,
        status: AppointmentStatus.scheduled, // Ensure it's scheduled
        endedAt: null, // Clear any previous end time
      );
      await _saveAppointments();

      // Send confirmation to patient's inbox
      await MessageService.addMessage(
        senderId: 'system',
        senderName: 'Klinate System',
        content:
            'Your appointment with ${appointment.providerName} has been rescheduled from ${_formatDateTime(oldDateTime)} to ${_formatDateTime(newDateTime)}.',
        type: MessageType.appointment,
        category: MessageCategory.systemNotification,
      );

      // Notify provider about the reschedule
      await MessageService.addSystemNotification(
        '🔄 Appointment Rescheduled\n\nPatient: ${appointment.patientName}\nOld Date & Time: ${_formatDateTime(oldDateTime)}\nNew Date & Time: ${_formatDateTime(newDateTime)}\nType: ${appointment.description}',
        MessageType.appointment,
        role: MessageRole.provider, // Send to provider inbox
      );
    }
  }

  static Appointment? getAppointmentById(String appointmentId) {
    try {
      return _appointments.firstWhere((apt) => apt.id == appointmentId);
    } catch (e) {
      return null;
    }
  }

  static List<Appointment> getAppointmentsByPatient(String patientEmail) {
    return _appointments
        .where((apt) => apt.patientEmail == patientEmail)
        .toList();
  }

  static List<Appointment> getAppointmentsByProvider(String providerEmail) {
    return _appointments
        .where((apt) => apt.providerEmail == providerEmail)
        .toList();
  }

  // Get unique patients for a provider (excluding other providers)
  static List<String> getUniquePatientEmailsForProvider(String providerEmail) {
    final appointments = getAppointmentsByProvider(providerEmail);
    final patientEmails = <String>{};

    for (final apt in appointments) {
      // Check if the patient is not a provider themselves
      final isPatientAProvider =
          ProviderService.getProviderByUserId(apt.patientEmail) != null;
      if (!isPatientAProvider) {
        patientEmails.add(apt.patientEmail);
      }
    }

    return patientEmails.toList();
  }

  // Get appointments for a provider, excluding appointments where patient is also a provider
  static List<Appointment> getPatientAppointmentsForProvider(
    String providerEmail,
  ) {
    final appointments = getAppointmentsByProvider(providerEmail);
    return appointments.where((apt) {
      // Exclude appointments where the patient is also a provider
      final isPatientAProvider =
          ProviderService.getProviderByUserId(apt.patientEmail) != null;
      return !isPatientAProvider;
    }).toList();
  }

  static Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        final appointment = _appointments[index];
        _appointments[index] = appointment.copyWith(
          status: AppointmentStatus.cancelled,
          endedAt: DateTime.now(),
        );
        await _saveAppointments();

        // Automatically create a message for the appointment cancellation
        await MessageService.addSystemNotification(
          'Your appointment with ${appointment.providerName} scheduled for ${_formatDateTime(appointment.dateTime)} has been cancelled.',
          MessageType.appointment,
        );

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Helper method to format date and time for messages
  static String _formatDateTime(DateTime dateTime) {
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

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour == 0
        ? 12
        : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year at $hour:$minute $period';
  }
}

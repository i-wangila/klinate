enum CommunicationType { chat, voice, video, inPerson }

enum AppointmentStatus { scheduled, inProgress, completed, cancelled, missed }

class Appointment {
  final String id;
  final String providerId;
  final String providerName;
  final String providerEmail;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final DateTime dateTime;
  final int durationMinutes;
  final CommunicationType communicationType;
  final AppointmentStatus status;
  final double amount;
  final String description;
  final String? meetingLink; // For video/voice calls
  final String? chatRoomId; // For chat sessions
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  Appointment({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerEmail,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.dateTime,
    this.durationMinutes = 30,
    required this.communicationType,
    this.status = AppointmentStatus.scheduled,
    required this.amount,
    required this.description,
    this.meetingLink,
    this.chatRoomId,
    DateTime? createdAt,
    this.startedAt,
    this.endedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'providerEmail': providerEmail,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'dateTime': dateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'communicationType': communicationType.toString(),
      'status': status.toString(),
      'amount': amount,
      'description': description,
      'meetingLink': meetingLink,
      'chatRoomId': chatRoomId,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      providerEmail: json['providerEmail'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      patientEmail: json['patientEmail'],
      dateTime: DateTime.parse(json['dateTime']),
      durationMinutes: json['durationMinutes'] ?? 30,
      communicationType: CommunicationType.values.firstWhere(
        (e) => e.toString() == json['communicationType'],
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      amount: json['amount'].toDouble(),
      description: json['description'],
      meetingLink: json['meetingLink'],
      chatRoomId: json['chatRoomId'],
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    );
  }

  // Copy with method
  Appointment copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? providerEmail,
    String? patientId,
    String? patientName,
    String? patientEmail,
    DateTime? dateTime,
    int? durationMinutes,
    CommunicationType? communicationType,
    AppointmentStatus? status,
    double? amount,
    String? description,
    String? meetingLink,
    String? chatRoomId,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerEmail: providerEmail ?? this.providerEmail,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      communicationType: communicationType ?? this.communicationType,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      meetingLink: meetingLink ?? this.meetingLink,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}

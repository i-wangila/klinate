enum MessageType {
  text,
  image,
  file,
  appointment,
  prescription,
  labResults,
  medicalReport,
  xrayReport,
  dischargeSummary,
  vaccinationRecord,
  system,
}

enum MessageCategory {
  healthcareProvider, // Interactive chats with doctors/providers
  systemNotification, // Read-only system alerts/notifications
}

enum MessageRole {
  patient, // Message belongs to patient inbox
  provider, // Message belongs to provider inbox
}

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageCategory category;
  final MessageRole role; // Which role's inbox this message belongs to
  final String? documentId; // ID of the medical record document
  bool isRead;
  bool isStarred;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.category = MessageCategory.healthcareProvider,
    this.role = MessageRole.patient, // Default to patient
    this.documentId,
    this.isRead = false,
    this.isStarred = false,
  });

  // Helper methods
  bool get isSystemNotification =>
      category == MessageCategory.systemNotification;
  bool get isHealthcareProviderMessage =>
      category == MessageCategory.healthcareProvider;
  bool get canReply => category == MessageCategory.healthcareProvider;
  bool get isMedicalRecord =>
      type == MessageType.prescription ||
      type == MessageType.labResults ||
      type == MessageType.medicalReport ||
      type == MessageType.xrayReport ||
      type == MessageType.dischargeSummary ||
      type == MessageType.vaccinationRecord;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'category': category.toString(),
      'role': role.toString(),
      'documentId': documentId,
      'isRead': isRead,
      'isStarred': isStarred,
    };
  }

  // Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      category: MessageCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => MessageCategory.healthcareProvider,
      ),
      role: MessageRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => MessageRole
            .patient, // Default to patient for backward compatibility
      ),
      documentId: json['documentId'],
      isRead: json['isRead'] ?? false,
      isStarred: json['isStarred'] ?? false,
    );
  }
}

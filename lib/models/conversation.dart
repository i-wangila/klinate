class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? participantAvatar;

  Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.participantAvatar,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'participantAvatar': participantAvatar,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participantId: json['participantId'],
      participantName: json['participantName'],
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      unreadCount: json['unreadCount'] ?? 0,
      participantAvatar: json['participantAvatar'],
    );
  }
}

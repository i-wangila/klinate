import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String _storageKey = 'klinate_chat_messages';
  static final Map<String, List<ChatMessage>> _chatRooms = {};
  static final Map<String, StreamController<List<ChatMessage>>>
  _streamControllers = {};

  // Generate consistent chat room ID for two users
  static String generateChatRoomId(String userId1, String userId2) {
    // Sort IDs to ensure consistency regardless of who initiates
    final ids = [userId1, userId2]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  // Get all conversations for a specific user
  static Future<Map<String, List<ChatMessage>>> getUserConversations(
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final conversations = <String, List<ChatMessage>>{};

    for (final key in keys) {
      if (key.startsWith(_storageKey) && key.contains(userId)) {
        final chatRoomId = key.replaceFirst('${_storageKey}_', '');
        final messages = await loadChatMessages(chatRoomId);
        if (messages.isNotEmpty) {
          conversations[chatRoomId] = messages;
        }
      }
    }

    return conversations;
  }

  // Get conversation list with last message for a user
  static Future<List<Map<String, dynamic>>> getConversationsList(
    String userId,
  ) async {
    final conversations = await getUserConversations(userId);
    final conversationsList = <Map<String, dynamic>>[];

    conversations.forEach((chatRoomId, messages) {
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        // Extract other participant ID from chat room ID
        final participantId = chatRoomId
            .replaceAll('chat_', '')
            .replaceAll(userId, '')
            .replaceAll('_', '');

        conversationsList.add({
          'chatRoomId': chatRoomId,
          'participantId': participantId,
          'participantName': lastMessage.senderName,
          'lastMessage': lastMessage.text,
          'lastMessageTime': lastMessage.timestamp,
          'unreadCount': messages.where((m) => !m.isFromUser).length,
        });
      }
    });

    // Sort by last message time (most recent first)
    conversationsList.sort(
      (a, b) => (b['lastMessageTime'] as DateTime).compareTo(
        a['lastMessageTime'] as DateTime,
      ),
    );

    return conversationsList;
  }

  // Get real-time stream for chat messages
  static Stream<List<ChatMessage>> getChatStream(String chatRoomId) {
    if (!_streamControllers.containsKey(chatRoomId)) {
      _streamControllers[chatRoomId] =
          StreamController<List<ChatMessage>>.broadcast();
    }
    return _streamControllers[chatRoomId]!.stream;
  }

  // Notify listeners of message updates
  static void _notifyListeners(String chatRoomId) {
    if (_streamControllers.containsKey(chatRoomId)) {
      _streamControllers[chatRoomId]!.add(_chatRooms[chatRoomId] ?? []);
    }
  }

  // Load chat messages for a specific chat room
  static Future<List<ChatMessage>> loadChatMessages(String chatRoomId) async {
    if (_chatRooms.containsKey(chatRoomId)) {
      return _chatRooms[chatRoomId]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final chatData = prefs.getString('${_storageKey}_$chatRoomId');

      if (chatData != null) {
        final List<dynamic> messagesList = json.decode(chatData);
        final messages = messagesList
            .map((json) => ChatMessage.fromJson(json))
            .toList();
        _chatRooms[chatRoomId] = messages;
        return messages;
      }
    } catch (e) {
      // Handle error silently
    }

    // Return empty list if no messages found
    _chatRooms[chatRoomId] = [];
    return _chatRooms[chatRoomId]!;
  }

  // Save chat messages for a specific chat room
  static Future<void> _saveChatMessages(String chatRoomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messages = _chatRooms[chatRoomId] ?? [];
      final messagesJson = json.encode(
        messages.map((message) => message.toJson()).toList(),
      );
      await prefs.setString('${_storageKey}_$chatRoomId', messagesJson);
    } catch (e) {
      // Handle save error silently
    }
  }

  // Add a message to a chat room
  static Future<void> addMessage(String chatRoomId, ChatMessage message) async {
    if (!_chatRooms.containsKey(chatRoomId)) {
      _chatRooms[chatRoomId] = [];
    }

    _chatRooms[chatRoomId]!.add(message);
    await _saveChatMessages(chatRoomId);
    _notifyListeners(chatRoomId);
  }

  // Get messages for a chat room (without loading from storage)
  static List<ChatMessage> getChatMessages(String chatRoomId) {
    return _chatRooms[chatRoomId] ?? [];
  }

  // Clear messages for a chat room
  static Future<void> clearChatMessages(String chatRoomId) async {
    _chatRooms[chatRoomId] = [];
    await _saveChatMessages(chatRoomId);
  }

  // Initialize a chat room with an initial message if it doesn't exist
  static Future<void> initializeChatRoom(
    String chatRoomId,
    String initialMessage,
    String senderName,
    String senderId,
    DateTime timestamp,
  ) async {
    final messages = await loadChatMessages(chatRoomId);

    // If no messages exist, add the initial message
    if (messages.isEmpty) {
      await addMessage(
        chatRoomId,
        ChatMessage(
          text: initialMessage,
          isFromUser: false,
          senderId: senderId,
          timestamp: timestamp,
          senderName: senderName,
        ),
      );
    }
  }
}

enum ChatMessageType { text, image, file, call, video }

class ChatMessage {
  final String text;
  final bool isFromUser;
  final String senderId; // ID of the user who sent the message
  final DateTime timestamp;
  final String senderName;
  final ChatMessageType messageType;
  final String? attachmentUrl;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.senderId,
    required this.timestamp,
    required this.senderName,
    this.messageType = ChatMessageType.text,
    this.attachmentUrl,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isFromUser': isFromUser,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
      'senderName': senderName,
      'messageType': messageType.toString(),
      'attachmentUrl': attachmentUrl,
    };
  }

  // Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isFromUser: json['isFromUser'],
      senderId: json['senderId'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      senderName: json['senderName'],
      messageType: ChatMessageType.values.firstWhere(
        (e) => e.toString() == (json['messageType'] ?? 'ChatMessageType.text'),
        orElse: () => ChatMessageType.text,
      ),
      attachmentUrl: json['attachmentUrl'],
    );
  }

  // Helper method to check if message is from current user
  bool isFromCurrentUser(String currentUserId) {
    return senderId == currentUserId;
  }
}

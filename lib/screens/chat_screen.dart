import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:io';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/call_service.dart';
import '../services/message_service.dart';
import '../services/user_service.dart';
import '../utils/responsive_utils.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final Message message;

  const ChatScreen({super.key, required this.message});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _chatMessages = [];
  late String _chatRoomId;
  StreamSubscription<List<ChatMessage>>? _chatSubscription;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Generate chat room ID based on sender ID
    _chatRoomId = 'chat_${widget.message.senderId}';
    _loadChatMessages();
    _setupChatStream();
  }

  void _setupChatStream() {
    _chatSubscription = ChatService.getChatStream(_chatRoomId).listen((
      messages,
    ) {
      if (mounted) {
        setState(() {
          _chatMessages = messages;
        });
      }
    });
  }

  Future<void> _loadChatMessages() async {
    // Initialize chat room with the original message if it doesn't exist
    await ChatService.initializeChatRoom(
      _chatRoomId,
      widget.message.content,
      widget.message.senderName,
      widget.message.senderId,
      widget.message.timestamp,
    );

    // Load all messages for this chat room
    final messages = await ChatService.loadChatMessages(_chatRoomId);

    if (mounted) {
      setState(() {
        _chatMessages = messages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveUtils.safeText(
              widget.message.senderName,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
              maxLines: 1,
            ),
            Text(
              'Online',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.videocam,
              size: ResponsiveUtils.isSmallScreen(context) ? 22 : 24,
            ),
            onPressed: () => _startVideoCall(),
          ),
          IconButton(
            icon: Icon(
              Icons.call,
              size: ResponsiveUtils.isSmallScreen(context) ? 22 : 24,
            ),
            onPressed: () => _startVoiceCall(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_chat',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear Chat History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: ResponsiveUtils.getResponsivePadding(context),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(_chatMessages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final currentUser = UserService.currentUser;
    final isMyMessage =
        currentUser != null && message.senderId == currentUser.id;

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
        ),
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getScreenWidth(context) * 0.8,
        ),
        decoration: BoxDecoration(
          color: isMyMessage ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isMyMessage
              ? Border.all(color: Colors.black, width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display file attachment if present
            if (message.attachmentUrl != null) ...[
              _buildAttachmentPreview(message),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
            ],
            // Display text message
            if (message.messageType == ChatMessageType.text ||
                message.attachmentUrl == null)
              Text(
                message.text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
                ),
                softWrap: true,
              ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview(ChatMessage message) {
    switch (message.messageType) {
      case ChatMessageType.image:
        return _buildImagePreview(message.attachmentUrl!);
      case ChatMessageType.file:
        return _buildFilePreview(message.text, message.attachmentUrl!);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImagePreview(String imagePath) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(imagePath),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: kIsWeb
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    );
                  },
                )
              : Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(String fileName, String filePath) {
    return GestureDetector(
      onTap: () => _openFile(filePath),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red[600], size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'PDF Document',
                    style: TextStyle(fontSize: 12, color: Colors.red[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.download, color: Colors.red[600], size: 20),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: kIsWeb
                    ? Image.network(imagePath)
                    : Image.file(File(imagePath)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFile(String filePath) {
    // For now, show a message that the file can be opened
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening file: ${filePath.split('/').last}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildMessageInput() {
    // Check if this message allows replies
    final canReply = widget.message.canReply;

    if (!canReply) {
      // Show read-only indicator for system notifications
      return Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[600],
              size: ResponsiveUtils.isSmallScreen(context) ? 18 : 20,
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Flexible(
              child: ResponsiveUtils.safeText(
                'This is a system notification - no replies allowed',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.attach_file,
              size: ResponsiveUtils.isSmallScreen(context) ? 22 : 24,
            ),
            onPressed: () => _showAttachmentOptions(),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
                ),
              ),
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.black,
                size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final messageText = _messageController.text.trim();
      _messageController.clear();

      // Add user message (from current user - could be provider or patient)
      final currentUser = UserService.currentUser;
      final userMessage = ChatMessage(
        text: messageText,
        isFromUser: true,
        senderId: currentUser?.id ?? '',
        timestamp: DateTime.now(),
        senderName: 'You',
        messageType: ChatMessageType.text,
      );

      await ChatService.addMessage(_chatRoomId, userMessage);

      // Update or create conversation in provider's inbox
      if (currentUser != null) {
        await _updateProviderInboxConversation(
          currentUser.id,
          currentUser.name,
          messageText,
        );
      }

      // Show sent confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.black,
          ),
        );
      }
    }
  }

  void _startVideoCall() async {
    try {
      final callSession = await CallService.startCall(
        providerId: widget.message.senderId,
        providerName: widget.message.senderName,
        callType: CallType.video,
        patientId: 'current_user',
        patientName: 'You',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(callSession: callSession),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start video call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startVoiceCall() async {
    try {
      final callSession = await CallService.startCall(
        providerId: widget.message.senderId,
        providerName: widget.message.senderName,
        callType: CallType.voice,
        patientId: 'current_user',
        patientName: 'You',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(callSession: callSession),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start voice call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Send Attachment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImageFromCamera(),
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImageFromGallery(),
                ),
                _buildAttachmentOption(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  onTap: () => _pickPdfDocument(),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      Navigator.pop(context); // Close bottom sheet

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendFileMessage(image.path, image.name, ChatMessageType.image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image from camera');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      Navigator.pop(context); // Close bottom sheet

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendFileMessage(image.path, image.name, ChatMessageType.image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery');
    }
  }

  Future<void> _pickPdfDocument() async {
    try {
      Navigator.pop(context); // Close bottom sheet

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          await _sendFileMessage(file.path!, file.name, ChatMessageType.file);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick PDF document');
    }
  }

  Future<void> _sendFileMessage(
    String filePath,
    String fileName,
    ChatMessageType messageType,
  ) async {
    try {
      // Create a message with file attachment
      final currentUser = UserService.currentUser;
      final fileMessage = ChatMessage(
        text: fileName, // Use filename as message text
        isFromUser: true,
        senderId: currentUser?.id ?? '',
        timestamp: DateTime.now(),
        senderName: 'You',
        messageType: messageType,
        attachmentUrl: filePath,
      );

      await ChatService.addMessage(_chatRoomId, fileMessage);

      // Update conversation in provider's inbox
      if (currentUser != null) {
        final messageContent = messageType == ChatMessageType.image
            ? '📷 Sent an image: $fileName'
            : '📎 Sent a file: $fileName';
        await _updateProviderInboxConversation(
          currentUser.id,
          currentUser.name,
          messageContent,
        );
      }

      _showSuccessSnackBar(
        '${messageType == ChatMessageType.image ? 'Image' : 'Document'} sent successfully',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to send file');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_chat':
        _showClearChatDialog();
        break;
    }
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text(
          'Are you sure you want to clear all messages in this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();

              // Clear chat messages
              await ChatService.clearChatMessages(_chatRoomId);

              // Reload messages (will be empty)
              final messages = await ChatService.loadChatMessages(_chatRoomId);
              if (mounted) {
                setState(() {
                  _chatMessages = messages;
                });

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Chat history cleared'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // Update or create conversation entry in provider's inbox
  Future<void> _updateProviderInboxConversation(
    String senderId,
    String senderName,
    String latestMessage,
  ) async {
    // Create a consistent conversation ID using sorted IDs to ensure same conversation
    // regardless of who initiates the chat
    final ids = [senderId, widget.message.senderId]..sort();
    final conversationId = 'conversation_${ids[0]}_${ids[1]}';

    // Update or create the conversation in MessageService
    await MessageService.updateOrCreateConversation(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      content: latestMessage,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatSubscription?.cancel();
    super.dispose();
  }
}

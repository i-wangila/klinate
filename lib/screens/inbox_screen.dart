import 'package:flutter/material.dart';
import '../services/message_service.dart';
import '../models/message.dart';
import '../utils/responsive_utils.dart';
import 'chat_screen.dart';
import 'notification_chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    // Force save messages when screen is disposed
    MessageService.forceSave();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    await MessageService.loadMessages();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get all messages - unified inbox for both patients and providers
    final messages = MessageService.getAllMessages();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Inbox',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          24,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: ResponsiveUtils.isSmallScreen(context) ? 22 : 24,
                    ),
                    onSelected: _handleMenuAction,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'mark_all_read',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mark_email_read, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Mark All as Read'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_sweep, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Clear All Messages'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: ResponsiveUtils.flexibleContainer(
                        context: context,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: ResponsiveUtils.isSmallScreen(context)
                                  ? 60
                                  : 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                16,
                              ),
                            ),
                            ResponsiveUtils.safeText(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  16,
                                ),
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildMessageCard(message);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(Message message) {
    final timeAgo = _getTimeAgo(message.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: !message.isRead ? 3 : 1,
      color: message.isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMessageTypeColor(
            message.type,
          ).withValues(alpha: 0.1),
          child: Icon(
            _getMessageIcon(message.type),
            color: _getMessageTypeColor(message.type),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontWeight: !message.isRead
                      ? FontWeight.bold
                      : FontWeight.w600,
                ),
              ),
            ),
            // Star icon
            GestureDetector(
              onTap: () => _toggleStar(message),
              child: Icon(
                message.isStarred ? Icons.star : Icons.star_border,
                color: message.isStarred ? Colors.amber : Colors.grey[400],
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            if (!message.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 4),
            // Show appropriate badge based on message category
            if (message.isHealthcareProviderMessage)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _openMessage(message),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: (value) => _handleMessageAction(value, message),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'star',
              child: Row(
                children: [
                  Icon(
                    message.isStarred ? Icons.star_border : Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Text(message.isStarred ? 'Unstar' : 'Star'),
                ],
              ),
            ),
            if (!message.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Mark as Read'),
                  ],
                ),
              ),
            if (message.isRead)
              const PopupMenuItem(
                value: 'mark_unread',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_unread, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Mark as Unread'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Message'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _openMessage(Message message) async {
    // Mark message as read when opened
    if (!message.isRead) {
      await MessageService.markAsRead(message.id);
      if (mounted) {
        setState(() {});
      }
    }

    if (!mounted) return;

    // Use the new message category to determine navigation
    if (message.isSystemNotification) {
      // Open notification chat screen (read-only) for system notifications
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationChatScreen(message: message),
        ),
      );
    } else {
      // Open interactive chat screen for healthcare provider messages
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(message: message)),
      );
    }
  }

  IconData _getMessageIcon(MessageType type) {
    switch (type) {
      case MessageType.appointment:
        return Icons.calendar_today;
      case MessageType.prescription:
        return Icons.medication;
      case MessageType.labResults:
        return Icons.science;
      case MessageType.medicalReport:
        return Icons.description;
      case MessageType.xrayReport:
        return Icons.medical_information;
      case MessageType.dischargeSummary:
        return Icons.local_hospital;
      case MessageType.vaccinationRecord:
        return Icons.vaccines;
      case MessageType.system:
        return Icons.info;
      case MessageType.image:
        return Icons.image;
      case MessageType.file:
        return Icons.attach_file;
      default:
        return Icons.message;
    }
  }

  Color _getMessageTypeColor(MessageType type) {
    switch (type) {
      case MessageType.appointment:
        return Colors.grey[700]!;
      case MessageType.prescription:
      case MessageType.labResults:
      case MessageType.medicalReport:
      case MessageType.xrayReport:
      case MessageType.dischargeSummary:
      case MessageType.vaccinationRecord:
        return Colors.grey[700]!;
      case MessageType.system:
        return Colors.grey[700]!;
      case MessageType.image:
        return Colors.grey[700]!;
      case MessageType.file:
        return Colors.grey[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  void _handleMessageAction(String action, Message message) {
    switch (action) {
      case 'star':
        _toggleStar(message);
        break;
      case 'mark_read':
        _markMessageAsRead(message.id);
        break;
      case 'mark_unread':
        _markMessageAsUnread(message.id);
        break;
      case 'delete':
        _deleteMessage(message);
        break;
    }
  }

  Future<void> _toggleStar(Message message) async {
    await MessageService.toggleStar(message.id);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isStarred ? 'Message starred' : 'Message unstarred',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _markMessageAsRead(String messageId) async {
    await MessageService.markAsRead(messageId);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _markMessageAsUnread(String messageId) async {
    await MessageService.markAsUnread(messageId);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message marked as unread'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    await MessageService.markAllAsRead();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All messages marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showClearAllDialog() {
    final starredCount = MessageService.getStarredMessages().length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Messages'),
        content: Text(
          starredCount > 0
              ? 'Are you sure you want to delete all messages? Starred messages ($starredCount) will be kept.'
              : 'Are you sure you want to delete all messages? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllMessages();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text(
          'Are you sure you want to delete this message from ${message.senderName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessageById(message.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllMessages() async {
    final starredCount = MessageService.getStarredMessages().length;
    await MessageService.clearAllMessages();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            starredCount > 0
                ? 'All messages cleared. $starredCount starred message${starredCount > 1 ? 's' : ''} kept.'
                : 'All messages cleared',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteMessageById(String messageId) async {
    await MessageService.deleteMessage(messageId);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../services/message_service.dart';
import '../models/message.dart';
import 'chat_screen.dart';
import 'notification_chat_screen.dart';

// DEPRECATED: This screen is no longer used. All messages now appear in the unified InboxScreen
// for both patients and providers. This file is kept for reference only.
class ProviderInboxScreen extends StatefulWidget {
  const ProviderInboxScreen({super.key});

  @override
  State<ProviderInboxScreen> createState() => _ProviderInboxScreenState();
}

class _ProviderInboxScreenState extends State<ProviderInboxScreen> {
  @override
  void initState() {
    super.initState();
    _loadMessages();
    MessageService.addListener(_onMessageUpdate);
  }

  @override
  void dispose() {
    MessageService.removeListener(_onMessageUpdate);
    super.dispose();
  }

  void _onMessageUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadMessages() async {
    await MessageService.loadMessages();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get only provider role messages for provider inbox
    final messages = MessageService.getProviderMessages();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inbox',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Messages & Notifications',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Mark All as Read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.black),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Messages and notifications will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageCard(messages[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(Message message) {
    final timeAgo = _getTimeAgo(message.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: !message.isRead ? 2 : 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: !message.isRead ? Colors.black : Colors.grey[300]!,
          width: !message.isRead ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(_getMessageIcon(message.type), color: Colors.black),
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
            if (!message.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                message.isHealthcareProviderMessage ? 'Chat' : 'Alert',
                style: const TextStyle(
                  color: Colors.black,
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
            if (!message.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, color: Colors.black),
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
                    Icon(Icons.mark_email_unread, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Mark as Unread'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.black),
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
    if (!message.isRead) {
      await MessageService.markAsRead(message.id);
      if (mounted) {
        setState(() {});
      }
    }

    if (!mounted) return;

    if (message.isSystemNotification) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationChatScreen(message: message),
        ),
      );
    } else {
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

  Future<void> _markMessageAsRead(String messageId) async {
    await MessageService.markAsRead(messageId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _markMessageAsUnread(String messageId) async {
    await MessageService.markAsUnread(messageId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _markAllAsRead() async {
    await MessageService.markAllAsRead();
    if (mounted) {
      setState(() {});
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Messages'),
        content: const Text(
          'Are you sure you want to delete all messages? This action cannot be undone.',
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
            style: TextButton.styleFrom(foregroundColor: Colors.black),
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
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllMessages() async {
    await MessageService.clearAllMessages();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteMessageById(String messageId) async {
    await MessageService.deleteMessage(messageId);
    if (mounted) {
      setState(() {});
    }
  }
}

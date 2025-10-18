import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../models/house_model.dart';
import '../../models/message_model.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  final AgentInfo? agent;
  final HouseData? property;

  const MessagingScreen({
    super.key,
    this.agent,
    this.property,
  });

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // Mock data - in a real app, this would come from an API
  final List<Message> _messages = [
    Message(
      id: '1',
      senderId: 'agent1',
      receiverId: 'user1',
      content: 'Hello! I saw you were interested in the property on Main Street. Would you like to schedule a viewing?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      propertyId: '1',
    ),
    Message(
      id: '2',
      senderId: 'user1',
      receiverId: 'agent1',
      content: 'Yes, I\'d love to see it! When would be a good time?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isRead: true,
      propertyId: '1',
    ),
    Message(
      id: '3',
      senderId: 'agent1',
      receiverId: 'user1',
      content: 'How about tomorrow at 2 PM? I can show you the property and answer any questions you might have.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: true,
      propertyId: '1',
    ),
    Message(
      id: '4',
      senderId: 'user1',
      receiverId: 'agent1',
      content: 'Perfect! I\'ll see you tomorrow at 2 PM. Thank you!',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      propertyId: '1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'user1', // Current user ID
        receiverId: widget.agent?.id ?? 'agent1',
        content: _messageController.text.trim(),
        type: MessageType.text,
        timestamp: DateTime.now(),
        isRead: false,
        propertyId: widget.property?.id.toString(),
      );

      setState(() {
        _messages.add(message);
      });

      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.agent?.name ?? 'Agent',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.agent != null)
              Text(
                widget.agent!.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.agent!.isOnline ? Colors.green : Colors.grey,
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.strong,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _showContactOptions(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Property Info (if available)
          if (widget.property != null) _buildPropertyInfo(),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == 'user1';
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildPropertyInfo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      color: AppColors.lightGray,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://via.placeholder.com/80x60',
              width: 20.w,
              height: 15.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${widget.property!.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: AppTypography.title02.copyWith(
                    color: AppColors.strong,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.property!.bedrooms} bed • ${widget.property!.bathrooms} bath • ${widget.property!.size} sq ft',
                  style: AppTypography.body.copyWith(
                    color: AppColors.medium,
                  ),
                ),
                Text(
                  '${widget.property!.zip} ${widget.property!.city}',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 4.w,
              backgroundColor: AppColors.medium,
              child: Icon(
                Icons.person,
                color: AppColors.white,
                size: 4.w,
              ),
            ),
            SizedBox(width: 2.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isMe ? AppColors.strong : AppColors.lightGray,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.body.copyWith(
                      color: isMe ? AppColors.white : AppColors.strong,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTypography.detail.copyWith(
                      color: isMe ? AppColors.white.withOpacity(0.7) : AppColors.medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 2.w),
            CircleAvatar(
              radius: 4.w,
              backgroundColor: AppColors.strong,
              child: Icon(
                Icons.person,
                color: AppColors.white,
                size: 4.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.medium.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () => _showAttachmentOptions(),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.medium),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 2.w),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: AppColors.strong,
            mini: true,
            child: const Icon(Icons.send, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call'),
              subtitle: Text(widget.agent?.phone ?? ''),
              onTap: () {
                Navigator.pop(context);
                // Implement phone call functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(widget.agent?.email ?? ''),
              onTap: () {
                Navigator.pop(context);
                // Implement email functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                // Implement video call functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('View Property Details'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to property details
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule Viewing'),
              onTap: () {
                Navigator.pop(context);
                // Implement schedule viewing functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Property'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block Agent'),
              onTap: () {
                Navigator.pop(context);
                // Implement block functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                // Implement photo attachment
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                // Implement video attachment
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                // Implement document attachment
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location'),
              onTap: () {
                Navigator.pop(context);
                // Implement location sharing
              },
            ),
          ],
        ),
      ),
    );
  }
}
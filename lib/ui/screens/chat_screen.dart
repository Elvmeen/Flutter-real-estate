import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../application/messaging_provider.dart';
import '../../models/message_model.dart';
import '../theme/colors.dart';
import '../theme/type.dart';
import '../components/error_state.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({Key? key, required this.conversationId}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read when entering chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider.notifier).markMessagesAsRead(widget.conversationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesValue = ref.watch(conversationMessagesProvider(widget.conversationId));
    final conversation = ref.watch(conversationProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.strong,
        foregroundColor: Colors.white,
        title: conversation.when(
          data: (conv) => Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: _getAgentImage(conv?.participantIds.firstWhere(
                  (id) => id != 'current_user',
                  orElse: () => '1',
                ) ?? '1'),
                child: _getAgentImage(conv?.participantIds.firstWhere(
                  (id) => id != 'current_user',
                  orElse: () => '1',
                ) ?? '1') == null
                    ? Icon(Icons.person, color: Colors.white, size: 16)
                    : null,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAgentName(conv?.participantIds.firstWhere(
                        (id) => id != 'current_user',
                        orElse: () => '1',
                      ) ?? '1'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => Text('Loading...'),
          error: (_, __) => Text('Chat'),
        ),
        actions: [
          IconButton(
            onPressed: () => _showChatOptions(context),
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesValue.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppColors.medium,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Start the conversation',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(4.w),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == 'current_user';
                    
                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: ErrorState()),
            ),
          ),
          
          // Message input
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showAttachmentOptions(context),
                  icon: Icon(Icons.add, color: AppColors.medium),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTypography.hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGray,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.strong,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = MessageData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: widget.conversationId,
      senderId: 'current_user',
      receiverId: 'agent_id', // In real app, get from conversation
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    ref.read(messagesProvider.notifier).sendMessage(message);
    _messageController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.strong),
              title: Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                // Implement photo selection
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.strong),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                // Implement camera
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: AppColors.strong),
              title: Text('Share Property'),
              onTap: () {
                Navigator.pop(context);
                // Implement property sharing
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: AppColors.strong),
              title: Text('View Agent Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to agent profile
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: AppColors.strong),
              title: Text('Schedule Tour'),
              onTap: () {
                Navigator.pop(context);
                _schedulePropertyTour();
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Block User'),
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

  void _schedulePropertyTour() {
    // Send a tour scheduling message
    final message = MessageData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: widget.conversationId,
      senderId: 'current_user',
      receiverId: 'agent_id',
      content: 'I would like to schedule a property tour. When are you available?',
      type: MessageType.scheduleTour,
      timestamp: DateTime.now(),
    );

    ref.read(messagesProvider.notifier).sendMessage(message);
  }

  ImageProvider? _getAgentImage(String agentId) {
    final imageUrls = {
      '1': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      '2': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      '3': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    };
    
    final imageUrl = imageUrls[agentId];
    return imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null;
  }

  String _getAgentName(String agentId) {
    final names = {
      '1': 'Sarah Johnson',
      '2': 'Michael Chen',
      '3': 'Emily Rodriguez',
    };
    
    return names[agentId] ?? 'Agent';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final MessageData message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.lightGray,
              child: Icon(Icons.person, size: 16, color: AppColors.medium),
            ),
            SizedBox(width: 2.w),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 70.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: isMe ? AppColors.strong : AppColors.lightGray,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message type indicator
                  if (message.type != MessageType.text)
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getMessageTypeIcon(message.type),
                            size: 14,
                            color: isMe ? Colors.white70 : AppColors.medium,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _getMessageTypeLabel(message.type),
                            style: TextStyle(
                              fontSize: 12,
                              color: isMe ? Colors.white70 : AppColors.medium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Message content
                  Text(
                    message.content,
                    style: AppTypography.body.copyWith(
                      color: isMe ? Colors.white : AppColors.strong,
                    ),
                  ),
                  
                  SizedBox(height: 0.5.h),
                  
                  // Timestamp
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : AppColors.medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) ...[
            SizedBox(width: 2.w),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.strong.withOpacity(0.2),
              child: Icon(Icons.person, size: 16, color: AppColors.strong),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getMessageTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.message;
      case MessageType.image:
        return Icons.photo;
      case MessageType.propertyInquiry:
        return Icons.home;
      case MessageType.scheduleTour:
        return Icons.schedule;
      case MessageType.makeOffer:
        return Icons.attach_money;
    }
  }

  String _getMessageTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'Message';
      case MessageType.image:
        return 'Photo';
      case MessageType.propertyInquiry:
        return 'Property Inquiry';
      case MessageType.scheduleTour:
        return 'Tour Request';
      case MessageType.makeOffer:
        return 'Offer';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
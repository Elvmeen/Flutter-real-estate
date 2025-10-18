import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../application/messaging_provider.dart';
import '../../models/message_model.dart';
import '../../models/house_model.dart';
import '../theme/colors.dart';
import '../theme/type.dart';
import '../components/error_state.dart';
import 'chat_screen.dart';

class MessagesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsValue = ref.watch(conversationsProvider);

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Messages', style: AppTypography.title02),
              IconButton(
                onPressed: () => _showNewMessageDialog(context, ref),
                icon: Icon(Icons.add_comment, color: AppColors.strong),
              ),
            ],
          ),
        ),
        
        // Conversations list
        Expanded(
          child: conversationsValue.when(
            data: (conversations) {
              if (conversations.isEmpty) {
                return _buildEmptyState(context);
              }
              
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ConversationCard(conversation: conversation);
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: ErrorState()),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.medium,
          ),
          SizedBox(height: 2.h),
          Text('No Messages Yet', style: AppTypography.title02),
          SizedBox(height: 1.h),
          Text(
            'Start a conversation with an agent or property owner.',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => _showNewMessageDialog(context, null),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strong,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Start New Conversation'),
          ),
        ],
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context, WidgetRef? ref) {
    showDialog(
      context: context,
      builder: (context) => NewMessageDialog(),
    );
  }
}

class ConversationCard extends ConsumerWidget {
  final ConversationData conversation;

  const ConversationCard({Key? key, required this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get agent info for the conversation
    final agentId = conversation.participantIds.firstWhere(
      (id) => id != 'current_user',
      orElse: () => '1',
    );
    
    return Card(
      margin: EdgeInsets.only(bottom: 1.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversationId: conversation.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              // Agent avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.lightGray,
                    backgroundImage: _getAgentImage(agentId),
                    child: _getAgentImage(agentId) == null
                        ? Icon(Icons.person, color: AppColors.medium)
                        : null,
                  ),
                  if (conversation.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${conversation.unreadCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(width: 3.w),
              
              // Conversation info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _getAgentName(agentId),
                            style: AppTypography.title02,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(conversation.lastActivity),
                          style: AppTypography.detail,
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    
                    // Last message preview
                    if (conversation.lastMessage != null)
                      Text(
                        _getMessagePreview(conversation.lastMessage!),
                        style: AppTypography.body.copyWith(
                          color: conversation.unreadCount > 0 
                              ? AppColors.strong 
                              : AppColors.medium,
                          fontWeight: conversation.unreadCount > 0 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    // Property info if applicable
                    if (conversation.propertyId != null) ...[
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(Icons.home, size: 14, color: AppColors.medium),
                          SizedBox(width: 1.w),
                          Text(
                            'Property #${conversation.propertyId}',
                            style: AppTypography.detail,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getAgentImage(String agentId) {
    // In a real app, this would fetch from agent data
    final imageUrls = {
      '1': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      '2': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      '3': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    };
    
    final imageUrl = imageUrls[agentId];
    return imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null;
  }

  String _getAgentName(String agentId) {
    // In a real app, this would fetch from agent data
    final names = {
      '1': 'Sarah Johnson',
      '2': 'Michael Chen',
      '3': 'Emily Rodriguez',
    };
    
    return names[agentId] ?? 'Agent';
  }

  String _getMessagePreview(MessageData message) {
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Image';
      case MessageType.propertyInquiry:
        return '🏠 Property inquiry';
      case MessageType.scheduleTour:
        return '📅 Tour request';
      case MessageType.makeOffer:
        return '💰 Offer submitted';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class NewMessageDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends ConsumerState<NewMessageDialog> {
  String? _selectedAgentId;
  String? _selectedPropertyId;
  MessageType _messageType = MessageType.text;
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Message'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Agent selection
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Agent'),
              value: _selectedAgentId,
              items: [
                DropdownMenuItem(value: '1', child: Text('Sarah Johnson')),
                DropdownMenuItem(value: '2', child: Text('Michael Chen')),
                DropdownMenuItem(value: '3', child: Text('Emily Rodriguez')),
              ],
              onChanged: (value) => setState(() => _selectedAgentId = value),
            ),
            
            SizedBox(height: 2.h),
            
            // Message type
            DropdownButtonFormField<MessageType>(
              decoration: InputDecoration(labelText: 'Message Type'),
              value: _messageType,
              items: [
                DropdownMenuItem(
                  value: MessageType.text,
                  child: Text('General Message'),
                ),
                DropdownMenuItem(
                  value: MessageType.propertyInquiry,
                  child: Text('Property Inquiry'),
                ),
                DropdownMenuItem(
                  value: MessageType.scheduleTour,
                  child: Text('Schedule Tour'),
                ),
              ],
              onChanged: (value) => setState(() => _messageType = value!),
            ),
            
            SizedBox(height: 2.h),
            
            // Property selection (if applicable)
            if (_messageType == MessageType.propertyInquiry ||
                _messageType == MessageType.scheduleTour)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Select Property'),
                value: _selectedPropertyId,
                items: [
                  DropdownMenuItem(value: '1', child: Text('Property #1')),
                  DropdownMenuItem(value: '2', child: Text('Property #2')),
                  DropdownMenuItem(value: '3', child: Text('Property #3')),
                ],
                onChanged: (value) => setState(() => _selectedPropertyId = value),
              ),
            
            if (_messageType == MessageType.propertyInquiry ||
                _messageType == MessageType.scheduleTour)
              SizedBox(height: 2.h),
            
            // Message content
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: _getMessageHint(),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sendMessage,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.strong),
          child: Text('Send'),
        ),
      ],
    );
  }

  String _getMessageHint() {
    switch (_messageType) {
      case MessageType.text:
        return 'Type your message here...';
      case MessageType.propertyInquiry:
        return 'I\'m interested in this property...';
      case MessageType.scheduleTour:
        return 'I\'d like to schedule a tour...';
      default:
        return 'Type your message here...';
    }
  }

  void _sendMessage() {
    if (_selectedAgentId == null || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Create new conversation and message
    final conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    final messageId = '${conversationId}_1';
    
    final message = MessageData(
      id: messageId,
      conversationId: conversationId,
      senderId: 'current_user',
      receiverId: _selectedAgentId!,
      content: _messageController.text,
      type: _messageType,
      timestamp: DateTime.now(),
      propertyId: _selectedPropertyId,
    );
    
    ref.read(messagesProvider.notifier).sendMessage(message);
    
    Navigator.pop(context);
    
    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversationId: conversationId),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
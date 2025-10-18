import 'package:flutter/material.dart';
import 'package:flutter_real_estate/application/messages_provider.dart';
import 'package:flutter_real_estate/ui/components/top_app_bar.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int contactId;
  final String contactName;
  final int? propertyId;
  final String? propertyTitle;

  const ChatScreen({
    Key? key,
    required this.contactId,
    required this.contactName,
    this.propertyId,
    this.propertyTitle,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      ref.read(messagesProvider.notifier).sendMessage(
        recipientId: widget.contactId,
        recipientName: widget.contactName,
        content: content,
        propertyId: widget.propertyId,
        propertyTitle: widget.propertyTitle,
      );
      _messageController.clear();
      // Scroll to bottom after sending
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesNotifier = ref.watch(messagesProvider.notifier);
    final messages = messagesNotifier.getConversationWith(widget.contactId);

    return Scaffold(
      appBar: TopAppBar(title: widget.contactName),
      body: Column(
        children: [
          // Property context banner if applicable
          if (widget.propertyTitle != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              color: AppColors.lightGray,
              child: Row(
                children: [
                  Icon(Icons.home, color: AppColors.medium, size: 20),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'About: ${widget.propertyTitle}',
                      style: AppTypography.detail.copyWith(
                        color: AppColors.strong,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'Start a conversation',
                      style: AppTypography.body.copyWith(
                        color: AppColors.medium,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message.senderId == 0;
                      return _buildMessageBubble(message, isCurrentUser);
                    },
                  ),
          ),
          // Message input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTypography.hint,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.5.h,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.strong,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: AppColors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, bool isCurrentUser) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) SizedBox(width: 2.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppColors.strong : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.body.copyWith(
                      color: isCurrentUser ? AppColors.white : AppColors.strong,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: AppTypography.detail.copyWith(
                      color: isCurrentUser
                          ? AppColors.white.withOpacity(0.7)
                          : AppColors.medium,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) SizedBox(width: 2.w),
        ],
      ),
    );
  }
}

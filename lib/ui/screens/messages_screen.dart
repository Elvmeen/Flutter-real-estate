import 'package:flutter/material.dart';
import 'package:flutter_real_estate/application/messages_provider.dart';
import 'package:flutter_real_estate/ui/screens/chat_screen.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesNotifier = ref.watch(messagesProvider.notifier);
    final conversations = messagesNotifier.getConversations();

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 80,
              color: AppColors.medium,
            ),
            SizedBox(height: 2.h),
            Text(
              'No messages yet',
              style: AppTypography.title02,
            ),
            SizedBox(height: 1.h),
            Text(
              'Start a conversation with an agent',
              style: AppTypography.body.copyWith(
                color: AppColors.medium,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return Card(
          margin: EdgeInsets.only(bottom: 1.h),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    contactId: conversation.contactId,
                    contactName: conversation.contactName,
                  ),
                ),
              );
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.strong,
              child: Text(
                conversation.contactName[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.contactName,
                    style: AppTypography.title02,
                  ),
                ),
                Text(
                  _formatTime(conversation.lastMessageTime),
                  style: AppTypography.detail.copyWith(
                    color: AppColors.medium,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.lastMessage,
                    style: AppTypography.body.copyWith(
                      color: conversation.hasUnread ? AppColors.strong : AppColors.medium,
                      fontWeight: conversation.hasUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (conversation.hasUnread)
                  Container(
                    margin: EdgeInsets.only(left: 2.w),
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppColors.strong,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      conversation.unreadCount.toString(),
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(timestamp);
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

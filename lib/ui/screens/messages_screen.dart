import 'package:flutter/material.dart';
import 'package:flutter_real_estate/application/messages_provider.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);
    final unreadCount = ref.watch(unreadMessagesCountProvider);

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Messages',
            style: AppTypography.title01,
          ),
          SizedBox(height: 1.h),
          if (unreadCount > 0)
            Text(
              '$unreadCount unread ${unreadCount == 1 ? 'message' : 'messages'}',
              style: AppTypography.detail.copyWith(color: AppColors.strong),
            ),
          SizedBox(height: 2.h),
          Expanded(
            child: messages.isEmpty
                ? Center(
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
                          style: AppTypography.title02.copyWith(color: AppColors.medium),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Start a conversation with an agent!',
                          style: AppTypography.body.copyWith(color: AppColors.medium),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageCard(
                        message: message,
                        onTap: () {
                          ref.read(messagesProvider.notifier).markAsRead(message.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final message;
  final VoidCallback onTap;

  const MessageCard({Key? key, required this.message, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: message.isRead ? AppColors.white : AppColors.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: message.isRead ? AppColors.lightGray : AppColors.strong.withOpacity(0.3),
            width: message.isRead ? 1 : 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender photo
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CachedNetworkImage(
                imageUrl: message.senderPhoto,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 50,
                  height: 50,
                  color: AppColors.darkGray,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 50,
                  height: 50,
                  color: AppColors.darkGray,
                  child: const Icon(Icons.person),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message.senderName,
                          style: AppTypography.title02,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeago.format(message.timestamp),
                        style: AppTypography.detail.copyWith(color: AppColors.medium),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    message.propertyTitle,
                    style: AppTypography.detail.copyWith(
                      color: AppColors.strong,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    message.message,
                    style: AppTypography.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!message.isRead)
              Container(
                margin: EdgeInsets.only(left: 2.w),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.strong,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

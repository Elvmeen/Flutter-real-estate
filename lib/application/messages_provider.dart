import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_model.dart';

// StateNotifier to manage messages
class MessagesNotifier extends StateNotifier<List<MessageData>> {
  MessagesNotifier() : super(_initialMessages);

  static final List<MessageData> _initialMessages = [
    MessageData(
      id: 1,
      senderName: 'Sarah Johnson',
      senderPhoto: 'https://i.pravatar.cc/150?img=1',
      message: 'Hi! I saw you were interested in the luxury home. Would you like to schedule a viewing?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      propertyTitle: 'Luxury Villa in Beverly Hills',
    ),
    MessageData(
      id: 2,
      senderName: 'Michael Chen',
      senderPhoto: 'https://i.pravatar.cc/150?img=12',
      message: 'The commercial property you inquired about is still available. Let me know if you have any questions!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      propertyTitle: 'Downtown Office Space',
    ),
    MessageData(
      id: 3,
      senderName: 'Emily Rodriguez',
      senderPhoto: 'https://i.pravatar.cc/150?img=5',
      message: 'I have some great options for first-time buyers. Would you like to discuss your budget and preferences?',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      propertyTitle: 'Starter Home Consultation',
    ),
  ];

  // Mark a message as read
  void markAsRead(int messageId) {
    state = state.map((message) {
      if (message.id == messageId) {
        return MessageData(
          id: message.id,
          senderName: message.senderName,
          senderPhoto: message.senderPhoto,
          message: message.message,
          timestamp: message.timestamp,
          isRead: true,
          propertyTitle: message.propertyTitle,
        );
      }
      return message;
    }).toList();
  }

  // Add a new message
  void addMessage(MessageData message) {
    state = [message, ...state];
  }

  // Get unread messages count
  int get unreadCount => state.where((message) => !message.isRead).length;
}

// Provider for messages
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<MessageData>>((ref) {
  return MessagesNotifier();
});

// Provider for unread messages count
final unreadMessagesCountProvider = Provider<int>((ref) {
  final messages = ref.watch(messagesProvider);
  return messages.where((message) => !message.isRead).length;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';

// State notifier for managing messages
class MessagesNotifier extends StateNotifier<List<MessageData>> {
  MessagesNotifier() : super(_getInitialMessages());

  static List<MessageData> _getInitialMessages() {
    // Simulated initial messages
    return [
      MessageData(
        id: 1,
        senderId: 1,
        recipientId: 0,
        senderName: 'Sarah Johnson',
        recipientName: 'You',
        content: 'Hi! I saw you\'re interested in the property. Would you like to schedule a viewing?',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        isRead: false,
        propertyTitle: 'Beautiful Family Home',
        propertyId: 1,
      ),
      MessageData(
        id: 2,
        senderId: 2,
        recipientId: 0,
        senderName: 'Michael Chen',
        recipientName: 'You',
        content: 'Thank you for your inquiry. The property is still available.',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        isRead: true,
        propertyTitle: 'Downtown Apartment',
        propertyId: 2,
      ),
    ];
  }

  // Send a new message
  void sendMessage({
    required int recipientId,
    required String recipientName,
    required String content,
    int? propertyId,
    String? propertyTitle,
  }) {
    final newMessage = MessageData(
      id: state.length + 1,
      senderId: 0, // Current user
      recipientId: recipientId,
      senderName: 'You',
      recipientName: recipientName,
      content: content,
      timestamp: DateTime.now(),
      isRead: true,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
    );

    state = [...state, newMessage];
  }

  // Mark message as read
  void markAsRead(int messageId) {
    state = state.map((msg) {
      if (msg.id == messageId) {
        return MessageData(
          id: msg.id,
          senderId: msg.senderId,
          recipientId: msg.recipientId,
          senderName: msg.senderName,
          recipientName: msg.recipientName,
          content: msg.content,
          timestamp: msg.timestamp,
          isRead: true,
          propertyId: msg.propertyId,
          propertyTitle: msg.propertyTitle,
        );
      }
      return msg;
    }).toList();
  }

  // Get conversations grouped by contact
  List<ConversationPreview> getConversations() {
    final Map<int, List<MessageData>> grouped = {};
    
    for (var message in state) {
      final contactId = message.senderId == 0 ? message.recipientId : message.senderId;
      if (!grouped.containsKey(contactId)) {
        grouped[contactId] = [];
      }
      grouped[contactId]!.add(message);
    }

    return grouped.entries.map((entry) {
      final messages = entry.value..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final lastMessage = messages.first;
      final unreadMessages = messages.where((m) => !m.isRead && m.senderId != 0).toList();
      
      return ConversationPreview(
        contactId: entry.key,
        contactName: lastMessage.senderId == 0 ? lastMessage.recipientName : lastMessage.senderName,
        lastMessage: lastMessage.content,
        lastMessageTime: lastMessage.timestamp,
        hasUnread: unreadMessages.isNotEmpty,
        unreadCount: unreadMessages.length,
      );
    }).toList()..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  // Get messages with a specific contact
  List<MessageData> getConversationWith(int contactId) {
    return state
        .where((msg) => 
            (msg.senderId == contactId && msg.recipientId == 0) ||
            (msg.senderId == 0 && msg.recipientId == contactId))
        .toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Delete a message
  void deleteMessage(int messageId) {
    state = state.where((msg) => msg.id != messageId).toList();
  }
}

// Provider for messages
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<MessageData>>((ref) {
  return MessagesNotifier();
});

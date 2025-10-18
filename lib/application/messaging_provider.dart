import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/message_model.dart';

// Provider for managing messages
class MessagesNotifier extends StateNotifier<List<MessageData>> {
  MessagesNotifier() : super([]) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('messages') ?? [];
    final messages = messagesJson
        .map((json) => MessageData.fromJson(jsonDecode(json)))
        .toList();
    state = messages;
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = state
        .map((message) => jsonEncode(message.toJson()))
        .toList();
    await prefs.setStringList('messages', messagesJson);
  }

  void sendMessage(MessageData message) {
    state = [...state, message];
    _saveMessages();
    
    // Simulate agent response after a delay
    _simulateAgentResponse(message);
  }

  void _simulateAgentResponse(MessageData originalMessage) {
    Future.delayed(Duration(seconds: 2), () {
      final responses = [
        'Thank you for your message! I\'ll get back to you shortly.',
        'I\'d be happy to help you with that property.',
        'Let me check the availability and get back to you.',
        'That\'s a great question! Here\'s what I can tell you...',
        'I can schedule a showing for you this week.',
      ];
      
      final response = MessageData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: originalMessage.conversationId,
        senderId: originalMessage.receiverId,
        receiverId: originalMessage.senderId,
        content: responses[DateTime.now().millisecond % responses.length],
        type: MessageType.text,
        timestamp: DateTime.now(),
        propertyId: originalMessage.propertyId,
      );
      
      state = [...state, response];
      _saveMessages();
    });
  }

  void markMessagesAsRead(String conversationId) {
    state = state.map((message) {
      if (message.conversationId == conversationId && 
          message.receiverId == 'current_user') {
        return MessageData(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          receiverId: message.receiverId,
          content: message.content,
          type: message.type,
          timestamp: message.timestamp,
          isRead: true,
          propertyId: message.propertyId,
        );
      }
      return message;
    }).toList();
    _saveMessages();
  }

  void deleteMessage(String messageId) {
    state = state.where((message) => message.id != messageId).toList();
    _saveMessages();
  }

  void deleteConversation(String conversationId) {
    state = state.where((message) => message.conversationId != conversationId).toList();
    _saveMessages();
  }
}

final messagesProvider = StateNotifierProvider<MessagesNotifier, List<MessageData>>((ref) {
  return MessagesNotifier();
});

// Provider for getting messages in a specific conversation
final conversationMessagesProvider = Provider.family<List<MessageData>, String>((ref, conversationId) {
  final allMessages = ref.watch(messagesProvider);
  return allMessages
      .where((message) => message.conversationId == conversationId)
      .toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
});

// Provider for getting all conversations
final conversationsProvider = Provider<List<ConversationData>>((ref) {
  final allMessages = ref.watch(messagesProvider);
  
  // Group messages by conversation ID
  final conversationMap = <String, List<MessageData>>{};
  for (final message in allMessages) {
    conversationMap.putIfAbsent(message.conversationId, () => []).add(message);
  }
  
  // Create conversation objects
  final conversations = <ConversationData>[];
  for (final entry in conversationMap.entries) {
    final messages = entry.value..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final lastMessage = messages.isNotEmpty ? messages.first : null;
    final unreadCount = messages
        .where((msg) => msg.receiverId == 'current_user' && !msg.isRead)
        .length;
    
    final participantIds = messages
        .expand((msg) => [msg.senderId, msg.receiverId])
        .toSet()
        .toList();
    
    conversations.add(ConversationData(
      id: entry.key,
      participantIds: participantIds,
      lastMessage: lastMessage,
      lastActivity: lastMessage?.timestamp ?? DateTime.now(),
      propertyId: lastMessage?.propertyId,
      unreadCount: unreadCount,
    ));
  }
  
  // Sort conversations by last activity
  conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  
  return conversations;
});

// Provider for getting a specific conversation
final conversationProvider = Provider.family<ConversationData?, String>((ref, conversationId) {
  final conversations = ref.watch(conversationsProvider);
  return conversations.firstWhere(
    (conv) => conv.id == conversationId,
    orElse: () => ConversationData(
      id: conversationId,
      participantIds: ['current_user'],
      lastActivity: DateTime.now(),
    ),
  );
});

// Provider for unread message count
final unreadMessageCountProvider = Provider<int>((ref) {
  final conversations = ref.watch(conversationsProvider);
  return conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
});
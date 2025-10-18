import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String sender; // 'user' or 'agent'
  final String text;
  final DateTime timestamp;

  ChatMessage({required this.sender, required this.text, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        sender: json['sender'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class ChatState {
  final Map<int, List<ChatMessage>> messagesByAgentId;

  const ChatState({required this.messagesByAgentId});

  ChatState copyWith({Map<int, List<ChatMessage>>? messagesByAgentId}) => ChatState(
        messagesByAgentId: messagesByAgentId ?? this.messagesByAgentId,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState(messagesByAgentId: {})) {
    _load();
  }

  static const String _prefsKey = 'chat_messages_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final map = <int, List<ChatMessage>>{};
      for (final entry in decoded.entries) {
        final agentId = int.parse(entry.key);
        final list = (entry.value as List<dynamic>)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        map[agentId] = list;
      }
      state = state.copyWith(messagesByAgentId: map);
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{};
    state.messagesByAgentId.forEach((key, value) {
      map[key.toString()] = value.map((e) => e.toJson()).toList();
    });
    await prefs.setString(_prefsKey, json.encode(map));
  }

  List<ChatMessage> getConversation(int agentId) =>
      List<ChatMessage>.from(state.messagesByAgentId[agentId] ?? const []);

  Future<void> sendUserMessage(int agentId, String text) async {
    final updated = Map<int, List<ChatMessage>>.from(state.messagesByAgentId);
    final list = List<ChatMessage>.from(updated[agentId] ?? const []);
    list.add(ChatMessage(sender: 'user', text: text, timestamp: DateTime.now()));
    updated[agentId] = list;
    state = state.copyWith(messagesByAgentId: updated);
    await _persist();
    // Simple auto-reply for demo purposes
    await sendAgentMessage(agentId, 'Thanks for reaching out! We\'ll get back to you soon.');
  }

  Future<void> sendAgentMessage(int agentId, String text) async {
    final updated = Map<int, List<ChatMessage>>.from(state.messagesByAgentId);
    final list = List<ChatMessage>.from(updated[agentId] ?? const []);
    list.add(ChatMessage(sender: 'agent', text: text, timestamp: DateTime.now()));
    updated[agentId] = list;
    state = state.copyWith(messagesByAgentId: updated);
    await _persist();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

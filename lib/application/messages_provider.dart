import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String fromId; // agent id
  final String text;
  final DateTime sentAt;

  const Message({required this.fromId, required this.text, required this.sentAt});

  Map<String, dynamic> toJson() => {
        'fromId': fromId,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
      };

  static Message fromJson(Map<String, dynamic> json) => Message(
        fromId: json['fromId'] as String,
        text: json['text'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
}

final messagesProvider = StateNotifierProvider<MessagesNotifier, Map<String, List<Message>>>((ref) {
  return MessagesNotifier();
});

class MessagesNotifier extends StateNotifier<Map<String, List<Message>>> {
  static const storageKey = 'messages_by_agent_v1';
  MessagesNotifier() : super(<String, List<Message>>{}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? <String>[];
    final next = <String, List<Message>>{};
    for (final s in raw) {
      final parts = s.split('||');
      if (parts.length < 3) continue;
      final agentId = parts[0];
      final sentAt = DateTime.parse(parts[1]);
      final text = parts.sublist(2).join('||');
      next.putIfAbsent(agentId, () => <Message>[]).add(Message(fromId: agentId, text: text, sentAt: sentAt));
    }
    state = next;
  }

  Future<void> send(String agentId, String text) async {
    final msg = Message(fromId: agentId, text: text, sentAt: DateTime.now());
    final next = Map<String, List<Message>>.from(state);
    next.putIfAbsent(agentId, () => <Message>[]).add(msg);
    state = next;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = <String>[];
    state.forEach((agentId, msgs) {
      for (final m in msgs) {
        // Serialize as simple pipe-joined record
        list.add('$agentId||${m.sentAt.toIso8601String()}||${m.text}');
      }
    });
    await prefs.setStringList(storageKey, list);
  }
}

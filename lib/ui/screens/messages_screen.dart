import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Message {
  final String text;
  final bool fromUser;
  final DateTime sentAt;
  Message({required this.text, required this.fromUser, required this.sentAt});

  Map<String, dynamic> toJson() => {
        'text': text,
        'fromUser': fromUser,
        'sentAt': sentAt.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        text: json['text'] as String,
        fromUser: json['fromUser'] as bool,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
}

class ConversationController extends StateNotifier<Map<int, List<Message>>> {
  ConversationController() : super(<int, List<Message>>{});

  void send(int agentId, String text, {bool fromUser = true}) {
    final list = List<Message>.from(state[agentId] ?? const <Message>[]);
    list.add(Message(text: text, fromUser: fromUser, sentAt: DateTime.now()));
    state = {...state, agentId: list};
  }
}

final conversationsProvider =
    StateNotifierProvider<ConversationController, Map<int, List<Message>>>((ref) {
  return ConversationController();
});

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  int? selectedAgentId;
  String? selectedAgentName;
  final TextEditingController _controller = TextEditingController();
  Future<List<Map<String, dynamic>>>? _agentsFuture;

  @override
  void initState() {
    super.initState();
    _agentsFuture = _loadAgents();
  }

  Future<List<Map<String, dynamic>>> _loadAgents() async {
    final jsonStr = await rootBundle.loadString('assets/data/agents.json');
    final data = jsonDecode(jsonStr) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final messages = selectedAgentId != null ? (conversations[selectedAgentId!] ?? const <Message>[]) : const <Message>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _agentsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }
              final agents = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<int>(
                  value: selectedAgentId,
                  items: [
                    for (final a in agents)
                      DropdownMenuItem(
                        value: a['id'] as int,
                        child: Text(a['name'] as String),
                      )
                  ],
                  decoration: const InputDecoration(labelText: 'Select agent'),
                  onChanged: (value) {
                    setState(() {
                      selectedAgentId = value;
                      selectedAgentName = agents.firstWhere((e) => e['id'] == value)['name'] as String;
                    });
                  },
                ),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                final align = m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                final color = m.fromUser ? Colors.blue[200] : Colors.grey[300];
                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: selectedAgentId == null
                    ? null
                    : () {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;
                        ref.read(conversationsProvider.notifier).send(selectedAgentId!, text, fromUser: true);
                        _controller.clear();
                      },
              ),
            ],
          )
        ],
      ),
    );
  }
}

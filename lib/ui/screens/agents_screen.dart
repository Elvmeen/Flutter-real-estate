import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/agent_model.dart';
import '../components/strings.dart';
import '../theme/type.dart';
import '../../application/chat_provider.dart' as chat_provider;

class AgentsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends ConsumerState<AgentsScreen> {
  List<Agent> _agents = [];
  List<Agent> _filtered = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    final jsonStr = await rootBundle.loadString('assets/agents.json');
    final list = (json.decode(jsonStr) as List<dynamic>)
        .map((e) => Agent.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {
      _agents = list;
      _filtered = list;
    });
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = _agents);
    } else {
      setState(() => _filtered = _agents
          .where((a) => a.name.toLowerCase().contains(q) || a.city.toLowerCase().contains(q))
          .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: Strings.agentsSearchHint,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _applyFilter,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final agent = _filtered[index];
              return ListTile(
                leading: CircleAvatar(child: Text(agent.name.isNotEmpty ? agent.name[0] : '?')),
                title: Text(agent.name, style: AppTypography.body),
                subtitle: Text(agent.city),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AgentDetailScreen(agent: agent))),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AgentDetailScreen extends ConsumerWidget {
  final Agent agent;
  const AgentDetailScreen({required this.agent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(agent.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(agent.name, style: AppTypography.title02),
            const SizedBox(height: 8),
            Text(agent.city),
            const SizedBox(height: 16),
            Text(agent.bio),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(agentId: agent.id, agentName: agent.name),
                    ),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text('Message Agent'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  final int agentId;
  final String agentName;
  const ChatScreen({required this.agentId, required this.agentName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chat_provider.chatProvider);
    final messages = chatState.messagesByAgentId[widget.agentId] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.agentName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.sender == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    await ref
                        .read(chat_provider.chatProvider.notifier)
                        .sendUserMessage(widget.agentId, text);
                    _controller.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

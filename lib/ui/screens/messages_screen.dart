import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/messages_provider.dart';
import '../../models/agent_model.dart';

final selectedAgentIdProvider = StateProvider<String?>((ref) => demoAgents.first.id);

class MessagesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentId = ref.watch(selectedAgentIdProvider);
    final messagesByAgent = ref.watch(messagesProvider);

    return Column(
      children: [
        // Agent picker
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String?>(
            value: agentId,
            items: [
              for (final a in demoAgents)
                DropdownMenuItem<String?>(value: a.id, child: Text(a.name)),
            ],
            onChanged: (id) => ref.read(selectedAgentIdProvider.notifier).state = id,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final m in (messagesByAgent[agentId] ?? const <Message>[]))
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(m.text),
                  ),
                )
            ],
          ),
        ),
        _Composer(agentId: agentId),
      ],
    );
  }
}

class _Composer extends ConsumerStatefulWidget {
  final String? agentId;
  const _Composer({required this.agentId});

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: widget.agentId == null || controller.text.trim().isEmpty
                ? null
                : () async {
                    final text = controller.text.trim();
                    controller.clear();
                    await ref.read(messagesProvider.notifier).send(widget.agentId!, text);
                  },
          )
        ],
      ),
    );
  }
}

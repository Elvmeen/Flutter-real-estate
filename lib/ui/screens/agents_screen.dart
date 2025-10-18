import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/agent_model.dart';

final agentsProvider = Provider<List<Agent>>((ref) => demoAgents);

class AgentsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(agentsProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: agents.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final agent = agents[index];
        return ListTile(
          leading: CircleAvatar(child: Text(agent.name[0])),
          title: Text(agent.name),
          subtitle: Text('${agent.city} • ${agent.email}'),
          trailing: Wrap(
            spacing: 8,
            children: [
              IconButton(
                tooltip: 'Email',
                icon: const Icon(Icons.email),
                onPressed: () async => _launch('mailto:${agent.email}'),
              ),
              IconButton(
                tooltip: 'Call',
                icon: const Icon(Icons.phone),
                onPressed: () async => _launch('tel:${agent.phone}'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri);
  }
}

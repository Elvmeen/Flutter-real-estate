import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class Agent {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String city;

  Agent({required this.id, required this.name, required this.phone, required this.email, required this.city});

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        city: json['city'] as String,
      );
}

class AgentsScreen extends StatefulWidget {
  const AgentsScreen({super.key});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  late Future<List<Agent>> _futureAgents;

  @override
  void initState() {
    super.initState();
    _futureAgents = _loadAgents();
  }

  Future<List<Agent>> _loadAgents() async {
    final jsonStr = await rootBundle.loadString('assets/data/agents.json');
    final data = jsonDecode(jsonStr) as List<dynamic>;
    return data.map((e) => Agent.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agents')),
      body: FutureBuilder<List<Agent>>(
        future: _futureAgents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final agents = snapshot.data ?? const <Agent>[];
          if (agents.isEmpty) {
            return const Center(child: Text('No agents found'));
          }
          return ListView.separated(
            itemCount: agents.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final a = agents[index];
              return ListTile(
                leading: CircleAvatar(child: Text(a.name.split(' ').map((e) => e[0]).take(2).join())),
                title: Text(a.name),
                subtitle: Text(a.city),
                trailing: Wrap(spacing: 8, children: [
                  IconButton(
                    tooltip: 'Call',
                    icon: const Icon(Icons.call),
                    onPressed: () => launchUrl(Uri.parse('tel:${a.phone}')),
                  ),
                  IconButton(
                    tooltip: 'Email',
                    icon: const Icon(Icons.email_outlined),
                    onPressed: () => launchUrl(Uri.parse('mailto:${a.email}')),
                  ),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}

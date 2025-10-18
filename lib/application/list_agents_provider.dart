import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agent_model.dart';

// Provider for the list of agents
// In a real app, this would fetch from an API
final listAgentsProvider = Provider<List<AgentData>>((ref) {
  // Mock data for demonstration
  return [
    AgentData(
      id: 1,
      name: 'Sarah Johnson',
      email: 'sarah.johnson@dreamhome.com',
      phone: '+1 (555) 123-4567',
      photo: 'https://i.pravatar.cc/150?img=1',
      specialty: 'Luxury Homes',
      rating: 4.8,
      propertiesListed: 45,
    ),
    AgentData(
      id: 2,
      name: 'Michael Chen',
      email: 'michael.chen@dreamhome.com',
      phone: '+1 (555) 234-5678',
      photo: 'https://i.pravatar.cc/150?img=12',
      specialty: 'Commercial Properties',
      rating: 4.9,
      propertiesListed: 38,
    ),
    AgentData(
      id: 3,
      name: 'Emily Rodriguez',
      email: 'emily.rodriguez@dreamhome.com',
      phone: '+1 (555) 345-6789',
      photo: 'https://i.pravatar.cc/150?img=5',
      specialty: 'First-Time Buyers',
      rating: 4.7,
      propertiesListed: 52,
    ),
    AgentData(
      id: 4,
      name: 'David Thompson',
      email: 'david.thompson@dreamhome.com',
      phone: '+1 (555) 456-7890',
      photo: 'https://i.pravatar.cc/150?img=15',
      specialty: 'Investment Properties',
      rating: 4.6,
      propertiesListed: 41,
    ),
  ];
});

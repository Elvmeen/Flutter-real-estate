import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agent_model.dart';

// Provider to manage the list of agents
// In a real app, this would fetch from an API
final listAgentsProvider = FutureProvider<List<AgentData>>((ref) async {
  // Simulated agent data - in production, this would be an API call
  await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
  
  return [
    AgentData(
      id: 1,
      name: 'Sarah Johnson',
      email: 'sarah.johnson@dreamhome.com',
      phone: '+1 (555) 123-4567',
      photo: 'https://randomuser.me/api/portraits/women/1.jpg',
      specialty: 'Luxury Homes',
      rating: 4.9,
      propertiesSold: 156,
      bio: 'With over 10 years of experience in luxury real estate, Sarah specializes in high-end properties and personalized service.',
      agency: 'DreamHome Premier',
    ),
    AgentData(
      id: 2,
      name: 'Michael Chen',
      email: 'michael.chen@dreamhome.com',
      phone: '+1 (555) 234-5678',
      photo: 'https://randomuser.me/api/portraits/men/2.jpg',
      specialty: 'Commercial Properties',
      rating: 4.8,
      propertiesSold: 203,
      bio: 'Michael brings extensive knowledge of commercial real estate and investment properties to help clients maximize their returns.',
      agency: 'DreamHome Business',
    ),
    AgentData(
      id: 3,
      name: 'Emily Rodriguez',
      email: 'emily.rodriguez@dreamhome.com',
      phone: '+1 (555) 345-6789',
      photo: 'https://randomuser.me/api/portraits/women/3.jpg',
      specialty: 'First-Time Buyers',
      rating: 4.9,
      propertiesSold: 142,
      bio: 'Emily is passionate about helping first-time homebuyers navigate the process with confidence and ease.',
      agency: 'DreamHome Family',
    ),
    AgentData(
      id: 4,
      name: 'David Thompson',
      email: 'david.thompson@dreamhome.com',
      phone: '+1 (555) 456-7890',
      photo: 'https://randomuser.me/api/portraits/men/4.jpg',
      specialty: 'Investment Properties',
      rating: 4.7,
      propertiesSold: 189,
      bio: 'David specializes in investment properties and has helped numerous clients build successful real estate portfolios.',
      agency: 'DreamHome Investments',
    ),
    AgentData(
      id: 5,
      name: 'Jessica Williams',
      email: 'jessica.williams@dreamhome.com',
      phone: '+1 (555) 567-8901',
      photo: 'https://randomuser.me/api/portraits/women/5.jpg',
      specialty: 'Residential Sales',
      rating: 4.8,
      propertiesSold: 167,
      bio: 'With a keen eye for detail and strong negotiation skills, Jessica ensures her clients get the best deals.',
      agency: 'DreamHome Residential',
    ),
  ];
});

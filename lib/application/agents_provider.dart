import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/house_model.dart';

// Provider for agents list
final agentsProvider = FutureProvider<List<AgentData>>((ref) async {
  // Simulate API call - in real app, this would fetch from your backend
  await Future.delayed(Duration(seconds: 1));
  
  return [
    AgentData(
      id: 1,
      name: 'Sarah Johnson',
      email: 'sarah.johnson@dreamhome.com',
      phone: '+1-555-0101',
      profileImage: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      company: 'DreamHome Realty',
      rating: 4.8,
      reviewCount: 127,
      bio: 'With over 8 years of experience in residential real estate, Sarah specializes in helping first-time homebuyers and luxury property sales. She has a deep knowledge of the local market and is committed to providing exceptional service to her clients.',
      specializations: ['First-time Buyers', 'Luxury Homes', 'Investment Properties'],
    ),
    AgentData(
      id: 2,
      name: 'Michael Chen',
      email: 'michael.chen@dreamhome.com',
      phone: '+1-555-0102',
      profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      company: 'DreamHome Realty',
      rating: 4.9,
      reviewCount: 203,
      bio: 'Michael is a top-performing agent with expertise in commercial and residential properties. He has helped over 500 families find their dream homes and has consistently been recognized as a top sales agent.',
      specializations: ['Commercial Properties', 'Residential Sales', 'Property Investment'],
    ),
    AgentData(
      id: 3,
      name: 'Emily Rodriguez',
      email: 'emily.rodriguez@dreamhome.com',
      phone: '+1-555-0103',
      profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      company: 'DreamHome Realty',
      rating: 4.7,
      reviewCount: 89,
      bio: 'Emily specializes in rental properties and property management. She has extensive knowledge of the rental market and helps both landlords and tenants find the perfect match.',
      specializations: ['Rental Properties', 'Property Management', 'Tenant Relations'],
    ),
    AgentData(
      id: 4,
      name: 'David Thompson',
      email: 'david.thompson@dreamhome.com',
      phone: '+1-555-0104',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      company: 'DreamHome Realty',
      rating: 4.6,
      reviewCount: 156,
      bio: 'David has been serving the community for over 12 years, specializing in family homes and suburban properties. He understands the importance of finding the right neighborhood for growing families.',
      specializations: ['Family Homes', 'Suburban Properties', 'School District Specialist'],
    ),
    AgentData(
      id: 5,
      name: 'Lisa Park',
      email: 'lisa.park@dreamhome.com',
      phone: '+1-555-0105',
      profileImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      company: 'DreamHome Realty',
      rating: 4.9,
      reviewCount: 178,
      bio: 'Lisa is a luxury property specialist with a keen eye for high-end real estate. She works with discerning clients who demand the finest properties and exceptional service.',
      specializations: ['Luxury Properties', 'High-end Condos', 'Waterfront Homes'],
    ),
  ];
});

// Provider for searching agents
final agentSearchProvider = StateProvider<String>((ref) => '');

// Filtered agents based on search
final filteredAgentsProvider = Provider<AsyncValue<List<AgentData>>>((ref) {
  final agentsAsync = ref.watch(agentsProvider);
  final searchQuery = ref.watch(agentSearchProvider);
  
  return agentsAsync.when(
    data: (agents) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(agents);
      }
      
      final filtered = agents.where((agent) {
        final query = searchQuery.toLowerCase();
        return agent.name.toLowerCase().contains(query) ||
               agent.company.toLowerCase().contains(query) ||
               agent.specializations.any((spec) => 
                   spec.toLowerCase().contains(query));
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
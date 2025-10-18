import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../models/house_model.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

class AgentDirectoryScreen extends ConsumerStatefulWidget {
  const AgentDirectoryScreen({super.key});

  @override
  ConsumerState<AgentDirectoryScreen> createState() => _AgentDirectoryScreenState();
}

class _AgentDirectoryScreenState extends ConsumerState<AgentDirectoryScreen> {
  final _searchController = TextEditingController();
  String _selectedSpecialty = 'All';
  String _sortBy = 'Rating';

  final List<String> _specialties = [
    'All',
    'Residential Sales',
    'Commercial Real Estate',
    'Luxury Properties',
    'First Time Buyers',
    'Investment Properties',
    'Rental Properties',
    'New Construction',
    'Foreclosures',
    'Short Sales',
  ];

  final List<String> _sortOptions = [
    'Rating',
    'Experience',
    'Name',
    'Company',
  ];

  // Mock data - in a real app, this would come from an API
  final List<AgentInfo> _agents = [
    AgentInfo(
      id: '1',
      name: 'Sarah Johnson',
      email: 'sarah.johnson@dreamhome.com',
      phone: '(555) 123-4567',
      profileImage: 'https://via.placeholder.com/150',
      company: 'DreamHome Realty',
      rating: 4.9,
      totalSales: 127,
      specialties: ['Residential Sales', 'First Time Buyers', 'Luxury Properties'],
      bio: 'With over 10 years of experience in residential real estate, Sarah specializes in helping first-time buyers find their dream home.',
      isOnline: true,
    ),
    AgentInfo(
      id: '2',
      name: 'Michael Chen',
      email: 'michael.chen@dreamhome.com',
      phone: '(555) 234-5678',
      profileImage: 'https://via.placeholder.com/150',
      company: 'Elite Properties',
      rating: 4.8,
      totalSales: 89,
      specialties: ['Commercial Real Estate', 'Investment Properties'],
      bio: 'Michael is a commercial real estate expert with a proven track record in investment properties and commercial developments.',
      isOnline: false,
    ),
    AgentInfo(
      id: '3',
      name: 'Emily Rodriguez',
      email: 'emily.rodriguez@dreamhome.com',
      phone: '(555) 345-6789',
      profileImage: 'https://via.placeholder.com/150',
      company: 'DreamHome Realty',
      rating: 4.7,
      totalSales: 156,
      specialties: ['Luxury Properties', 'New Construction'],
      bio: 'Emily specializes in luxury properties and new construction, helping clients find their perfect high-end home.',
      isOnline: true,
    ),
    AgentInfo(
      id: '4',
      name: 'David Thompson',
      email: 'david.thompson@dreamhome.com',
      phone: '(555) 456-7890',
      profileImage: 'https://via.placeholder.com/150',
      company: 'Thompson Real Estate',
      rating: 4.6,
      totalSales: 203,
      specialties: ['Rental Properties', 'Investment Properties', 'Foreclosures'],
      bio: 'David has extensive experience in rental properties and investment real estate, helping clients build their portfolios.',
      isOnline: true,
    ),
    AgentInfo(
      id: '5',
      name: 'Lisa Wang',
      email: 'lisa.wang@dreamhome.com',
      phone: '(555) 567-8901',
      profileImage: 'https://via.placeholder.com/150',
      company: 'DreamHome Realty',
      rating: 4.9,
      totalSales: 98,
      specialties: ['First Time Buyers', 'Short Sales', 'Residential Sales'],
      bio: 'Lisa is passionate about helping first-time buyers navigate the complex process of purchasing their first home.',
      isOnline: false,
    ),
  ];

  List<AgentInfo> get _filteredAgents {
    var filtered = _agents.where((agent) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        if (!agent.name.toLowerCase().contains(searchTerm) &&
            !agent.company.toLowerCase().contains(searchTerm) &&
            !agent.specialties.any((s) => s.toLowerCase().contains(searchTerm))) {
          return false;
        }
      }

      // Specialty filter
      if (_selectedSpecialty != 'All' && !agent.specialties.contains(_selectedSpecialty)) {
        return false;
      }

      return true;
    }).toList();

    // Sort agents
    switch (_sortBy) {
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Experience':
        filtered.sort((a, b) => b.totalSales.compareTo(a.totalSales));
        break;
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Company':
        filtered.sort((a, b) => a.company.compareTo(b.company));
        break;
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find an Agent'),
        backgroundColor: AppColors.strong,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppColors.lightGray,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search agents by name, company, or specialty',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 2.h),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSpecialty,
                        decoration: const InputDecoration(
                          labelText: 'Specialty',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                        items: _specialties.map((specialty) {
                          return DropdownMenuItem(
                            value: specialty,
                            child: Text(specialty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecialty = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Agents List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _filteredAgents.length,
              itemBuilder: (context, index) {
                final agent = _filteredAgents[index];
                return _buildAgentCard(agent);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(AgentInfo agent) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 6.w,
                  backgroundImage: NetworkImage(agent.profileImage ?? ''),
                  child: agent.profileImage == null
                      ? Icon(Icons.person, size: 6.w)
                      : null,
                ),
                SizedBox(width: 3.w),

                // Agent Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            agent.name,
                            style: AppTypography.title02.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: agent.isOnline ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              agent.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        agent.company,
                        style: AppTypography.body.copyWith(
                          color: AppColors.medium,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 4.w),
                          SizedBox(width: 1.w),
                          Text(
                            agent.rating.toString(),
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '(${agent.totalSales} sales)',
                            style: AppTypography.body.copyWith(
                              color: AppColors.medium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contact Button
                ElevatedButton(
                  onPressed: () => _contactAgent(agent),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.strong,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Contact'),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Specialties
            Wrap(
              spacing: 1.w,
              runSpacing: 1.h,
              children: agent.specialties.map((specialty) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    specialty,
                    style: AppTypography.detail.copyWith(
                      color: AppColors.strong,
                    ),
                  ),
                );
              }).toList(),
            ),

            if (agent.bio != null) ...[
              SizedBox(height: 2.h),
              Text(
                agent.bio!,
                style: AppTypography.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: 2.h),

            // Contact Info
            Row(
              children: [
                Icon(Icons.phone, size: 4.w, color: AppColors.medium),
                SizedBox(width: 2.w),
                Text(
                  agent.phone,
                  style: AppTypography.body,
                ),
                SizedBox(width: 4.w),
                Icon(Icons.email, size: 4.w, color: AppColors.medium),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    agent.email,
                    style: AppTypography.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _contactAgent(AgentInfo agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${agent.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call'),
              subtitle: Text(agent.phone),
              onTap: () {
                // Implement phone call functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(agent.email),
              onTap: () {
                // Implement email functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Message'),
              subtitle: const Text('Send a message'),
              onTap: () {
                // Navigate to messaging screen
                Navigator.pop(context);
                // TODO: Implement messaging navigation
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
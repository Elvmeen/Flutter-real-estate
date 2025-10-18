import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/house_model.dart';
import '../../application/agents_provider.dart';
import '../theme/colors.dart';
import '../theme/type.dart';
import '../components/error_state.dart';

class AgentsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsValue = ref.watch(agentsProvider);

    return Column(
      children: [
        // Search bar for agents
        Padding(
          padding: EdgeInsets.all(4.w),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              style: AppTypography.input,
              decoration: InputDecoration(
                hintText: 'Search agents by name or specialization',
                hintStyle: AppTypography.hint,
                prefixIcon: Icon(Icons.search, color: AppColors.medium),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
            ),
          ),
        ),
        
        // Agents list
        Expanded(
          child: agentsValue.when(
            data: (agents) => ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: agents.length,
              itemBuilder: (context, index) {
                final agent = agents[index];
                return AgentCard(agent: agent);
              },
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: ErrorState()),
          ),
        ),
      ],
    );
  }
}

class AgentCard extends StatelessWidget {
  final AgentData agent;

  const AgentCard({Key? key, required this.agent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Agent profile image
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.lightGray,
                  backgroundImage: agent.profileImage != null
                      ? CachedNetworkImageProvider(agent.profileImage!)
                      : null,
                  child: agent.profileImage == null
                      ? Icon(Icons.person, size: 30, color: AppColors.medium)
                      : null,
                ),
                SizedBox(width: 4.w),
                
                // Agent info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.name, style: AppTypography.title02),
                      Text(agent.company, style: AppTypography.detail),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 1.w),
                          Text(
                            '${agent.rating.toStringAsFixed(1)} (${agent.reviewCount} reviews)',
                            style: AppTypography.detail,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Contact buttons
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _makePhoneCall(agent.phone),
                      icon: Icon(Icons.phone, color: AppColors.strong),
                    ),
                    IconButton(
                      onPressed: () => _sendEmail(agent.email),
                      icon: Icon(Icons.email, color: AppColors.strong),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Agent bio
            Text(agent.bio, style: AppTypography.body),
            
            SizedBox(height: 2.h),
            
            // Specializations
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: agent.specializations.map((spec) => Chip(
                label: Text(spec, style: AppTypography.detail),
                backgroundColor: AppColors.lightGray,
                side: BorderSide.none,
              )).toList(),
            ),
            
            SizedBox(height: 2.h),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewProfile(context, agent),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.strong,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('View Profile'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _startConversation(context, agent),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.strong,
                      side: BorderSide(color: AppColors.strong),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _viewProfile(BuildContext context, AgentData agent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentProfileScreen(agent: agent),
      ),
    );
  }

  void _startConversation(BuildContext context, AgentData agent) {
    // Navigate to messaging screen with this agent
    // This will be implemented when we create the messaging system
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting conversation with ${agent.name}')),
    );
  }
}

class AgentProfileScreen extends StatelessWidget {
  final AgentData agent;

  const AgentProfileScreen({Key? key, required this.agent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(agent.name),
        backgroundColor: AppColors.strong,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.lightGray,
                    backgroundImage: agent.profileImage != null
                        ? CachedNetworkImageProvider(agent.profileImage!)
                        : null,
                    child: agent.profileImage == null
                        ? Icon(Icons.person, size: 60, color: AppColors.medium)
                        : null,
                  ),
                  SizedBox(height: 2.h),
                  Text(agent.name, style: AppTypography.title01),
                  Text(agent.company, style: AppTypography.subtitle),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 1.w),
                      Text(
                        '${agent.rating.toStringAsFixed(1)} (${agent.reviewCount} reviews)',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 4.h),
            
            // Contact information
            _buildSection('Contact Information', [
              _buildContactItem(Icons.phone, 'Phone', agent.phone),
              _buildContactItem(Icons.email, 'Email', agent.email),
            ]),
            
            SizedBox(height: 3.h),
            
            // About section
            _buildSection('About', [
              Text(agent.bio, style: AppTypography.body),
            ]),
            
            SizedBox(height: 3.h),
            
            // Specializations
            _buildSection('Specializations', [
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: agent.specializations.map((spec) => Chip(
                  label: Text(spec, style: AppTypography.detail),
                  backgroundColor: AppColors.strong.withOpacity(0.1),
                  side: BorderSide.none,
                )).toList(),
              ),
            ]),
            
            SizedBox(height: 4.h),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(agent.phone),
                    icon: Icon(Icons.phone),
                    label: Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.strong,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startConversation(context, agent),
                    icon: Icon(Icons.message),
                    label: Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.medium,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title02),
        SizedBox(height: 1.h),
        ...children,
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.medium, size: 20),
          SizedBox(width: 3.w),
          Text('$label: ', style: AppTypography.detail),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _startConversation(BuildContext context, AgentData agent) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting conversation with ${agent.name}')),
    );
  }
}
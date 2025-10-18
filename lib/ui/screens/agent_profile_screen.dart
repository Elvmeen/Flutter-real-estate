import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate/models/agent_model.dart';
import 'package:flutter_real_estate/ui/components/top_app_bar.dart';
import 'package:flutter_real_estate/ui/screens/chat_screen.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentProfileScreen extends StatelessWidget {
  final AgentData agent;

  const AgentProfileScreen({Key? key, required this.agent}) : super(key: key);

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Property Inquiry'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(title: 'Agent Profile'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Agent header with photo and basic info
            Container(
              color: AppColors.white,
              padding: EdgeInsets.all(6.w),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: CachedNetworkImage(
                      imageUrl: agent.photo,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: AppColors.lightGray,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        color: AppColors.lightGray,
                        child: Icon(Icons.person, size: 60),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    agent.name,
                    style: AppTypography.title01,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    agent.specialty,
                    style: AppTypography.body.copyWith(
                      color: AppColors.medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    agent.agency,
                    style: AppTypography.detail.copyWith(
                      color: AppColors.medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('Rating', agent.rating.toString(), Icons.star),
                      SizedBox(width: 8.w),
                      _buildStatItem('Sold', agent.propertiesSold.toString(), Icons.home),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(agent.phone),
                      icon: Icon(Icons.phone),
                      label: Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.strong,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              contactId: agent.id,
                              contactName: agent.name,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.message),
                      label: Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.strong,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            // Bio section
            Container(
              color: AppColors.white,
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: AppTypography.title02,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    agent.bio,
                    style: AppTypography.body,
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            // Contact information
            Container(
              color: AppColors.white,
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: AppTypography.title02,
                  ),
                  SizedBox(height: 2.h),
                  _buildContactRow(Icons.email, agent.email, () => _sendEmail(agent.email)),
                  SizedBox(height: 1.h),
                  _buildContactRow(Icons.phone, agent.phone, () => _makePhoneCall(agent.phone)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTypography.title02,
        ),
        Text(
          label,
          style: AppTypography.detail.copyWith(
            color: AppColors.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.medium, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body,
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.medium),
        ],
      ),
    );
  }
}

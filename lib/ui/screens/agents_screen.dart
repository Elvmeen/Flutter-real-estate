import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate/application/list_agents_provider.dart';
import 'package:flutter_real_estate/ui/components/error_state.dart';
import 'package:flutter_real_estate/ui/screens/agent_profile_screen.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class AgentsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsData = ref.watch(listAgentsProvider);

    return agentsData.when(
      skipLoadingOnRefresh: false,
      data: (agents) => ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: agents.length,
        itemBuilder: (context, index) {
          final agent = agents[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 2.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgentProfileScreen(agent: agent),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  children: [
                    // Agent photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: agent.photo,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.lightGray,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.lightGray,
                          child: Icon(Icons.person, size: 40),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // Agent details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.name,
                            style: AppTypography.title02,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            agent.specialty,
                            style: AppTypography.detail.copyWith(
                              color: AppColors.medium,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '${agent.rating} • ${agent.propertiesSold} properties sold',
                                style: AppTypography.detail,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.medium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: ErrorState()),
    );
  }
}

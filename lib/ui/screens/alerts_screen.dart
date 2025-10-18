import 'package:flutter/material.dart';
import 'package:flutter_real_estate/application/alerts_provider.dart';
import 'package:flutter_real_estate/models/alert_model.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class AlertsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final unreadCount = ref.watch(unreadAlertsCountProvider);

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: AppTypography.title01,
                  ),
                  if (unreadCount > 0)
                    Text(
                      '$unreadCount new ${unreadCount == 1 ? 'notification' : 'notifications'}',
                      style: AppTypography.detail.copyWith(color: AppColors.strong),
                    ),
                ],
              ),
              if (unreadCount > 0)
                TextButton(
                  onPressed: () {
                    ref.read(alertsProvider.notifier).markAllAsRead();
                  },
                  child: Text(
                    'Mark all read',
                    style: AppTypography.detail.copyWith(color: AppColors.strong),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: alerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: AppColors.medium,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No notifications',
                          style: AppTypography.title02.copyWith(color: AppColors.medium),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'You\'re all caught up!',
                          style: AppTypography.body.copyWith(color: AppColors.medium),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return AlertCard(
                        alert: alert,
                        onTap: () {
                          ref.read(alertsProvider.notifier).markAsRead(alert.id);
                        },
                        onDismiss: () {
                          ref.read(alertsProvider.notifier).removeAlert(alert.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final AlertData alert;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const AlertCard({
    Key? key,
    required this.alert,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  IconData _getIconForType(AlertType type) {
    switch (type) {
      case AlertType.newListing:
        return Icons.home;
      case AlertType.priceChange:
        return Icons.trending_down;
      case AlertType.savedSearch:
        return Icons.search;
      case AlertType.appointment:
        return Icons.calendar_today;
    }
  }

  Color _getColorForType(AlertType type) {
    switch (type) {
      case AlertType.newListing:
        return Colors.green;
      case AlertType.priceChange:
        return Colors.orange;
      case AlertType.savedSearch:
        return Colors.blue;
      case AlertType.appointment:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alert.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: alert.isRead ? AppColors.white : AppColors.lightGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: alert.isRead ? AppColors.lightGray : _getColorForType(alert.type).withOpacity(0.3),
              width: alert.isRead ? 1 : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getColorForType(alert.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForType(alert.type),
                  color: _getColorForType(alert.type),
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: AppTypography.title02,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            margin: EdgeInsets.only(left: 2.w),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getColorForType(alert.type),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      alert.description,
                      style: AppTypography.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      timeago.format(alert.timestamp),
                      style: AppTypography.detail.copyWith(color: AppColors.medium),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alert_model.dart';

// StateNotifier to manage alerts
class AlertsNotifier extends StateNotifier<List<AlertData>> {
  AlertsNotifier() : super(_initialAlerts);

  static final List<AlertData> _initialAlerts = [
    AlertData(
      id: 1,
      title: 'New Listing Match!',
      description: 'A new 3-bedroom home in your preferred area is now available.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      type: AlertType.newListing,
    ),
    AlertData(
      id: 2,
      title: 'Price Reduced',
      description: 'The property at 123 Main St has been reduced by \$25,000.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      type: AlertType.priceChange,
    ),
    AlertData(
      id: 3,
      title: 'Saved Search Alert',
      description: '5 new properties match your saved search criteria.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: AlertType.savedSearch,
    ),
    AlertData(
      id: 4,
      title: 'Upcoming Viewing',
      description: 'Reminder: Your property viewing is scheduled for tomorrow at 2 PM.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: AlertType.appointment,
    ),
  ];

  // Mark an alert as read
  void markAsRead(int alertId) {
    state = state.map((alert) {
      if (alert.id == alertId) {
        return AlertData(
          id: alert.id,
          title: alert.title,
          description: alert.description,
          timestamp: alert.timestamp,
          isRead: true,
          type: alert.type,
        );
      }
      return alert;
    }).toList();
  }

  // Mark all alerts as read
  void markAllAsRead() {
    state = state.map((alert) {
      return AlertData(
        id: alert.id,
        title: alert.title,
        description: alert.description,
        timestamp: alert.timestamp,
        isRead: true,
        type: alert.type,
      );
    }).toList();
  }

  // Add a new alert
  void addAlert(AlertData alert) {
    state = [alert, ...state];
  }

  // Remove an alert
  void removeAlert(int alertId) {
    state = state.where((alert) => alert.id != alertId).toList();
  }

  // Get unread alerts count
  int get unreadCount => state.where((alert) => !alert.isRead).length;
}

// Provider for alerts
final alertsProvider = StateNotifierProvider<AlertsNotifier, List<AlertData>>((ref) {
  return AlertsNotifier();
});

// Provider for unread alerts count
final unreadAlertsCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsProvider);
  return alerts.where((alert) => !alert.isRead).length;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'alerts_provider.dart';
import 'messages_provider.dart';

// Class to hold unread badge counts
class UnreadBadges {
  final int messages;
  final int alerts;

  UnreadBadges({required this.messages, required this.alerts});
}

// Provider that combines unread counts from messages and alerts
final unreadBadgesProvider = Provider<UnreadBadges>((ref) {
  final unreadMessages = ref.watch(unreadMessagesCountProvider);
  final unreadAlerts = ref.watch(unreadAlertsCountProvider);

  return UnreadBadges(messages: unreadMessages, alerts: unreadAlerts);
});

// Data class for alerts/notifications
class AlertData {
  final int id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final AlertType type;

  AlertData({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });
}

enum AlertType {
  newListing,
  priceChange,
  savedSearch,
  appointment,
}

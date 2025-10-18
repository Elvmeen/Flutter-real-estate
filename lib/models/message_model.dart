// Data class for messages
class MessageData {
  final int id;
  final String senderName;
  final String senderPhoto;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String propertyTitle;

  MessageData({
    required this.id,
    required this.senderName,
    required this.senderPhoto,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.propertyTitle,
  });
}

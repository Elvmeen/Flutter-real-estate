// Data class for Messages
class MessageData {
  final int id;
  final int senderId;
  final int recipientId;
  final String senderName;
  final String recipientName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? propertyTitle;
  final int? propertyId;

  MessageData({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.senderName,
    required this.recipientName,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.propertyTitle,
    this.propertyId,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      id: json['id'] ?? 0,
      senderId: json['senderId'] ?? 0,
      recipientId: json['recipientId'] ?? 0,
      senderName: json['senderName'] ?? '',
      recipientName: json['recipientName'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      propertyTitle: json['propertyTitle'],
      propertyId: json['propertyId'],
    );
  }
}

// Conversation preview for message list
class ConversationPreview {
  final int contactId;
  final String contactName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool hasUnread;
  final int unreadCount;

  ConversationPreview({
    required this.contactId,
    required this.contactName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.hasUnread,
    required this.unreadCount,
  });
}

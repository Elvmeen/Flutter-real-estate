class MessageData {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? propertyId;

  MessageData({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.propertyId,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      propertyId: json['propertyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'propertyId': propertyId,
    };
  }
}

class ConversationData {
  final String id;
  final List<String> participantIds;
  final MessageData? lastMessage;
  final DateTime lastActivity;
  final String? propertyId;
  final int unreadCount;

  ConversationData({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.lastActivity,
    this.propertyId,
    this.unreadCount = 0,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) {
    return ConversationData(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      lastMessage: json['lastMessage'] != null 
          ? MessageData.fromJson(json['lastMessage']) 
          : null,
      lastActivity: DateTime.parse(json['lastActivity']),
      propertyId: json['propertyId'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

enum MessageType {
  text,
  image,
  propertyInquiry,
  scheduleTour,
  makeOffer,
}
enum MessageType { text, image, voice, video, file, emoji }

enum MessageStatus { sending, sent, delivered, read, failed }

class Message {
  final String id;
  final String senderId;
  final String? receiverId;
  final String? chatRoomId;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isDeleted;
  final bool isDeletedForEveryone;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.chatRoomId,
    required this.type,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.isDeleted = false,
    this.isDeletedForEveryone = false,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      chatRoomId: json['chatRoomId'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      isDeleted: json['isDeleted'] ?? false,
      isDeletedForEveryone: json['isDeletedForEveryone'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'chatRoomId': chatRoomId,
      'type': type.toString().split('.').last,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'isDeleted': isDeleted,
      'isDeletedForEveryone': isDeletedForEveryone,
      'metadata': metadata,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? chatRoomId,
    MessageType? type,
    String? content,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isDeleted,
    bool? isDeletedForEveryone,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      metadata: metadata ?? this.metadata,
    );
  }
}

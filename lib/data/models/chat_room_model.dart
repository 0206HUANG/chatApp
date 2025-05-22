enum ChatRoomType { private, group }

class ChatRoom {
  final String id;
  final String name;
  final String? avatar;
  final ChatRoomType type;
  final List<String> memberIds;
  final List<String>? adminIds;
  final String? lastMessageId;
  final String? lastMessageText;
  final int unreadCount;
  final String? announcement;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.name,
    this.avatar,
    required this.type,
    required this.memberIds,
    this.adminIds,
    this.lastMessageId,
    this.lastMessageText,
    this.unreadCount = 0,
    this.announcement,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      type: ChatRoomType.values.firstWhere(
        (e) => e.toString() == 'ChatRoomType.${json['type']}',
        orElse: () => ChatRoomType.private,
      ),
      memberIds: List<String>.from(json['memberIds']),
      adminIds:
          json['adminIds'] != null ? List<String>.from(json['adminIds']) : null,
      lastMessageId: json['lastMessageId'],
      lastMessageText: json['lastMessageText'],
      unreadCount: json['unreadCount'] ?? 0,
      announcement: json['announcement'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'type': type.toString().split('.').last,
      'memberIds': memberIds,
      'adminIds': adminIds,
      'lastMessageId': lastMessageId,
      'lastMessageText': lastMessageText,
      'unreadCount': unreadCount,
      'announcement': announcement,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool isGroupChat() {
    return type == ChatRoomType.group;
  }

  bool isAdmin(String userId) {
    return adminIds?.contains(userId) ?? false;
  }

  bool isMember(String userId) {
    return memberIds.contains(userId);
  }

  ChatRoom copyWith({
    String? id,
    String? name,
    String? avatar,
    ChatRoomType? type,
    List<String>? memberIds,
    List<String>? adminIds,
    String? lastMessageId,
    String? lastMessageText,
    int? unreadCount,
    String? announcement,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      type: type ?? this.type,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      unreadCount: unreadCount ?? this.unreadCount,
      announcement: announcement ?? this.announcement,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

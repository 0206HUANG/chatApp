import 'dart:async';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'mock_data_service.dart';

class ChatService {
  final StreamController<Message> _messageStreamController =
      StreamController<Message>.broadcast();
  final StreamController<User> _userStatusStreamController =
      StreamController<User>.broadcast();
  final StreamController<ChatRoom> _chatRoomStreamController =
      StreamController<ChatRoom>.broadcast();

  String? _currentUserId;

  Stream<Message> get messageStream => _messageStreamController.stream;
  Stream<User> get userStatusStream => _userStatusStreamController.stream;
  Stream<ChatRoom> get chatRoomStream => _chatRoomStreamController.stream;

  void init(String userId) {
    _currentUserId = userId;

    // Simulate user status changes
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentUserId == null) {
        timer.cancel();
        return;
      }

      final users = MockDataService.getUsers();
      if (users.length > 1) {
        final otherUser = users.firstWhere((user) => user.id != _currentUserId);
        final updatedUser = User(
          id: otherUser.id,
          name: otherUser.name,
          avatar: otherUser.avatar,
          isOnline: !otherUser.isOnline, // Toggle online status
          lastSeen: otherUser.isOnline ? DateTime.now() : otherUser.lastSeen,
        );

        _userStatusStreamController.add(updatedUser);
      }
    });
  }

  // Send message
  void sendMessage(Message message) {
    // In a real app, this would call an API to send the message to the server
    // Simulate delay, then change status to sent
    Future.delayed(const Duration(milliseconds: 500), () {
      final updatedMessage = message.copyWith(status: MessageStatus.sent);
      _messageStreamController.add(updatedMessage);
    });

    // Update chat room's last message
    for (final room in MockDataService.getChatRooms()) {
      if (room.id == message.chatRoomId) {
        final updatedRoom = room.copyWith(
          lastMessageText: message.content,
          lastMessageId: message.id,
          updatedAt: DateTime.now(),
        );
        _chatRoomStreamController.add(updatedRoom);
        break;
      }
    }
  }

  // Update message status
  void updateMessageStatus(String messageId, MessageStatus status) {
    // In a real app, this would call an API to update the message status
  }

  // Recall message
  void recallMessage(String messageId, bool forEveryone) {
    // In a real app, this would call an API to recall the message
  }

  // Create group
  void createGroup(ChatRoom chatRoom) {
    // In a real app, this would call an API to create the group
    _chatRoomStreamController.add(chatRoom);
  }

  // Invite users to group
  void inviteToGroup(String chatRoomId, List<String> userIds) {
    // In a real app, this would call an API to invite users to the group
    // Simulate successful invite response
    for (final room in MockDataService.getChatRooms()) {
      if (room.id == chatRoomId) {
        final newMemberIds = [...room.memberIds, ...userIds];
        final updatedRoom = room.copyWith(memberIds: newMemberIds);
        _chatRoomStreamController.add(updatedRoom);
        break;
      }
    }
  }

  // Remove group member
  void removeFromGroup(String chatRoomId, String userId) {
    // In a real app, this would call an API to remove a group member
    // Simulate successful remove response
    for (final room in MockDataService.getChatRooms()) {
      if (room.id == chatRoomId) {
        final newMemberIds =
            room.memberIds.where((id) => id != userId).toList();
        final updatedRoom = room.copyWith(memberIds: newMemberIds);
        _chatRoomStreamController.add(updatedRoom);
        break;
      }
    }
  }

  // Set group admin
  void setGroupAdmin(String chatRoomId, String userId, bool isAdmin) {
    // In a real app, this would call an API to set/unset admin status
    // Simulate successful response
    for (final room in MockDataService.getChatRooms()) {
      if (room.id == chatRoomId) {
        List<String> newAdminIds = [...room.adminIds ?? []];
        if (isAdmin && !newAdminIds.contains(userId)) {
          newAdminIds.add(userId);
        } else if (!isAdmin) {
          newAdminIds.remove(userId);
        }
        final updatedRoom = room.copyWith(adminIds: newAdminIds);
        _chatRoomStreamController.add(updatedRoom);
        break;
      }
    }
  }

  // Update group announcement
  void updateGroupAnnouncement(String chatRoomId, String announcement) {
    // In a real app, this would call an API to update the group announcement
    // Simulate successful response
    for (final room in MockDataService.getChatRooms()) {
      if (room.id == chatRoomId) {
        final updatedRoom = room.copyWith(announcement: announcement);
        _chatRoomStreamController.add(updatedRoom);
        break;
      }
    }
  }

  void dispose() {
    _currentUserId = null;
    _messageStreamController.close();
    _userStatusStreamController.close();
    _chatRoomStreamController.close();
  }
}

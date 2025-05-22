import '../models/user_model.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class MockDataService {
  // Mock user data
  static List<User> getUsers() {
    return [
      User(
        id: 'user1',
        name: 'Current User',
        avatar: 'https://via.placeholder.com/150',
        isOnline: true,
      ),
      User(
        id: 'user2',
        name: 'John Doe',
        avatar: 'https://via.placeholder.com/150',
        isOnline: true,
      ),
      User(
        id: 'user3',
        name: 'Jane Smith',
        avatar: 'https://via.placeholder.com/150',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      User(
        id: 'user4',
        name: 'Mike Johnson',
        avatar: 'https://via.placeholder.com/150',
        isOnline: true,
      ),
      User(
        id: 'user5',
        name: 'Sarah Williams',
        avatar: 'https://via.placeholder.com/150',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  // Mock chat room data
  static List<ChatRoom> getChatRooms() {
    final DateTime now = DateTime.now();

    return [
      ChatRoom(
        id: 'chatroom1',
        name: 'John Doe',
        type: ChatRoomType.private,
        memberIds: ['user1', 'user2'],
        lastMessageText: 'Hi, how are you doing?',
        lastMessageId: 'msg1',
        unreadCount: 0,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ),
      ChatRoom(
        id: 'chatroom2',
        name: 'Jane Smith',
        type: ChatRoomType.private,
        memberIds: ['user1', 'user3'],
        lastMessageText: 'Are you free this weekend?',
        lastMessageId: 'msg3',
        unreadCount: 2,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      ChatRoom(
        id: 'chatroom3',
        name: 'Project Discussion',
        avatar: 'https://via.placeholder.com/150',
        type: ChatRoomType.group,
        memberIds: ['user1', 'user2', 'user3', 'user4'],
        adminIds: ['user1', 'user2'],
        lastMessageText: 'Meeting scheduled for Monday at 10 AM',
        lastMessageId: 'msg5',
        unreadCount: 5,
        announcement: 'Please attend the project kickoff meeting',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      ChatRoom(
        id: 'chatroom4',
        name: 'Friends Group',
        avatar: 'https://via.placeholder.com/150',
        type: ChatRoomType.group,
        memberIds: ['user1', 'user2', 'user3', 'user5'],
        adminIds: ['user1'],
        lastMessageText: 'Any plans for the weekend?',
        lastMessageId: 'msg8',
        unreadCount: 0,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Mock message data
  static Map<String, List<Message>> getMessages() {
    final DateTime now = DateTime.now();

    // Create maps for chat rooms
    final Map<String, List<Message>> messages = {
      'chatroom1': [],
      'chatroom2': [],
      'chatroom3': [],
      'chatroom4': [],
    };

    // Add messages for chatroom1
    messages['chatroom1']!.addAll([
      Message(
        id: 'msg1',
        chatRoomId: 'chatroom1',
        senderId: 'user2',
        content: 'Hi, how are you doing?',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 5)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'msg2',
        chatRoomId: 'chatroom1',
        senderId: 'user1',
        content: 'I\'m good! Just working on the new app design.',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 4)),
        status: MessageStatus.delivered,
      ),
    ]);

    // Add messages for chatroom2
    messages['chatroom2']!.addAll([
      Message(
        id: 'msg3',
        chatRoomId: 'chatroom2',
        senderId: 'user3',
        content: 'Are you free this weekend?',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(hours: 1)),
        status: MessageStatus.delivered,
      ),
      Message(
        id: 'msg4',
        chatRoomId: 'chatroom2',
        senderId: 'user3',
        content: 'I was thinking we could check out that new restaurant.',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(hours: 1)),
        status: MessageStatus.delivered,
      ),
    ]);

    // Add messages for chatroom3
    messages['chatroom3']!.addAll([
      Message(
        id: 'msg5',
        chatRoomId: 'chatroom3',
        senderId: 'user2',
        content: 'Meeting scheduled for Monday at 10 AM',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 30)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'msg6',
        chatRoomId: 'chatroom3',
        senderId: 'user4',
        content: 'I\'ll prepare the presentation slides.',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 25)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'msg7',
        chatRoomId: 'chatroom3',
        senderId: 'user3',
        content: 'Great! I\'ll review the project requirements.',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 20)),
        status: MessageStatus.read,
      ),
    ]);

    // Add messages for chatroom4
    messages['chatroom4']!.addAll([
      Message(
        id: 'msg8',
        chatRoomId: 'chatroom4',
        senderId: 'user5',
        content: 'Any plans for the weekend?',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(days: 1)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'msg9',
        chatRoomId: 'chatroom4',
        senderId: 'user2',
        content: 'I\'m going hiking, anyone interested?',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(days: 1)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'msg10',
        chatRoomId: 'chatroom4',
        senderId: 'user1',
        content: 'I might join. Where are you planning to go?',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(hours: 23)),
        status: MessageStatus.sent,
      ),
    ]);

    return messages;
  }
}

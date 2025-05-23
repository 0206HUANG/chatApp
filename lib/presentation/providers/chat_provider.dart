import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/chat_room_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/chat_service.dart';
import '../../data/services/message_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final MessageService _messageService = MessageService();
  final Uuid _uuid = const Uuid();

  List<ChatRoom> _chatRooms = [];
  Map<String, List<Message>> _messages = {};
  Map<String, User> _users = {};
  String? _currentChatRoomId;
  bool _isLoading = false;
  String? _error;

  List<ChatRoom> get chatRooms => _chatRooms;
  Map<String, List<Message>> get messages => _messages;
  Map<String, User> get users => _users;
  String? get currentChatRoomId => _currentChatRoomId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  late StreamSubscription _messageSubscription;
  late StreamSubscription _userStatusSubscription;
  late StreamSubscription _chatRoomSubscription;

  ChatProvider() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _messageService.init();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Initialize chat service
  void initChatService(String userId) {
    _chatService.init(userId);

    // Listen for message updates from server
    _messageSubscription = _chatService.messageStream.listen((message) {
      handleNewMessage(message);
    });

    // Listen for user status changes
    _userStatusSubscription = _chatService.userStatusStream.listen((user) {
      _users[user.id] = user;
      notifyListeners();
    });

    // Listen for chat room updates
    _chatRoomSubscription = _chatService.chatRoomStream.listen((chatRoom) {
      updateChatRoom(chatRoom);
    });
  }

  // Internal method to handle new messages, same functionality as public method
  void _handleNewMessage(Message message) {
    handleNewMessage(message);
  }

  // Handle new message
  void handleNewMessage(Message message) {
    // Update local message list
    if (_messages.containsKey(message.chatRoomId)) {
      final List<Message> roomMessages = _messages[message.chatRoomId]!;
      final int existingIndex = roomMessages.indexWhere(
        (m) => m.id == message.id,
      );

      if (existingIndex >= 0) {
        // If message already exists, update it
        roomMessages[existingIndex] = message;
      } else {
        // Otherwise add new message
        roomMessages.add(message);
        roomMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } else {
      // If message list for this chat room doesn't exist, create one
      _messages[message.chatRoomId!] = [message];
    }

    // Save message to local database
    _messageService.saveMessage(message);

    // If this message is not sent by current user, mark as delivered
    if (message.senderId != _users.keys.first &&
        message.status == MessageStatus.sent) {
      _chatService.updateMessageStatus(message.id, MessageStatus.delivered);
    }

    notifyListeners();
  }

  // Internal method to update chat room, same functionality as public method
  void _updateChatRoom(ChatRoom chatRoom) {
    updateChatRoom(chatRoom);
  }

  // Update chat room information
  void updateChatRoom(ChatRoom chatRoom) {
    final int index = _chatRooms.indexWhere((room) => room.id == chatRoom.id);

    if (index >= 0) {
      _chatRooms[index] = chatRoom;
    } else {
      _chatRooms.add(chatRoom);
    }

    // Sort by latest message
    _chatRooms.sort((a, b) {
      if (a.lastMessageId == null) return 1;
      if (b.lastMessageId == null) return -1;

      final DateTime timeA =
          _messages[a.id]
              ?.where((m) => m.id == a.lastMessageId)
              .firstOrNull
              ?.timestamp ??
          DateTime(0);
      final DateTime timeB =
          _messages[b.id]
              ?.where((m) => m.id == b.lastMessageId)
              .firstOrNull
              ?.timestamp ??
          DateTime(0);

      return timeB.compareTo(timeA);
    });

    notifyListeners();
  }

  // Load chat room list
  Future<void> loadChatRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This should load chat room list from API, but since there's no actual backend, use mock data
      // TODO: Implement real API call
      await Future.delayed(const Duration(seconds: 1));

      _chatRooms = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load messages for specific chat room
  Future<void> loadMessages(String chatRoomId) async {
    _isLoading = true;
    _currentChatRoomId = chatRoomId;
    notifyListeners();

    try {
      final messages = await _messageService.getMessages(chatRoomId);
      _messages[chatRoomId] = messages;

      // Mark all received unread messages as read
      for (final message in messages) {
        if (message.status == MessageStatus.delivered &&
            message.senderId != _users.keys.first) {
          _chatService.updateMessageStatus(message.id, MessageStatus.read);
        }
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<void> sendMessage({
    required String content,
    required String chatRoomId,
    required String receiverId,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    final String currentUserId = _users.keys.first;

    // Create new message
    final message = Message(
      id: _uuid.v4(),
      senderId: currentUserId,
      receiverId: receiverId,
      chatRoomId: chatRoomId,
      type: type,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      metadata: metadata,
    );

    // Add message locally first
    handleNewMessage(message);

    // Send message to server
    _chatService.sendMessage(message);
  }

  // Send image message
  Future<void> sendImage(
    File image,
    String chatRoomId,
    String receiverId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Upload image
      final String url = await _messageService.uploadMedia(
        image,
        MessageType.image,
      );

      // Send message
      await sendMessage(
        content: url,
        chatRoomId: chatRoomId,
        receiverId: receiverId,
        type: MessageType.image,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Recall message
  Future<void> recallMessage(String messageId, bool forEveryone) async {
    _chatService.recallMessage(messageId, forEveryone);
    await _messageService.markMessageDeleted(messageId, forEveryone);

    // Update local message list
    for (final chatRoomId in _messages.keys) {
      final List<Message> roomMessages = _messages[chatRoomId]!;
      final int index = roomMessages.indexWhere((m) => m.id == messageId);

      if (index >= 0) {
        roomMessages[index] = roomMessages[index].copyWith(
          isDeleted: true,
          isDeletedForEveryone: forEveryone,
        );
        notifyListeners();
        break;
      }
    }
  }

  // Create group chat
  Future<ChatRoom?> createGroup(String name, List<String> memberIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String currentUserId = _users.keys.first;

      // Ensure creator is also in member list
      if (!memberIds.contains(currentUserId)) {
        memberIds.add(currentUserId);
      }

      final ChatRoom chatRoom = ChatRoom(
        id: _uuid.v4(),
        name: name,
        type: ChatRoomType.group,
        memberIds: memberIds,
        adminIds: [currentUserId],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _chatService.createGroup(chatRoom);
      _chatRooms.add(chatRoom);

      notifyListeners();
      return chatRoom;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add users to group
  void inviteToGroup(String chatRoomId, List<String> userIds) {
    _chatService.inviteToGroup(chatRoomId, userIds);
  }

  // Remove user from group
  void removeFromGroup(String chatRoomId, String userId) {
    _chatService.removeFromGroup(chatRoomId, userId);
  }

  // Set group admin
  void setGroupAdmin(String chatRoomId, String userId, bool isAdmin) {
    _chatService.setGroupAdmin(chatRoomId, userId, isAdmin);
  }

  // Update group announcement
  void updateGroupAnnouncement(String chatRoomId, String announcement) {
    _chatService.updateGroupAnnouncement(chatRoomId, announcement);
  }

  // Update user
  void updateUser(User user) {
    _users[user.id] = user;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _userStatusSubscription.cancel();
    _chatRoomSubscription.cancel();
    _chatService.dispose();
    _messageService.dispose();
    super.dispose();
  }
}

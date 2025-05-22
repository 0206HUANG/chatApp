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

  // 初始化聊天服务
  void initChatService(String userId) {
    _chatService.init(userId);

    // 监听来自服务器的消息更新
    _messageSubscription = _chatService.messageStream.listen((message) {
      handleNewMessage(message);
    });

    // 监听用户状态变化
    _userStatusSubscription = _chatService.userStatusStream.listen((user) {
      _users[user.id] = user;
      notifyListeners();
    });

    // 监听聊天室更新
    _chatRoomSubscription = _chatService.chatRoomStream.listen((chatRoom) {
      updateChatRoom(chatRoom);
    });
  }

  // 内部处理新消息的方法，与公开方法功能相同
  void _handleNewMessage(Message message) {
    handleNewMessage(message);
  }

  // 处理新消息
  void handleNewMessage(Message message) {
    // 更新本地消息列表
    if (_messages.containsKey(message.chatRoomId)) {
      final List<Message> roomMessages = _messages[message.chatRoomId]!;
      final int existingIndex = roomMessages.indexWhere(
        (m) => m.id == message.id,
      );

      if (existingIndex >= 0) {
        // 如果消息已存在，则更新它
        roomMessages[existingIndex] = message;
      } else {
        // 否则添加新消息
        roomMessages.add(message);
        roomMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } else {
      // 如果这个聊天室的消息列表还不存在，则创建一个
      _messages[message.chatRoomId!] = [message];
    }

    // 保存消息到本地数据库
    _messageService.saveMessage(message);

    // 如果这个消息不是当前用户发送的，标记已送达
    if (message.senderId != _users.keys.first &&
        message.status == MessageStatus.sent) {
      _chatService.updateMessageStatus(message.id, MessageStatus.delivered);
    }

    notifyListeners();
  }

  // 内部更新聊天室的方法，与公开方法功能相同
  void _updateChatRoom(ChatRoom chatRoom) {
    updateChatRoom(chatRoom);
  }

  // 更新聊天室信息
  void updateChatRoom(ChatRoom chatRoom) {
    final int index = _chatRooms.indexWhere((room) => room.id == chatRoom.id);

    if (index >= 0) {
      _chatRooms[index] = chatRoom;
    } else {
      _chatRooms.add(chatRoom);
    }

    // 按最近消息排序
    _chatRooms.sort((a, b) {
      if (a.lastMessageId == null) return 1;
      if (b.lastMessageId == null) return -1;

      final DateTime timeA =
          _messages[a.id]
              ?.firstWhere((m) => m.id == a.lastMessageId)
              ?.timestamp ??
          DateTime(0);
      final DateTime timeB =
          _messages[b.id]
              ?.firstWhere((m) => m.id == b.lastMessageId)
              ?.timestamp ??
          DateTime(0);

      return timeB.compareTo(timeA);
    });

    notifyListeners();
  }

  // 加载聊天室列表
  Future<void> loadChatRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 这里应该是从API加载聊天室列表，但由于没有实际后端，先使用模拟数据
      // TODO: 实现真实API调用
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

  // 加载特定聊天室的消息
  Future<void> loadMessages(String chatRoomId) async {
    _isLoading = true;
    _currentChatRoomId = chatRoomId;
    notifyListeners();

    try {
      final messages = await _messageService.getMessages(chatRoomId);
      _messages[chatRoomId] = messages;

      // 将所有接收到的未读消息标记为已读
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

  // 发送消息
  Future<void> sendMessage({
    required String content,
    required String chatRoomId,
    required String receiverId,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    final String currentUserId = _users.keys.first;

    // 创建新消息
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

    // 先在本地添加消息
    handleNewMessage(message);

    // 发送消息到服务器
    _chatService.sendMessage(message);
  }

  // 发送图片消息
  Future<void> sendImage(
    File image,
    String chatRoomId,
    String receiverId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 上传图片
      final String url = await _messageService.uploadMedia(
        image,
        MessageType.image,
      );

      // 发送消息
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

  // 撤回消息
  Future<void> recallMessage(String messageId, bool forEveryone) async {
    _chatService.recallMessage(messageId, forEveryone);
    await _messageService.markMessageDeleted(messageId, forEveryone);

    // 更新本地消息列表
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

  // 创建群聊
  Future<ChatRoom?> createGroup(String name, List<String> memberIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String currentUserId = _users.keys.first;

      // 确保创建者也在成员列表中
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

  // 添加用户到群组
  void inviteToGroup(String chatRoomId, List<String> userIds) {
    _chatService.inviteToGroup(chatRoomId, userIds);
  }

  // 从群组移除用户
  void removeFromGroup(String chatRoomId, String userId) {
    _chatService.removeFromGroup(chatRoomId, userId);
  }

  // 设置群管理员
  void setGroupAdmin(String chatRoomId, String userId, bool isAdmin) {
    _chatService.setGroupAdmin(chatRoomId, userId, isAdmin);
  }

  // 更新群公告
  void updateGroupAnnouncement(String chatRoomId, String announcement) {
    _chatService.updateGroupAnnouncement(chatRoomId, announcement);
  }

  // 更新用户
  void updateUser(User user) {
    _users[user.id] = user;
    notifyListeners();
  }

  // 清除错误
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

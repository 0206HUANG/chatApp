import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data/models/chat_room_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/user_model.dart';
import '../providers/chat_provider.dart';
import '../providers/call_provider.dart';
import '../../data/services/mock_data_service.dart';
import 'group_info_screen.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _showEmojiPicker = false;
  bool _isComposing = false;

  String get _currentUserId => MockDataService.getUsers().first.id;

  @override
  void initState() {
    super.initState();
    // Load chat history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadMessages(widget.chatRoom.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Send text message
  Future<void> _sendTextMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final message = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    final receiverId = widget.chatRoom.memberIds.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => '',
    );

    await chatProvider.sendMessage(
      content: message,
      chatRoomId: widget.chatRoom.id,
      receiverId: receiverId,
      type: MessageType.text,
    );

    _scrollToBottom();
  }

  // Pick and send image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final receiverId = widget.chatRoom.memberIds.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => '',
    );

    await chatProvider.sendImage(
      File(image.path),
      widget.chatRoom.id,
      receiverId,
    );

    _scrollToBottom();
  }

  // Toggle emoji picker
  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  // Emoji selected
  void _onEmojiSelected(Category? category, Emoji emoji) {
    _messageController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    setState(() {
      _isComposing = _messageController.text.isNotEmpty;
    });
  }

  // Show message options menu
  void _showMessageOptions(Message message) {
    if (message.senderId != _currentUserId) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete for me only'),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Delete for everyone'),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message, true);
              },
            ),
          ],
        );
      },
    );
  }

  // Delete message
  Future<void> _deleteMessage(Message message, bool forEveryone) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.recallMessage(message.id, forEveryone);
  }

  // Start call
  void _startCall(bool isVideo) {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final receiverIds =
        widget.chatRoom.memberIds.where((id) => id != _currentUserId).toList();

    // Start call
    callProvider.startCall(
      channelId: widget.chatRoom.id,
      participants: receiverIds,
      isVideo: isVideo,
    );

    // Navigate to call screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CallScreen()),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.messages[widget.chatRoom.id] ?? [];
    final otherUserId = widget.chatRoom.memberIds.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => '',
    );
    final otherUser = chatProvider.users[otherUserId];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.chatRoom.avatar != null
                      ? NetworkImage(widget.chatRoom.avatar!)
                      : null,
              child:
                  widget.chatRoom.avatar == null
                      ? Text(widget.chatRoom.name[0])
                      : null,
              radius: 16,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.chatRoom.name),
                if (widget.chatRoom.type == ChatRoomType.private &&
                    otherUser != null)
                  Text(
                    otherUser.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: otherUser.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startCall(false),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall(true),
          ),
          if (widget.chatRoom.type == ChatRoomType.group)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GroupInfoScreen(chatRoom: widget.chatRoom),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showEmojiPicker = false),
              child:
                  chatProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                      ? const Center(child: Text('No messages'))
                      : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == _currentUserId;
                          final sender = chatProvider.users[message.senderId];

                          if (message.isDeleted) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              child: Center(
                                child: Text(
                                  message.isDeletedForEveryone
                                      ? 'This message was deleted'
                                      : isMe
                                      ? 'You deleted this message'
                                      : '${sender?.name ?? ''} deleted this message',
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }

                          return GestureDetector(
                            onLongPress: () => _showMessageOptions(message),
                            child: Align(
                              alignment:
                                  isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: isMe ? 64.0 : 16.0,
                                  right: isMe ? 16.0 : 64.0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isMe
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    if (widget.chatRoom.type ==
                                            ChatRoomType.group &&
                                        !isMe &&
                                        sender != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4.0,
                                        ),
                                        child: Text(
                                          sender.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color:
                                                isMe
                                                    ? Colors.white70
                                                    : Theme.of(
                                                      context,
                                                    ).hintColor,
                                          ),
                                        ),
                                      ),
                                    _buildMessageContent(message, isMe),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                isMe
                                                    ? Colors.white70
                                                    : Theme.of(
                                                      context,
                                                    ).hintColor,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        if (isMe)
                                          Icon(
                                            _getStatusIcon(message.status),
                                            size: 12,
                                            color: Colors.white70,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
          // Input area
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                  ),
                  onPressed: _toggleEmojiPicker,
                ),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.isNotEmpty;
                      });
                    },
                    onSubmitted: (text) => _sendTextMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color:
                      _isComposing
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                  onPressed: _isComposing ? _sendTextMessage : null,
                ),
              ],
            ),
          ),
          // Emoji picker
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: _onEmojiSelected,
                config: Config(
                  columns: 7,
                  emojiSizeMax: 32.0,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  initCategory: Category.RECENT,
                  bgColor: Theme.of(context).scaffoldBackgroundColor,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build different types of message content
  Widget _buildMessageContent(Message message, bool isMe) {
    switch (message.type) {
      case MessageType.text:
        return MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: isMe ? Colors.white : null),
          ),
        );
      case MessageType.image:
        return GestureDetector(
          onTap: () {
            // TODO: Implement full screen image view
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message.content,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 100,
                  width: 200,
                  child: Icon(Icons.broken_image),
                );
              },
            ),
          ),
        );
      default:
        return Text(
          message.content,
          style: TextStyle(color: isMe ? Colors.white : null),
        );
    }
  }

  // Get message status icon
  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
      default:
        return Icons.check;
    }
  }

  // Format message time
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays > 0) {
      return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

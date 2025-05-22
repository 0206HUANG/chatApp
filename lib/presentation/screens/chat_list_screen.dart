import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../data/services/mock_data_service.dart';
import '../../data/models/chat_room_model.dart';
import '../../data/models/user_model.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'create_group_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize with mock data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMockData();
    });
  }

  // Initialize mock data
  void _initializeMockData() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Update mock users
    for (final user in MockDataService.getUsers()) {
      chatProvider.updateUser(user);
    }

    // Add chat rooms
    for (final room in MockDataService.getChatRooms()) {
      chatProvider.updateChatRoom(room);
    }

    // Add messages
    final messages = MockDataService.getMessages();
    for (final chatRoomId in messages.keys) {
      for (final message in messages[chatRoomId]!) {
        chatProvider.handleNewMessage(message);
      }
    }

    // Initialize chat service using the first user as current user
    chatProvider.initChatService(MockDataService.getUsers().first.id);
  }

  // Show new chat dialog
  void _showNewChatDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('New Private Chat'),
              onTap: () {
                Navigator.pop(context);
                _showUserSelectionDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('New Group Chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Show user selection dialog
  void _showUserSelectionDialog() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUserId = MockDataService.getUsers().first.id;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Contact'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: chatProvider.users.length,
              itemBuilder: (context, index) {
                final user = chatProvider.users.values.elementAt(index);

                if (user.id == currentUserId) {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        user.avatar != null ? NetworkImage(user.avatar!) : null,
                    child: user.avatar == null ? Text(user.name[0]) : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.isOnline ? 'Online' : 'Offline'),
                  onTap: () {
                    Navigator.pop(context);

                    // Open chat screen
                    final chatRoom = chatProvider.chatRooms.firstWhere(
                      (room) =>
                          room.type == ChatRoomType.private &&
                          room.memberIds.contains(user.id) &&
                          room.memberIds.contains(currentUserId),
                      orElse:
                          () => ChatRoom(
                            id: 'temp_${user.id}',
                            name: user.name,
                            type: ChatRoomType.private,
                            memberIds: [currentUserId, user.id],
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatRoom: chatRoom),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body:
          chatProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : chatProvider.chatRooms.isEmpty
              ? const Center(child: Text('No chat history'))
              : ListView.separated(
                itemCount: chatProvider.chatRooms.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final chatRoom = chatProvider.chatRooms[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          chatRoom.avatar != null
                              ? NetworkImage(chatRoom.avatar!)
                              : null,
                      child:
                          chatRoom.avatar == null
                              ? Text(chatRoom.name[0])
                              : null,
                    ),
                    title: Text(chatRoom.name),
                    subtitle: Text(
                      chatRoom.lastMessageText ?? 'No messages',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatLastMessageTime(chatRoom.updatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (chatRoom.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              chatRoom.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(chatRoom: chatRoom),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Format last message time
  String _formatLastMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

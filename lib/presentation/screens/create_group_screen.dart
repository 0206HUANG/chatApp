import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/chat_room_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  final List<User> users;

  const CreateGroupScreen({Key? key, required this.users}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedUserIds = {};

  // Create group chat
  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter group name')));
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;

    // Create group chat
    final chatRoom = await chatProvider.createGroup(
      _nameController.text.trim(),
      [..._selectedUserIds.toList(), currentUser.id],
    );

    // Navigate to chat page on successful creation
    if (mounted && chatRoom != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ChatScreen(chatRoom: chatRoom)),
      );
    }
  }

  // Select/deselect user
  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    // Filter out current user
    final availableUsers =
        widget.users.where((user) => user.id != currentUser?.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          TextButton(onPressed: _createGroup, child: const Text('Create')),
        ],
      ),
      body: Column(
        children: [
          // Group name input field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Number of selected users
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Contacts (${_selectedUserIds.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const Divider(),
          // Contact list
          Expanded(
            child: ListView.builder(
              itemCount: availableUsers.length,
              itemBuilder: (context, index) {
                final user = availableUsers[index];
                final isSelected = _selectedUserIds.contains(user.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleUserSelection(user.id),
                  title: Text(user.name),
                  subtitle: Text(user.isOnline ? 'Online' : 'Offline'),
                  secondary: CircleAvatar(
                    backgroundImage:
                        user.avatar != null ? NetworkImage(user.avatar!) : null,
                    child: user.avatar == null ? Text(user.name[0]) : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

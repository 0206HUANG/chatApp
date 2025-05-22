import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/chat_room_model.dart';
import '../providers/chat_provider.dart';
import '../../data/services/mock_data_service.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const GroupInfoScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final TextEditingController _announcementController = TextEditingController();
  bool _isEditingAnnouncement = false;

  String get _currentUserId => MockDataService.getUsers().first.id;

  @override
  void initState() {
    super.initState();
    _announcementController.text = widget.chatRoom.announcement ?? '';
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  // Leave group
  void _leaveGroup() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Leave Group'),
            content: const Text('Are you sure you want to leave this group?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final chatProvider = Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  );
                  chatProvider.removeFromGroup(
                    widget.chatRoom.id,
                    _currentUserId,
                  );

                  // Return to chat list screen
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Update group announcement
  void _updateAnnouncement() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.updateGroupAnnouncement(
      widget.chatRoom.id,
      _announcementController.text,
    );
    setState(() {
      _isEditingAnnouncement = false;
    });
  }

  // Show add members dialog
  void _showAddMembersDialog() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    // Get all users not in the group
    final nonMembers =
        chatProvider.users.values
            .where((user) => !widget.chatRoom.memberIds.contains(user.id))
            .toList();

    if (nonMembers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No members to add')));
      return;
    }

    final selectedUserIds = <String>[];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add Members'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: ListView.builder(
                    itemCount: nonMembers.length,
                    itemBuilder: (context, index) {
                      final user = nonMembers[index];
                      final isSelected = selectedUserIds.contains(user.id);

                      return CheckboxListTile(
                        title: Text(user.name),
                        subtitle: Text(user.isOnline ? 'Online' : 'Offline'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedUserIds.add(user.id);
                            } else {
                              selectedUserIds.remove(user.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (selectedUserIds.isNotEmpty) {
                        chatProvider.inviteToGroup(
                          widget.chatRoom.id,
                          selectedUserIds,
                        );
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Toggle admin status for a member
  void _toggleAdminStatus(String userId) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final isAdmin = widget.chatRoom.isAdmin(userId);

    chatProvider.setGroupAdmin(widget.chatRoom.id, userId, !isAdmin);
  }

  // Remove a member
  void _removeMember(String userId, String userName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Member'),
            content: Text(
              'Are you sure you want to remove $userName from the group?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final chatProvider = Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  );
                  chatProvider.removeFromGroup(widget.chatRoom.id, userId);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final bool isCurrentUserAdmin = widget.chatRoom.isAdmin(_currentUserId);

    // Get group members information
    final members =
        widget.chatRoom.memberIds
            .map((id) => chatProvider.users[id])
            .where((user) => user != null)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Group Info')),
      body: ListView(
        children: [
          // Group avatar and name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      widget.chatRoom.avatar != null
                          ? NetworkImage(widget.chatRoom.avatar!)
                          : null,
                  child:
                      widget.chatRoom.avatar == null
                          ? Text(
                            widget.chatRoom.name[0],
                            style: const TextStyle(fontSize: 32),
                          )
                          : null,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.chatRoom.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.chatRoom.memberIds.length} members',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          const Divider(),
          // Group announcement
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Announcement'),
            subtitle:
                _isEditingAnnouncement
                    ? TextField(
                      controller: _announcementController,
                      decoration: const InputDecoration(
                        hintText: 'Enter announcement',
                      ),
                    )
                    : Text(
                      widget.chatRoom.announcement?.isNotEmpty ?? false
                          ? widget.chatRoom.announcement!
                          : 'No announcement',
                    ),
            trailing:
                isCurrentUserAdmin
                    ? IconButton(
                      icon: Icon(
                        _isEditingAnnouncement ? Icons.check : Icons.edit,
                      ),
                      onPressed: () {
                        if (_isEditingAnnouncement) {
                          _updateAnnouncement();
                        } else {
                          setState(() {
                            _isEditingAnnouncement = true;
                          });
                        }
                      },
                    )
                    : null,
          ),
          const Divider(),
          // Member list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Members',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (isCurrentUserAdmin)
                  TextButton.icon(
                    onPressed: _showAddMembersDialog,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add'),
                  ),
              ],
            ),
          ),
          ...members.map(
            (user) => ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user!.avatar != null ? NetworkImage(user.avatar!) : null,
                child: user.avatar == null ? Text(user.name[0]) : null,
              ),
              title: Row(
                children: [
                  Text(user.name),
                  const SizedBox(width: 8),
                  if (widget.chatRoom.isAdmin(user.id))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    ),
                  if (user.id == _currentUserId)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Me',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                ],
              ),
              subtitle: Text(user.isOnline ? 'Online' : 'Offline'),
              trailing:
                  isCurrentUserAdmin && user.id != _currentUserId
                      ? PopupMenuButton(
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'admin',
                                child: Text(
                                  widget.chatRoom.isAdmin(user.id)
                                      ? 'Remove Admin'
                                      : 'Make Admin',
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Text(
                                  'Remove from Group',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                        onSelected: (value) {
                          if (value == 'admin') {
                            _toggleAdminStatus(user.id);
                          } else if (value == 'remove') {
                            _removeMember(user.id, user.name);
                          }
                        },
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 40),
          // Leave group button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _leaveGroup,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Leave Group'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

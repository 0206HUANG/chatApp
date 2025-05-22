import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../../data/services/mock_data_service.dart';
import 'chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedUserIds = [];
  String get _currentUserId => MockDataService.getUsers().first.id;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 创建群聊
  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入群组名称')));
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少选择一个联系人')));
      return;
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    // 创建群聊
    final chatRoom = await chatProvider.createGroup(_nameController.text, [
      ..._selectedUserIds,
      _currentUserId,
    ]);

    // 创建成功，跳转到聊天页面
    if (chatRoom != null) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => ChatScreen(chatRoom: chatRoom)),
      );
    }
  }

  // 选择/取消选择用户
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
    final chatProvider = Provider.of<ChatProvider>(context);
    // 过滤掉当前用户
    final users =
        chatProvider.users.values
            .where((user) => user.id != _currentUserId)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('创建群聊'),
        actions: [TextButton(onPressed: _createGroup, child: const Text('创建'))],
      ),
      body: Column(
        children: [
          // 群名称输入框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '群组名称',
                prefixIcon: Icon(Icons.group),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // 已选择用户数量
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.person_add),
                const SizedBox(width: 8),
                Text(
                  '选择联系人 (${_selectedUserIds.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // 联系人列表
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = _selectedUserIds.contains(user.id);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        user.avatar != null ? NetworkImage(user.avatar!) : null,
                    child: user.avatar == null ? Text(user.name[0]) : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.isOnline ? '在线' : '离线'),
                  trailing:
                      isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                  onTap: () => _toggleUserSelection(user.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 退出登录
  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // 更新用户资料
  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.updateProfile({'name': _nameController.text});

    setState(() {
      _isEditing = false;
    });
  }

  // 选择头像
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // TODO: 实现头像上传功能
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('头像上传功能待实现')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        actions: [
          if (_isEditing)
            TextButton(onPressed: _updateProfile, child: const Text('保存'))
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('编辑'),
            ),
        ],
      ),
      body:
          user == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 头像
                  Center(
                    child: GestureDetector(
                      onTap: _isEditing ? _pickAvatar : null,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                user.avatar != null
                                    ? NetworkImage(user.avatar!)
                                    : null,
                            child:
                                user.avatar == null
                                    ? Text(
                                      user.name[0],
                                      style: const TextStyle(fontSize: 36),
                                    )
                                    : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 昵称
                  _buildInfoItem(
                    '昵称',
                    _isEditing
                        ? TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: '输入昵称'),
                        )
                        : Text(user.name, style: const TextStyle(fontSize: 16)),
                  ),
                  // 在线状态
                  _buildInfoItem(
                    '状态',
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: user.isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.isOnline ? '在线' : '离线',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // 最后在线时间
                  if (!user.isOnline && user.lastSeen != null)
                    _buildInfoItem(
                      '最后在线',
                      Text(
                        _formatLastSeen(user.lastSeen!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 40),
                  // 退出登录按钮
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('退出登录'),
                  ),
                ],
              ),
    );
  }

  Widget _buildInfoItem(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

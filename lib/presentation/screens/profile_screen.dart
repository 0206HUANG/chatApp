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

  // Logout
  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Update user profile
  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.updateProfile({'name': _nameController.text});

    setState(() {
      _isEditing = false;
    });
  }

  // Pick avatar
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // TODO: Implement avatar upload functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar upload feature coming soon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            TextButton(onPressed: _updateProfile, child: const Text('Save'))
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('Edit'),
            ),
        ],
      ),
      body:
          user == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Avatar
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
                  // Nickname
                  _buildInfoItem(
                    'Nickname',
                    _isEditing
                        ? TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter nickname',
                          ),
                        )
                        : Text(user.name, style: const TextStyle(fontSize: 16)),
                  ),
                  // Online status
                  _buildInfoItem(
                    'Status',
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
                          user.isOnline ? 'Online' : 'Offline',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Last seen time
                  if (!user.isOnline && user.lastSeen != null)
                    _buildInfoItem(
                      'Last seen',
                      Text(
                        _formatLastSeen(user.lastSeen!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 40),
                  // Logout button
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
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

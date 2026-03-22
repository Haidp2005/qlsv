import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/route_constants.dart';
import '../widgets/avatar_picker.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String role; // 'student' hoặc 'lecturer'
  
  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    setState(() {
      _userName = savedName ?? (widget.role == 'student' ? 'Nguyễn Văn Sinh Viên' : 'Tiến sĩ Giảng Viên');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin từ FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    final targetEmail = user?.email ?? (widget.role == 'student' ? 'sv@student.edu.vn' : 'gv@university.edu.vn');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const AvatarPicker(),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              targetEmail,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Chỉnh sửa thông tin cá nhân'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final newName = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen(initialName: _userName)),
                );
                if (newName != null && newName is String) {
                  setState(() {
                    _userName = newName;
                  });
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Đổi mật khẩu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go(RouteConstants.dashboard);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

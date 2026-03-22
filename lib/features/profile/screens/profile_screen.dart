import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    String? foundName;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          final studentId = userData['studentId'] as String? ?? '';
          final role = userData['role'] as String? ?? 'student';

          // Ưu tiên: Tìm tên thật trong CSDL lớp học (nguồn gốc)
          if (role == 'student' && studentId.isNotEmpty) {
            final classSnaps = await FirebaseFirestore.instance
                .collection('classes')
                .where('studentIds', arrayContains: studentId)
                .limit(1)
                .get();
            if (classSnaps.docs.isNotEmpty) {
              final studentSnap = await classSnaps.docs.first.reference
                  .collection('students')
                  .doc(studentId)
                  .get();
              if (studentSnap.exists && studentSnap.data() != null) {
                foundName = studentSnap.data()!['fullName'] as String?;
              }
            }
            // Fallback về fullName ở trang users (do người dùng sửa)
            foundName ??= userData['fullName'] as String?;
            foundName ??= 'Sinh viên $studentId';
          } else {
            // Giảng viên: Ưu tiên users/fullName
            foundName = userData['fullName'] as String?;
            foundName ??= user.email ?? 'Giảng viên';
          }
        }
      }
    } catch (_) {
      // Không có mạng: dùng cache local
      final prefs = await SharedPreferences.getInstance();
      foundName = prefs.getString('user_name');
    }

    // Cập nhật cache local
    if (foundName != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', foundName);
    }

    setState(() {
      _userName = foundName ??
          (widget.role == 'student' ? 'Nguyễn Văn Sinh Viên' : 'Tiến sĩ Giảng Viên');
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
                  context.go(RouteConstants.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  const EditProfileScreen({super.key, required this.initialName});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isSaving = true);

    // 1. Lưu LocalStorage (hiển ngay)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final userData = userDoc.data() ?? {};
        final studentId = userData['studentId'] as String? ?? '';
        final role = userData['role'] as String? ?? 'student';

        // 2. Lưu vào users/{uid}/fullName
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'fullName': newName}, SetOptions(merge: true));

        // 3. Nếu là sinh viên: cập nhật tên trong tất cả lớp học
        if (role == 'student' && studentId.isNotEmpty) {
          final classSnaps = await FirebaseFirestore.instance
              .collection('classes')
              .where('studentIds', arrayContains: studentId)
              .get();

          final batch = FirebaseFirestore.instance.batch();
          for (final classDoc in classSnaps.docs) {
            final studentRef = classDoc.reference.collection('students').doc(studentId);
            batch.set(studentRef, {'fullName': newName}, SetOptions(merge: true));
          }
          await batch.commit();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu: $e')),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật họ tên thành công!')),
      );
      Navigator.pop(context, newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin cá nhân'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.person, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Lưu Thay Đổi', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

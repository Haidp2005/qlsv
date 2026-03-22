import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({super.key});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;
  bool _uploading = false;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final signedUrl = await _supabase.storage
          .from('avatars')
          .createSignedUrl('$uid/avatar.jpg', 60 * 60 * 24);
      if (mounted) {
        setState(() => _avatarUrl = signedUrl);
      }
    } catch (_) {
      // Chưa có ảnh, giữ mặc định
    }
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked == null) return;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      setState(() => _uploading = true);

      final file = File(picked.path);
      await _supabase.storage.from('avatars').upload(
            '$uid/avatar.jpg',
            file,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );

      final signedUrl = await _supabase.storage
          .from('avatars')
          .createSignedUrl('$uid/avatar.jpg', 60 * 60 * 24);

      if (mounted) {
        setState(() {
          _avatarUrl = signedUrl;
          _uploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: $e')),
        );
      }
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
            child: _uploading
                ? const CircularProgressIndicator(color: Colors.white)
                : (_avatarUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null),
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

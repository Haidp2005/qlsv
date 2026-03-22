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

  /// Lấy uid của người dùng hiện tại.
  /// Nếu chưa đăng nhập Firebase (chế độ demo), dùng 'lecturer_demo_001'.
  String get _currentUid {
    return FirebaseAuth.instance.currentUser?.uid ?? 'lecturer_demo_001';
  }

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  /// Hàm phụ trợ: Thêm timestamp vào URL để đánh lừa bộ nhớ đệm (Cache Busting).
  /// Giúp Flutter luôn tải ảnh mới nhất thay vì dùng lại ảnh cũ trong bộ nhớ.
  String _bustCache(String url) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // signedUrl của Supabase thường đã chứa dấu '?' cho tham số bảo mật.
    // Nên ta dùng '&' để nối thêm. Nếu chưa có thì dùng '?'.
    if (url.contains('?')) {
      return '$url&t=$timestamp';
    } else {
      return '$url?t=$timestamp';
    }
  }

  Future<void> _loadAvatar() async {
    final uid = _currentUid;
    try {
      final signedUrl = await _supabase.storage
          .from('avatars')
          .createSignedUrl('$uid/avatar.jpg', 60 * 60 * 24 * 7); // 7 ngày
      
      if (mounted) {
        // Gọi hàm _bustCache trước khi gán vào UI
        setState(() => _avatarUrl = _bustCache(signedUrl));
      }
    } catch (e) {
      debugPrint('[AvatarPicker] Không tải được ảnh: $e');
    }
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked == null) return;

      final uid = _currentUid;

      setState(() => _uploading = true);

      final file = File(picked.path);

      // 1. Xoá ảnh cũ (có thể giữ lại đoạn này để dọn dẹp triệt để)
      try {
        await _supabase.storage.from('avatars').remove(['$uid/avatar.jpg']);
      } catch (e) {
        debugPrint('[AvatarPicker] Không có ảnh cũ để xoá hoặc lỗi: $e');
      }

      // 2. Upload ảnh mới (Sử dụng readAsBytes để đảm bảo lấy dữ liệu mới nhất)
      final bytes = await picked.readAsBytes();
      await _supabase.storage.from('avatars').uploadBinary(
            '$uid/avatar.jpg',
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );

      // Tạo signed URL mới sau khi upload thành công
      final signedUrl = await _supabase.storage
          .from('avatars')
          .createSignedUrl('$uid/avatar.jpg', 60 * 60 * 24 * 7);

      if (mounted) {
        setState(() {
          // Quan trọng: Gọi hàm _bustCache cho URL mới tải lên
          _avatarUrl = _bustCache(signedUrl);
          _uploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
        );
      }
    } on StorageException catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi Supabase Storage: ${e.message}')),
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
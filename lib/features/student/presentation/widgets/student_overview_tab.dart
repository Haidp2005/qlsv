import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import '../../data/models/student_models.dart';

class StudentOverviewTab extends StatelessWidget {
  const StudentOverviewTab({
    super.key,
    required this.data,
    required this.onChangeAvatar,
  });

  final StudentHomeData data;
  final Future<void> Function(String avatarBase64) onChangeAvatar;

  @override
  Widget build(BuildContext context) {
    final totalSubjects = data.subjects.length;
    final averageScore =
        data.subjects
            .map((subject) => subject.totalScore)
            .fold<double>(0, (sum, score) => sum + score) /
        totalSubjects;
    final averageAttendance =
        data.subjects
            .map((subject) => subject.attendancePercent)
            .fold<int>(0, (sum, percent) => sum + percent) /
        totalSubjects;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileCard(profile: data.profile, onChangeAvatar: onChangeAvatar),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Môn học',
                value: '$totalSubjects',
                icon: Icons.menu_book_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Điểm TB',
                value: averageScore.toStringAsFixed(2),
                icon: Icons.star_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title: 'Điểm danh trung bình',
          value: '${averageAttendance.toStringAsFixed(0)}%',
          icon: Icons.how_to_reg_outlined,
        ),
        const SizedBox(height: 16),
        Text(
          'Lịch học hôm nay',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (data.todaySchedule.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Hôm nay không có lịch học.'),
            ),
          )
        else
          ...data.todaySchedule.map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(item.subjectName),
                subtitle: Text(
                  '${item.startTime} - ${item.endTime} • ${item.room}',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onChangeAvatar});

  final StudentProfile profile;
  final Future<void> Function(String avatarBase64) onChangeAvatar;

  Uint8List? _decodeAvatar() {
    final avatarBase64 = profile.avatarBase64;
    if (avatarBase64 == null || avatarBase64.isEmpty) {
      return null;
    }

    try {
      return base64Decode(avatarBase64);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickAndChangeAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedImage == null) {
      return;
    }

    try {
      final imageBytes = await pickedImage.readAsBytes();
      final avatarBase64 = base64Encode(imageBytes);
      await onChangeAvatar(avatarBase64);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật avatar.')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể cập nhật avatar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarBytes = _decodeAvatar();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: avatarBytes == null
                      ? null
                      : MemoryImage(avatarBytes),
                  child: avatarBytes == null
                      ? const Icon(Icons.person_outline)
                      : null,
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Material(
                    color: Theme.of(context).colorScheme.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _pickAndChangeAvatar(context),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text('MSSV: ${profile.studentId}'),
                  Text('Lớp: ${profile.className}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

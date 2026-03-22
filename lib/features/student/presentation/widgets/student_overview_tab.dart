import 'package:flutter/material.dart';

import '../../data/models/student_models.dart';

class StudentOverviewTab extends StatelessWidget {
  const StudentOverviewTab({super.key, required this.data});

  final StudentHomeData data;

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
        _ProfileCard(profile: data.profile),
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
  const _ProfileCard({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(radius: 24, child: Icon(Icons.person_outline)),
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

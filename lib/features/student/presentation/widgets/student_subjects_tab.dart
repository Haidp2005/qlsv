import 'package:flutter/material.dart';

import '../../data/models/student_models.dart';

class StudentSubjectsTab extends StatelessWidget {
  const StudentSubjectsTab({super.key, required this.subjects});

  final List<SubjectProgress> subjects;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final item = subjects[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subjectName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text('${item.subjectCode} • ${item.credit} tín chỉ'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ScoreInfo(
                        label: 'Giữa kỳ',
                        value: item.midterm.toStringAsFixed(1),
                      ),
                    ),
                    Expanded(
                      child: _ScoreInfo(
                        label: 'Cuối kỳ',
                        value: item.finalScore.toStringAsFixed(1),
                      ),
                    ),
                    Expanded(
                      child: _ScoreInfo(
                        label: 'Tổng kết',
                        value: item.totalScore.toStringAsFixed(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Điểm danh: ${item.attendancePercent}%'),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: item.attendancePercent / 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScoreInfo extends StatelessWidget {
  const _ScoreInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

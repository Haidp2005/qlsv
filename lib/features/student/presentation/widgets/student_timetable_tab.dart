import 'package:flutter/material.dart';

import '../../data/models/student_models.dart';

class StudentTimetableTab extends StatefulWidget {
  const StudentTimetableTab({super.key, required this.schedule});

  final List<TimetableItem> schedule;

  @override
  State<StudentTimetableTab> createState() => _StudentTimetableTabState();
}

class _StudentTimetableTabState extends State<StudentTimetableTab> {
  static const _days = <String>[
    'Tất cả',
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
  ];

  String _selectedDay = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final visibleItems = _selectedDay == 'Tất cả'
        ? widget.schedule
        : widget.schedule.where((item) => item.day == _selectedDay).toList();

    return Column(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _days
                .map(
                  (day) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(day),
                      selected: _selectedDay == day,
                      onSelected: (_) {
                        setState(() {
                          _selectedDay = day;
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: visibleItems.isEmpty
              ? const Center(child: Text('Không có lịch học cho ngày đã chọn.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                  itemCount: visibleItems.length,
                  itemBuilder: (context, index) {
                    final item = visibleItems[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const Icon(Icons.event_note_outlined),
                        title: Text(item.subjectName),
                        subtitle: Text(
                          '${item.day} • ${item.startTime} - ${item.endTime}\n${item.room} • ${item.lecturer}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

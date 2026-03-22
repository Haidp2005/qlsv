import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/export_utils.dart';

import '../../domain/models/lecturer_models.dart';
import '../controllers/lecturer_module_cubit.dart';

class LecturerClassDetailPage extends StatelessWidget {
  const LecturerClassDetailPage({
    required this.classId,
    super.key,
  });

  final String classId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lớp học phần')),
      body: BlocBuilder<LecturerModuleCubit, LecturerModuleState>(
        builder: (context, state) {
          LecturerClassroom? classroom;
          for (final c in state.classes) {
            if (c.id == classId) {
              classroom = c;
              break;
            }
          }

          if (classroom == null) {
            return const Center(
              child: Text('Không tìm thấy lớp học phần.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${classroom.courseCode} - ${classroom.courseName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('Học kỳ: ${classroom.semester}'),
                      Text('Phòng học: ${classroom.room}'),
                      Text('Lịch học: ${classroom.schedule}'),
                      Text('Sĩ số: ${classroom.totalStudents} sinh viên'),
                      Text(
                        'Điểm danh trung bình: ${classroom.averageAttendanceRate.toStringAsFixed(1)}%',
                      ),
                      Text(
                        'Đã nhập điểm: ${classroom.gradedStudentsCount}/${classroom.totalStudents}',
                      ),
                      Text(
                        'Điểm trung bình lớp: ${_scoreOrDash(classroom.averageOverallScore)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách sinh viên',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        tooltip: 'In Mới bảng điểm (PDF)',
                        onPressed: () {
                          ExportUtils.exportPdf(context, classroom!);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.table_chart, color: Colors.green),
                        tooltip: 'Xuất Tệp Lớp (Excel)',
                        onPressed: () {
                          ExportUtils.exportExcel(context, classroom!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...classroom.students.map(
                (student) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Text(student.fullName[0]),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text('MSSV: ${student.id}'),
                                ],
                              ),
                            ),
                            _ScoreChip(
                              label: 'TB',
                              value: _scoreOrDash(student.overallScore),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Điểm danh: ${student.attendedSessions}/${student.totalSessions} (${student.attendanceRate.toStringAsFixed(0)}%)',
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (student.attendanceRate / 100).clamp(0.0, 1.0),
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(99),
                          color: Colors.teal,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            _ScoreChip(
                              label: 'GK',
                              value: _scoreOrDash(student.midtermScore),
                            ),
                            _ScoreChip(
                              label: 'CK',
                              value: _scoreOrDash(student.finalScore),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _scoreOrDash(double? score) {
    if (score == null) {
      return '--';
    }
    return score.toStringAsFixed(1);
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

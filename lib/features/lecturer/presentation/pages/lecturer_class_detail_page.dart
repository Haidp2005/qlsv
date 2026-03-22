import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${classroom.courseCode} - ${classroom.courseName}',
                        style: Theme.of(context).textTheme.titleMedium,
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
              Text(
                'Danh sách sinh viên',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...classroom.students.map(
                (student) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(student.fullName[0])),
                    title: Text(student.fullName),
                    subtitle: Text(
                      'MSSV: ${student.id} • Điểm danh: ${student.attendedSessions}/${student.totalSessions} (${student.attendanceRate.toStringAsFixed(0)}%)',
                    ),
                    trailing: Text(
                      'GK: ${_scoreOrDash(student.midtermScore)}\nCK: ${_scoreOrDash(student.finalScore)}\nTB: ${_scoreOrDash(student.overallScore)}',
                      textAlign: TextAlign.right,
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

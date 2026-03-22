import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/lecturer_models.dart';
import '../controllers/lecturer_module_cubit.dart';
import 'lecturer_class_detail_page.dart';

class LecturerDashboardPage extends StatefulWidget {
  const LecturerDashboardPage({super.key});

  @override
  State<LecturerDashboardPage> createState() => _LecturerDashboardPageState();
}

class _LecturerDashboardPageState extends State<LecturerDashboardPage> {
  int _currentTabIndex = 0;

  static const List<Widget> _tabTitles = [
    Text('Giảng viên - Lớp học phần'),
    Text('Giảng viên - Điểm danh'),
    Text('Giảng viên - Nhập điểm'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LecturerModuleCubit(),
      child: BlocListener<LecturerModuleCubit, LecturerModuleState>(
        listenWhen: (previous, current) =>
            previous.feedbackMessage != current.feedbackMessage ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final message = state.feedbackMessage;
          if (message == null || message.isEmpty) {
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            context.read<LecturerModuleCubit>().clearFeedbackMessage();
          }

          final error = state.errorMessage;
          if (error == null || error.isEmpty) {
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          context.read<LecturerModuleCubit>().clearErrorMessage();
        },
        child: BlocBuilder<LecturerModuleCubit, LecturerModuleState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: _tabTitles[_currentTabIndex],
                actions: [
                  IconButton(
                    tooltip: 'Đồng bộ Firestore',
                    onPressed: state.isSyncing
                        ? null
                        : () {
                            context
                                .read<LecturerModuleCubit>()
                                .refreshFromFirestore();
                          },
                    icon: const Icon(Icons.sync),
                  ),
                ],
              ),
              body: Column(
                children: [
                  if (state.isSyncing) const LinearProgressIndicator(),
                  Expanded(
                    child: IndexedStack(
                      index: _currentTabIndex,
                      children: const [
                        _LecturerClassesTab(),
                        _LecturerAttendanceTab(),
                        _LecturerGradingTab(),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentTabIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    _currentTabIndex = value;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.class_outlined),
                    selectedIcon: Icon(Icons.class_),
                    label: 'Lớp học phần',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.fact_check_outlined),
                    selectedIcon: Icon(Icons.fact_check),
                    label: 'Điểm danh',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grading_outlined),
                    selectedIcon: Icon(Icons.grading),
                    label: 'Nhập điểm',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LecturerClassesTab extends StatelessWidget {
  const _LecturerClassesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LecturerModuleCubit, LecturerModuleState>(
      builder: (context, state) {
        if (state.classes.isEmpty) {
          return const Center(child: Text('Chưa có lớp học phần phụ trách.'));
        }

        final totalStudents = state.classes.fold<int>(
          0,
          (sum, classroom) => sum + classroom.totalStudents,
        );
        final todayKeyword = _weekdayLabel(DateTime.now().weekday);
        final classesToday = state.classes
            .where((classroom) => classroom.schedule.contains(todayKeyword))
            .length;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.classes.length + 1,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              final colorScheme = Theme.of(context).colorScheme;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng quan giảng dạy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Số lớp đang phụ trách: ${state.classes.length}',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    Text(
                      'Tổng sinh viên quản lý: $totalStudents',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    Text(
                      'Lớp học trong hôm nay: $classesToday',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                  ],
                ),
              );
            }

            final classroom = state.classes[index - 1];
            final attendanceProgress =
                (classroom.averageAttendanceRate / 100).clamp(0.0, 1.0);
            final gradingProgress = classroom.totalStudents == 0
                ? 0.0
                : (classroom.gradedStudentsCount / classroom.totalStudents)
                    .clamp(0.0, 1.0);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${classroom.courseCode} - ${classroom.courseName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text('Học kỳ: ${classroom.semester}'),
                    Text('Phòng: ${classroom.room}'),
                    Text('Lịch học: ${classroom.schedule}'),
                    Text('Sĩ số: ${classroom.totalStudents} sinh viên'),
                    Text(
                      'Điểm danh TB: ${classroom.averageAttendanceRate.toStringAsFixed(1)}%',
                    ),
                    Text(
                      'Đã nhập điểm: ${classroom.gradedStudentsCount}/${classroom.totalStudents}',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoBadge(
                          icon: Icons.calendar_month,
                          label: classroom.semester,
                        ),
                        _InfoBadge(
                          icon: Icons.meeting_room,
                          label: classroom.room,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _MetricProgress(
                      label: 'Tiến độ điểm danh',
                      valueText:
                          '${classroom.averageAttendanceRate.toStringAsFixed(1)}%',
                      progress: attendanceProgress,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 8),
                    _MetricProgress(
                      label: 'Tiến độ nhập điểm',
                      valueText:
                          '${classroom.gradedStudentsCount}/${classroom.totalStudents}',
                      progress: gradingProgress,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<LecturerModuleCubit>(),
                                child: LecturerClassDetailPage(
                                  classId: classroom.id,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Chi tiết lớp'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      default:
        return 'Chủ nhật';
    }
  }
}

class _LecturerAttendanceTab extends StatelessWidget {
  const _LecturerAttendanceTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LecturerModuleCubit, LecturerModuleState>(
      builder: (context, state) {
        final selectedClassId = state.selectedAttendanceClassId;
        final selectedClass = state.selectedAttendanceClass;
        final currentDraft = selectedClass == null
            ? const <String, bool>{}
            : (state.attendanceDraftByClass[selectedClass.id] ??
                const <String, bool>{});
        final selectedPresentCount =
            currentDraft.values.where((isPresent) => isPresent).length;

        if (state.classes.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu lớp học phần.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedClassId,
              decoration: const InputDecoration(
                labelText: 'Chọn lớp học phần để điểm danh',
                border: OutlineInputBorder(),
              ),
              items: state.classes
                  .map(
                    (classroom) => DropdownMenuItem<String>(
                      value: classroom.id,
                      child: Text(
                        '${classroom.courseCode} - ${classroom.courseName}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                context.read<LecturerModuleCubit>().selectAttendanceClass(value);
              },
            ),
            const SizedBox(height: 14),
            if (selectedClass == null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Vui lòng chọn lớp để điểm danh.'),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StatPill(
                            icon: Icons.groups,
                            label: 'Sĩ số: ${selectedClass.totalStudents}',
                          ),
                          _StatPill(
                            icon: Icons.done_all,
                            label: 'Đã chọn có mặt: $selectedPresentCount',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.done_all, size: 18),
                          label: const Text('Tất cả có mặt'),
                          onPressed: () {
                            context
                                .read<LecturerModuleCubit>()
                                .markAllAttendanceForSelectedClass(true);
                          },
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.remove_done, size: 18),
                          label: const Text('Tất cả vắng'),
                          onPressed: () {
                            context
                                .read<LecturerModuleCubit>()
                                .markAllAttendanceForSelectedClass(false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (selectedClass != null)
              ...selectedClass.students.map(
                (student) {
                  final isPresent = currentDraft[student.id] ?? false;

                  return Card(
                    child: CheckboxListTile(
                      value: isPresent,
                      title: Text(student.fullName),
                      subtitle: Text(
                        'MSSV: ${student.id} • Tích nếu có mặt',
                      ),
                      secondary: Text(
                        '${student.attendedSessions}/${student.totalSessions}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        context.read<LecturerModuleCubit>().toggleAttendance(
                              classId: selectedClass.id,
                              studentId: student.id,
                              isPresent: value,
                            );
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: selectedClass == null
                  ? null
                  : () {
                      context
                          .read<LecturerModuleCubit>()
                          .submitAttendanceSession();
                    },
              icon: const Icon(Icons.save),
              label: const Text('Lưu điểm danh buổi mới'),
            ),
          ],
        );
      },
    );
  }
}

class _LecturerGradingTab extends StatelessWidget {
  const _LecturerGradingTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LecturerModuleCubit, LecturerModuleState>(
      builder: (context, state) {
        final selectedClass = state.selectedGradingClass;
        final selectedClassId = state.selectedGradingClassId;

        if (state.classes.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu lớp học phần.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedClassId,
              decoration: const InputDecoration(
                labelText: 'Chọn lớp học phần để nhập điểm',
                border: OutlineInputBorder(),
              ),
              items: state.classes
                  .map(
                    (classroom) => DropdownMenuItem<String>(
                      value: classroom.id,
                      child: Text(
                        '${classroom.courseCode} - ${classroom.courseName}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                context.read<LecturerModuleCubit>().selectGradingClass(value);
              },
            ),
            const SizedBox(height: 14),
            if (selectedClass == null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Vui lòng chọn lớp để nhập điểm.'),
                ),
              )
            else
              ...selectedClass.students.map(
                (student) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: Text(student.fullName[0]),
                    ),
                    title: Text(student.fullName),
                    subtitle: Text(
                      'MSSV: ${student.id} • GK: ${_scoreOrDash(student.midtermScore)} • CK: ${_scoreOrDash(student.finalScore)} • TB: ${_scoreOrDash(student.overallScore)}',
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        _showGradeDialog(
                          context,
                          classId: selectedClass.id,
                          student: student,
                        );
                      },
                      child: const Text('Nhập điểm'),
                    ),
                  ),
                ),
              ),
            if (selectedClass != null)
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng kết lớp ${selectedClass.courseCode}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Đã nhập điểm: ${selectedClass.gradedStudentsCount}/${selectedClass.totalStudents}',
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: selectedClass.totalStudents == 0
                            ? 0
                            : selectedClass.gradedStudentsCount /
                                selectedClass.totalStudents,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Điểm trung bình lớp: ${_scoreOrDash(selectedClass.averageOverallScore)}',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showGradeDialog(
    BuildContext context, {
    required String classId,
    required StudentRecord student,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _GradeEditDialog(
          cubit: context.read<LecturerModuleCubit>(),
          classId: classId,
          student: student,
        );
      },
    );
  }

  String _scoreOrDash(double? score) {
    if (score == null) {
      return '--';
    }
    return score.toStringAsFixed(1);
  }
}

class _GradeEditDialog extends StatefulWidget {
  final LecturerModuleCubit cubit;
  final String classId;
  final StudentRecord student;

  const _GradeEditDialog({
    required this.cubit,
    required this.classId,
    required this.student,
  });

  @override
  State<_GradeEditDialog> createState() => _GradeEditDialogState();
}

class _GradeEditDialogState extends State<_GradeEditDialog> {
  late TextEditingController midtermController;
  late TextEditingController finalController;

  @override
  void initState() {
    super.initState();
    midtermController = TextEditingController(
      text: widget.student.midtermScore?.toStringAsFixed(1),
    );
    finalController = TextEditingController(
      text: widget.student.finalScore?.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    // Flutter sẽ tự động vứt controller an toàn khi Dialog thực sự biến mất
    midtermController.dispose();
    finalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nhập điểm - ${widget.student.fullName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: midtermController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Điểm giữa kỳ (0 - 10)',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: finalController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Điểm cuối kỳ (0 - 10)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final midterm = double.tryParse(midtermController.text.trim());
            final finalScore = double.tryParse(finalController.text.trim());

            if (midterm == null || finalScore == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Điểm phải là số hợp lệ.')),
              );
              return;
            }

            if (midterm < 0 || midterm > 10 || finalScore < 0 || finalScore > 10) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Điểm hợp lệ trong khoảng 0 đến 10.')),
              );
              return;
            }

            widget.cubit.updateStudentGrade(
              classId: widget.classId,
              studentId: widget.student.id,
              midtermScore: midterm,
              finalScore: finalScore,
            );

            Navigator.of(context).pop();
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetricProgress extends StatelessWidget {
  const _MetricProgress({
    required this.label,
    required this.valueText,
    required this.progress,
    required this.color,
  });

  final String label;
  final String valueText;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(valueText),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress,
          minHeight: 7,
          color: color,
          borderRadius: BorderRadius.circular(99),
        ),
      ],
    );
  }
}

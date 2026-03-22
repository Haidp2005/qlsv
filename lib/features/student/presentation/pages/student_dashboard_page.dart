import 'package:flutter/material.dart';

import '../../data/models/student_models.dart';
import '../../data/repositories/student_mock_repository.dart';
import '../widgets/student_overview_tab.dart';
import '../widgets/student_subjects_tab.dart';
import '../widgets/student_timetable_tab.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final StudentMockRepository _repository = StudentMockRepository();

  late final Future<StudentHomeData> _homeDataFuture = _repository
      .fetchStudentHomeData();
  int _currentIndex = 0;

  static const _tabTitles = <String>['Tổng quan', 'Thời khóa biểu', 'Môn học'];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentHomeData>(
      future: _homeDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sinh viên')),
            body: const Center(
              child: Text('Không tải được dữ liệu sinh viên.'),
            ),
          );
        }

        final data = snapshot.data!;
        final tabViews = [
          StudentOverviewTab(data: data),
          StudentTimetableTab(schedule: data.weekSchedule),
          StudentSubjectsTab(subjects: data.subjects),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text('Sinh viên - ${_tabTitles[_currentIndex]}'),
          ),
          body: tabViews[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Tổng quan',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Lịch học',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Môn học',
              ),
            ],
          ),
        );
      },
    );
  }
}

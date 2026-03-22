import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../data/models/student_models.dart';
import '../../data/repositories/firestore_student_repository.dart';
import '../widgets/student_overview_tab.dart';
import '../widgets/student_subjects_tab.dart';
import '../widgets/student_timetable_tab.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final FirestoreStudentRepository _repository = FirestoreStudentRepository();
  late Future<StudentHomeData> _homeDataFuture;
  int _currentIndex = 0;

  static const _tabTitles = <String>['Tổng quan', 'Thời khóa biểu', 'Môn học'];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    String studentId = 'SV001';
    String email = 'SV001';
    if (authState is AuthSuccess) {
      email = authState.user.email;
      studentId = email.split('@')[0].toUpperCase();
    }
    _homeDataFuture = _repository.fetchStudentHomeData(studentId, email);
  }

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
            appBar: AppBar(title: const Text('TH5 - Nhóm 13')),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.person_pin, size: 28),
                tooltip: 'Hồ sơ & Xuất File',
                onPressed: () => context.push(RouteConstants.profile),
              ),
            ],
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

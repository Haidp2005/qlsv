import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/route_constants.dart';
import '../../core/utils/export_excel_util.dart';
import '../../core/utils/export_pdf_util.dart';

class Position4Dashboard extends StatelessWidget {
  const Position4Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Position 4 - Export & Utility'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.profile),
              child: const Text('Mở Hồ Sơ Cá Nhân (Profile)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.notifications),
              child: const Text('Mở Thông Báo (Notifications)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final mockStudents = [
                  <String, dynamic>{'student_id': 'SV01', 'name': 'Nguyễn Văn A', 'email': 'a@example.com', 'dob': '01/01/2000', 'gender': 'Nam', 'status': 'Đang học'},
                ];
                ExportExcelUtil.exportStudentList('Lớp Test', mockStudents);
              },
              child: const Text('Test Xuất File Excel'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final mockGrades = [
                  <String, dynamic>{'student_id': 'SV01', 'name': 'Nguyễn Văn A', 'attendance': 10.0, 'midterm': 8.5, 'final': 9.0},
                ];
                ExportPdfUtil.exportGradeSheetPDF('Lớp Test', mockGrades);
              },
              child: const Text('Test Xuất File PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

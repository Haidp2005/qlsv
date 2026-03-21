import 'package:flutter/material.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sinh viên - Trang chủ')),
      body: const Center(
        child: Text('DEV 2: Code UI Sinh viên ở đây...'),
      ),
    );
  }
}

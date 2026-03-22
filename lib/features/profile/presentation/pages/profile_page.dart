import 'package:flutter/material.dart';
import '../../../../core/utils/export_utils.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ & Tiện ích (Dev 4)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 60),
            ),
            const SizedBox(height: 16),
            const Text('Người Dùng Mẫu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('dev4@example.com'),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Test Xuất Bảng Điểm PDF'),
              onPressed: () async {
                await ExportUtils.exportPdfDummy(context);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.table_chart),
              label: const Text('Test Xuất Danh Sách Excel'),
              onPressed: () async {
                await ExportUtils.exportExcelDummy(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:excel/excel.dart';
import '../../features/lecturer/domain/models/lecturer_models.dart';

class ExportUtils {
  static Future<void> exportExcel(BuildContext context, LecturerClassroom classroom) async {
    try {
      var excelFile = Excel.createExcel();
      Sheet sheetObject = excelFile['Sheet1'];

      sheetObject.appendRow([
        TextCellValue('STT'),
        TextCellValue('MSSV'),
        TextCellValue('Ho ten'),
        TextCellValue('Diem Danh (%)'),
        TextCellValue('Diem GK'),
        TextCellValue('Diem CK'),
        TextCellValue('Diem Tong')
      ]);
      
      for (var i = 0; i < classroom.students.length; i++) {
        final s = classroom.students[i];
        sheetObject.appendRow([
          TextCellValue('${i + 1}'),
          TextCellValue(s.id),
          TextCellValue(s.fullName),
          TextCellValue(s.attendanceRate.toStringAsFixed(0)),
          TextCellValue(s.midtermScore?.toStringAsFixed(1) ?? '-'),
          TextCellValue(s.finalScore?.toStringAsFixed(1) ?? '-'),
          TextCellValue(s.overallScore?.toStringAsFixed(1) ?? '-'),
        ]);
      }

      var fileBytes = excelFile.save();
      if (fileBytes == null) throw Exception('Không thể tạo dữ liệu Excel');

      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/DanhSachLop_${classroom.courseCode}.xlsx');
      await file.writeAsBytes(fileBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xuất Excel thành công!\n${file.path}'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
      await OpenFilex.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xuất Excel: $e')));
      }
    }
  }
}

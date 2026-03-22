import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ExportExcelUtil {
  /// Xuất danh sách sinh viên ra file Excel
  static Future<void> exportStudentList(String className, List<Map<String, dynamic>> students) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['DanhSachSinhVien'];
      excel.setDefaultSheet('DanhSachSinhVien');

      // Tạo Header
      List<String> headers = ['STT', 'MSSV', 'Họ và tên', 'Ngày sinh', 'Lớp danh nghĩa'];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      // Thêm dữ liệu sinh viên
      for (int i = 0; i < students.length; i++) {
        var student = students[i];
        List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(student['student_id'] ?? ''),
          TextCellValue(student['full_name'] ?? ''),
          TextCellValue(student['dob'] ?? ''),
          TextCellValue(student['class_name'] ?? ''),
        ];
        sheetObject.appendRow(row);
      }

      // Lưu file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/DanhSach_$className.xlsx';
      final file = File(filePath);
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        debugPrint('Đã xuất file Excel thành công tại: $filePath');
        
        // Mở file sau khi xuất
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      debugPrint('Lỗi xuất file Excel: $e');
      rethrow;
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import '../../features/lecturer/domain/models/lecturer_models.dart';

class ExportUtils {
  static Future<void> exportPdf(BuildContext context, LecturerClassroom classroom) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('BANG DIEM KET THUC HOC PHAN', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Lop hoc phan: ${classroom.courseCode} - ${classroom.courseName}'),
                pw.Text('Hoc ky: ${classroom.semester} | Phong: ${classroom.room}'),
                pw.Text('Siso: ${classroom.totalStudents}'),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['STT', 'MSSV', 'Ho ten', 'Diem Danh (%)', 'Diem GK', 'Diem CK', 'Diem TB'],
                  data: List<List<String>>.generate(
                    classroom.students.length,
                    (index) {
                      final s = classroom.students[index];
                      return [
                        '${index + 1}',
                        s.id,
                        s.fullName,
                        s.attendanceRate.toStringAsFixed(0),
                        s.midtermScore?.toStringAsFixed(1) ?? '-',
                        s.finalScore?.toStringAsFixed(1) ?? '-',
                        s.overallScore?.toStringAsFixed(1) ?? '-',
                      ];
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Bang_Diem_${classroom.courseCode}.pdf',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giao diện in/lưu PDF đã được mở!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xuất PDF: $e')));
      }
    }
  }

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

      final directory = await getTemporaryDirectory();
      final File file = File('${directory.path}/DanhSachLop_${classroom.courseCode}.xlsx');
      await file.writeAsBytes(fileBytes);

      // Mở Share Sheet — người dùng chọn lưu vào Downloads, Drive, email...
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          subject: 'Danh sách lớp ${classroom.courseCode}',
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hãy chọn nơi lưu trên hộp thoại chia sẻ!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xuất Excel: $e')));
      }
    }
  }
}

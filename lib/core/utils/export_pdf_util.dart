import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportPdfUtil {
  /// Xuất bảng điểm của lớp ra file PDF
  static Future<void> exportGradeSheetPDF(String className, List<Map<String, dynamic>> grades) async {
    try {
      final pdf = pw.Document();

      // Cần có font hỗ trợ tiếng Việt nếu nội dung có tiếng Việt (VD: Roboto)
      // Giả sử dùng font mặc định tạm thời hoặc tải font (Printing hỗ trợ load font)
      final font = await PdfGoogleFonts.robotoRegular();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('BẢNG ĐIỂM LỚP HỌC PHẦN: $className', 
                    style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  context: context,
                  cellAlignment: pw.Alignment.center,
                  headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                  cellStyle: pw.TextStyle(font: font),
                  headers: ['STT', 'MSSV', 'Họ tên', 'Điểm QT', 'Điểm thi', 'Điểm TK'],
                  data: List<List<String>>.generate(
                    grades.length,
                    (index) => [
                      (index + 1).toString(),
                      grades[index]['student_id'] ?? '',
                      grades[index]['full_name'] ?? '',
                      grades[index]['grade_mid']?.toString() ?? '',
                      grades[index]['grade_final']?.toString() ?? '',
                      grades[index]['grade_total']?.toString() ?? '',
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Lưu file PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/BangDiem_$className.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      debugPrint('Đã xuất file PDF thành công tại: $filePath');
      
      // Mở file (hoặc preview tùy ứng dụng)
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      debugPrint('Lỗi xuất file PDF: $e');
      rethrow;
    }
  }
}

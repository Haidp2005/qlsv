import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';

class ExportUtils {
  static Future<void> exportPdfDummy(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Text('BANG DIEM SINH VIEN', style: const pw.TextStyle(fontSize: 24)),
          ),
        ),
      );

      // Mở preview PDF gốc (Printing API)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giao diện in PDF đã được mở!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xuất PDF: $e')));
    }
  }

  static Future<void> exportExcelDummy(BuildContext context) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Row Header
      sheetObject.appendRow([
        TextCellValue('MSSV'),
        TextCellValue('Ho ten'),
        TextCellValue('Diem QT'),
        TextCellValue('Diem Thi')
      ]);
      
      // Rows Data
      sheetObject.appendRow([TextCellValue('SV001'), TextCellValue('Nguyen Van A'), IntCellValue(8), IntCellValue(9)]);
      sheetObject.appendRow([TextCellValue('SV002'), TextCellValue('Tran Thi B'), IntCellValue(7), IntCellValue(8)]);

      var fileBytes = excel.save();
      final directory = await getApplicationDocumentsDirectory();
      
      final File file = File('${directory.path}/DanhSachLop.xlsx');
      await file.writeAsBytes(fileBytes!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xuất Excel thành công!\nĐã lưu tại Thư mục Documents của máy hệ điều hành.\nĐường dẫn: ${file.path}'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xuất Excel: $e')));
    }
  }
}

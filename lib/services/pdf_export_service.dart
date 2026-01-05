import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/expense_model.dart';
import '../utils/currency_utils.dart';

class PdfExportService {
  static Future<void> exportExpenses(List<Expense> expenses) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          _buildHeader(date),
          pw.SizedBox(height: 24),
          _buildExpenseTable(expenses),
          pw.SizedBox(height: 24),
          _buildSummary(expenses),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Expense_Report_${date.replaceAll('/', '_')}.pdf',
    );
  }

  static Future<void> downloadExpenses(List<Expense> expenses) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          _buildHeader(date),
          pw.SizedBox(height: 24),
          _buildExpenseTable(expenses),
          pw.SizedBox(height: 24),
          _buildSummary(expenses),
        ],
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'Spendly_Report_${date.replaceAll('/', '_')}.pdf';

    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  static pw.Widget _buildHeader(String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Spendly Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text('Date: $date', style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 2, color: PdfColors.blueGrey100),
      ],
    );
  }

  static pw.Widget _buildExpenseTable(List<Expense> expenses) {
    final headers = ['Date', 'Title', 'Category', 'Amount'];
    final data = expenses.map((e) {
      return [
        DateFormat('dd MMM yyyy').format(e.date),
        e.title,
        e.category,
        CurrencyUtils.format(e.amount),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
    );
  }

  static pw.Widget _buildSummary(List<Expense> expenses) {
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Divider(thickness: 1, color: PdfColors.black),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'Total Expenses: ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              pw.Text(
                CurrencyUtils.format(total),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                  color: PdfColors.red900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

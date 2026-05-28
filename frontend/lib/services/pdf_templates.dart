import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../constants/app_theme.dart';

// Font data cache - loaded once
late final pw.Font _interFont;
late final pw.Font _interBoldFont;
late final pw.Font _manropeBoldFont;
late final Uint8List _logoBytes;
bool pdfFontsLoaded = false;
bool _logoLoaded = false;

Future<void> loadPdfAssets() async {
  if (!pdfFontsLoaded) {
    final inter = await rootBundle.load('assets/fonts/Inter.ttf');
    final manropeBold = await rootBundle.load('assets/fonts/Manrope-Bold.ttf');
    _interFont = pw.Font.ttf(inter);
    _interBoldFont = pw.Font.ttf(inter);
    _manropeBoldFont = pw.Font.ttf(manropeBold);
    pdfFontsLoaded = true;
  }
  if (!_logoLoaded) {
    final logo = await rootBundle.load('assets/images/rayhan_icon.png');
    _logoBytes = logo.buffer.asUint8List();
    _logoLoaded = true;
  }
}

pw.Font pdfFont({bool bold = false}) => bold ? _interBoldFont : _interFont;
pw.Font pdfHeadingFont() => _manropeBoldFont;

class PdfBrandedHeader {
  static pw.Widget build({
    required String title,
    required String reference,
    String? subtitle,
  }) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 50,
              height: 50,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(AppTheme.kPrimaryTeal.value),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: _logoLoaded
                  ? pw.Image(pw.MemoryImage(_logoBytes), width: 50, height: 50, fit: pw.BoxFit.cover)
                  : pw.Center(
                      child: pw.Text('R',
                          style: pw.TextStyle(
                            fontSize: 24,
                            font: pdfHeadingFont(),
                            color: PdfColors.white,
                          )),
                    ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Rayhan ERP',
                      style: pw.TextStyle(
                        fontSize: 18,
                        font: pdfHeadingFont(),
                        color: PdfColor.fromInt(AppTheme.kPrimaryNavy.value),
                      )),
                  pw.Text('SUARL Rayhan - Plasturgie',
                      style: pw.TextStyle(fontSize: 9, font: pdfFont(), color: PdfColors.grey)),
                  pw.Text('ICE: 123456789 / MF: 0000000',
                      style: pw.TextStyle(fontSize: 8, font: pdfFont(), color: PdfColors.grey)),
                  pw.Text('Adresse: Z.I. Charguia - Tunis',
                      style: pw.TextStyle(fontSize: 8, font: pdfFont(), color: PdfColors.grey)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          height: 1,
          color: PdfColor.fromInt(AppTheme.kBorderLight.value),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(title,
                      style: pw.TextStyle(
                          fontSize: 16,
                          font: pdfHeadingFont(),
                          fontWeight: pw.FontWeight.bold)),
                  if (subtitle != null)
                    pw.Text(subtitle,
                        style: pw.TextStyle(fontSize: 10, font: pdfFont(), color: PdfColors.grey)),
                ],
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(AppTheme.kPrimaryTeal.value),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(reference,
                  style: pw.TextStyle(
                      fontSize: 11,
                      font: pdfFont(bold: true),
                      color: PdfColors.white)),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }
}

class PdfLineItemTable {
  static pw.Widget build({
    required List<PdfLineItem> items,
    required List<String> columns,
    required List<double> columnWidths,
  }) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(
            color: PdfColor.fromInt(AppTheme.kBorderLight.value), width: 0.5),
        bottom: pw.BorderSide(
            color: PdfColor.fromInt(AppTheme.kBorderLight.value), width: 0.5),
      ),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(
                AppTheme.kPrimaryTeal.withValues(alpha: 0.08).value),
          ),
          children: columns
              .map((h) => pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            fontSize: 9,
                            font: pdfFont(bold: true),
                            color: PdfColor.fromInt(
                                AppTheme.kTextPrimary.value))),
                  ))
              .toList(),
        ),
        ...items.asMap().entries.map((entry) {
          return pw.TableRow(
            children: entry.value.cells
                .asMap()
                .map((i, cell) => MapEntry(
                    i,
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      child: pw.Text(cell,
                          style: pw.TextStyle(fontSize: 9, font: pdfFont()),
                          textAlign: i == 0
                              ? pw.TextAlign.left
                              : pw.TextAlign.right),
                    )))
                .values
                .toList(),
          );
        }),
      ],
    );
  }
}

class PdfLineItem {
  final List<String> cells;
  PdfLineItem(this.cells);
}

class PdfTotalsBox {
  static pw.Widget build({
    required double totalHT,
    required double totalTVA,
    required double totalTTC,
    double tauxTVA = 19,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(height: 8),
        pw.Container(
          width: 220,
          padding: pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
                color: PdfColor.fromInt(AppTheme.kBorderLight.value)),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _row('Total HT', totalHT),
              pw.SizedBox(height: 3),
              _row('TVA ($tauxTVA%)', totalTVA),
              pw.Divider(height: 1,
                  color: PdfColor.fromInt(AppTheme.kBorderLight.value)),
              pw.SizedBox(height: 3),
              _row('Total TTC', totalTTC,
                  bold: true,
                  color: PdfColor.fromInt(AppTheme.kCtaOrange.value)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _row(String label, double amount,
      {bool bold = false, PdfColor? color}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 10,
                font: pdfFont(bold: bold),
                color: color)),
        pw.Text(amount.toStringAsFixed(3),
            style: pw.TextStyle(
                fontSize: 10,
                font: pdfFont(bold: bold),
                color: color)),
      ],
    );
  }
}

class PdfFooter {
  static pw.Widget build() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: PdfColor.fromInt(AppTheme.kBorderLight.value)),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Généré par Rayhan ERP',
                style: pw.TextStyle(fontSize: 7, font: pdfFont(), color: PdfColors.grey)),
            pw.Text('Page {page_num} / {page_count}',
                style: pw.TextStyle(fontSize: 7, font: pdfFont(), color: PdfColors.grey)),
          ],
        ),
      ],
    );
  }
}

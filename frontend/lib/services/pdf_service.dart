import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/purchase_order.dart';
import '../models/sales_order.dart';
import '../models/production_order.dart';
import '../models/article.dart';
import '../models/stock_movement.dart';
import 'pdf_templates.dart';
import '../constants/app_theme.dart';

class PdfService {
  PdfService._();

  static Uint8List? _logoBytes;

  static Future<void> init() async {
    final data = await rootBundle.load('assets/images/rayhan_icon.png');
    _logoBytes = data.buffer.asUint8List();
  }

  static Future<Uint8List> generatePurchaseReceipt(PurchaseOrder order) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (ctx) => PdfFooter.build(pageNumber: ctx.pageNumber),
        build: (ctx) => [
          PdfBrandedHeader.build(
            title: 'Bon de Réception',
            reference: 'BR-${order.reference ?? "N/A"}',
            subtitle: 'Date: ${order.dateCommande}',
            logoBytes: _logoBytes,
          ),
          pw.SizedBox(height: 16),
          _infoBlock('Fournisseur', [
            order.fournisseur?.raisonSociale ?? '—',
            order.fournisseur?.adresse ?? '',
            order.fournisseur?.matriculeFiscal ?? '',
          ]),
          pw.SizedBox(height: 16),
          PdfLineItemTable.build(
            columns: ['Réf', 'Désignation', 'Qté', 'PU HT', 'Total HT'],
            columnWidths: [0.15, 0.35, 0.15, 0.15, 0.2],
            items: order.lignes
                .map((l) => PdfLineItem([
                      l.article?.reference ?? '',
                      l.article?.designation ?? '',
                      l.quantiteCommandee.toString(),
                      'TND ${l.prixUnitaireHT.toStringAsFixed(3)}',
                      'TND ${(l.quantiteCommandee * l.prixUnitaireHT).toStringAsFixed(3)}',
                    ]))
                .toList(),
          ),
          pw.SizedBox(height: 8),
          PdfTotalsBox.build(
            totalHT: order.totalHT,
            totalTVA: order.totalTVA,
            totalTTC: order.totalTTC,
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Future<Uint8List> generateSalesInvoice(SalesOrder order) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (ctx) => PdfFooter.build(pageNumber: ctx.pageNumber),
        build: (ctx) => [
          PdfBrandedHeader.build(
            title: 'Facture',
            reference: 'FAC-${order.reference ?? "N/A"}',
            subtitle: 'Date: ${order.dateCommande}',
            logoBytes: _logoBytes,
          ),
          pw.SizedBox(height: 16),
          _infoBlock('Client', [
            order.client?.raisonSociale ?? '—',
            order.client?.adresse ?? '',
            order.client?.matriculeFiscal ?? '',
          ]),
          pw.SizedBox(height: 16),
          PdfLineItemTable.build(
            columns: ['Réf', 'Désignation', 'Qté', 'PU HT', 'Total HT'],
            columnWidths: [0.15, 0.35, 0.15, 0.15, 0.2],
            items: order.lignes
                .map((l) => PdfLineItem([
                      l.article?.reference ?? '',
                      l.article?.designation ?? '',
                      l.quantiteCommandee.toString(),
                      'TND ${l.prixUnitaireHT.toStringAsFixed(3)}',
                      'TND ${(l.quantiteCommandee * l.prixUnitaireHT).toStringAsFixed(3)}',
                    ]))
                .toList(),
          ),
          pw.SizedBox(height: 8),
          PdfTotalsBox.build(
            totalHT: order.totalHT,
            totalTVA: order.totalTVA,
            totalTTC: order.totalTTC,
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Future<Uint8List> generateStockReport(
      Article article, List<StockMovement> movements) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (ctx) => PdfFooter.build(pageNumber: ctx.pageNumber),
        build: (ctx) => [
          PdfBrandedHeader.build(
            title: 'Fiche de Stock',
            reference: article.reference,
            subtitle: article.designation,
            logoBytes: _logoBytes,
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _statBox('Stock actuel',
                  '${article.stockActuel} ${article.uniteMesure ?? ''}'),
              pw.SizedBox(width: 12),
              _statBox('Stock min',
                  '${article.stockMinimum} ${article.uniteMesure ?? ''}'),
              pw.SizedBox(width: 12),
              _statBox('Type', article.typeLabel),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Historique des mouvements',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          PdfLineItemTable.build(
            columns: ['Date', 'Type', 'Qté', 'Motif'],
            columnWidths: [0.25, 0.15, 0.15, 0.45],
            items: movements
                .map((m) => PdfLineItem([
                      m.dateFormatted,
                      m.isEntree ? 'Entrée' : 'Sortie',
                      '${m.quantite}',
                      m.motif ?? '—',
                    ]))
                .toList(),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Future<Uint8List> generateProductionReport(
      ProductionOrder order, List<BomLine> bomLines) async {
    final pct = order.quantitePlanifiee > 0
        ? (order.quantiteRealisee / order.quantitePlanifiee * 100).toInt()
        : 0;
    final dateFmt = DateFormat('dd/MM/yyyy');
    final dateTimeFmt = DateFormat('dd/MM/yyyy HH:mm');

    String? tryFormat(String? raw, DateFormat fmt) {
      if (raw == null) return null;
      try {
        return fmt.format(DateTime.parse(raw));
      } catch (_) {
        return raw;
      }
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (ctx) => PdfFooter.build(pageNumber: ctx.pageNumber),
        build: (ctx) => [
          PdfBrandedHeader.build(
            title: 'Ordre de Fabrication',
            reference: order.reference ?? 'N/A',
            subtitle: 'Statut: ${order.statutLabel}',
            logoBytes: _logoBytes,
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _statBox('Planifié', '${order.quantitePlanifiee}'),
              pw.SizedBox(width: 12),
              _statBox('Réalisé', '${order.quantiteRealisee}'),
              pw.SizedBox(width: 12),
              _statBox('Avancement', '$pct%'),
            ],
          ),
          pw.SizedBox(height: 16),
          _infoBlock('Produit', [
            'Désignation: ${order.produitFini?.designation ?? '—'}',
            'Référence: ${order.produitFini?.reference ?? '—'}',
          ]),
          pw.SizedBox(height: 16),
          if (bomLines.isNotEmpty) ...[
            pw.Text('Composition (Nomenclature)',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            PdfLineItemTable.build(
              columns: ['Réf', 'Désignation', 'Qté/U', 'Qté totale', 'Unité'],
              columnWidths: [0.15, 0.35, 0.15, 0.15, 0.2],
              items: bomLines
                  .map((l) => PdfLineItem([
                        l.composant?.reference ?? '',
                        l.composant?.designation ?? '',
                        l.quantiteParUnite.toStringAsFixed(3),
                        (l.quantiteParUnite * order.quantitePlanifiee)
                            .toStringAsFixed(3),
                        l.composant?.uniteMesure ?? '',
                      ]))
                  .toList(),
            ),
            pw.SizedBox(height: 16),
          ],
          _infoBlock('Informations', [
            'Date planifiée: ${tryFormat(order.datePlanifiee, dateFmt) ?? order.datePlanifiee}',
            if (order.dateLancement != null)
              'Date lancement: ${tryFormat(order.dateLancement, dateTimeFmt) ?? order.dateLancement}',
            if (order.dateTerminaison != null)
              'Date fin: ${tryFormat(order.dateTerminaison, dateTimeFmt) ?? order.dateTerminaison}',
            if (order.notes != null) 'Notes: ${order.notes}',
          ]),
        ],
      ),
    );
    return doc.save();
  }

  static Future<Uint8List> generateArticleCatalog(
      List<Article> articles, String type) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (ctx) => PdfFooter.build(pageNumber: ctx.pageNumber),
        build: (ctx) => [
          PdfBrandedHeader.build(
            title: 'Catalogue Articles',
            reference: type == 'TOUS' ? 'TOUS' : type,
            logoBytes: _logoBytes,
          ),
          pw.SizedBox(height: 16),
          PdfLineItemTable.build(
            columns: ['Réf', 'Désignation', 'Type', 'Stock', 'PU'],
            columnWidths: [0.18, 0.35, 0.12, 0.12, 0.23],
            items: articles
                .map((a) => PdfLineItem([
                      a.reference,
                      a.designation,
                      a.type,
                      '${a.stockActuel} ${a.uniteMesure ?? ''}',
                      'TND ${a.prixUnitaire.toStringAsFixed(3)}',
                    ]))
                .toList(),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Future<Uint8List> generateDevis(SalesOrder order) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (ctx) => PdfFooter.build(pageNumber: ctx.pageNumber),
        build: (ctx) => [
          PdfBrandedHeader.build(
            title: 'Devis',
            reference: 'DEV-001',
            subtitle: 'Date: ${order.dateCommande}',
            logoBytes: _logoBytes,
          ),
          pw.SizedBox(height: 16),
          if (order.client != null)
            _infoBlock('Client', [
              order.client!.raisonSociale,
              order.client!.adresse ?? '',
              order.client!.matriculeFiscal ?? '',
            ]),
          pw.SizedBox(height: 16),
          PdfLineItemTable.build(
            columns: ['Réf', 'Désignation', 'Qté', 'PU HT', 'Total HT'],
            columnWidths: [0.15, 0.35, 0.15, 0.15, 0.2],
            items: order.lignes
                .map((l) => PdfLineItem([
                      l.article?.reference ?? '',
                      l.article?.designation ?? '',
                      l.quantiteCommandee.toString(),
                      'TND ${l.prixUnitaireHT.toStringAsFixed(3)}',
                      'TND ${(l.quantiteCommandee * l.prixUnitaireHT).toStringAsFixed(3)}',
                    ]))
                .toList(),
          ),
          pw.SizedBox(height: 8),
          PdfTotalsBox.build(
            totalHT: order.totalHT,
            totalTVA: order.totalTVA,
            totalTTC: order.totalTTC,
          ),
        ],
      ),
    );
    return doc.save();
  }

  static void downloadPdf(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static pw.Widget _infoBlock(String title, List<String> lines) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border:
            pw.Border.all(color: PdfColor.fromInt(AppTheme.kBorderLight.value)),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(AppTheme.kTextPrimary.value))),
          pw.SizedBox(height: 4),
          ...lines.where((l) => l.isNotEmpty).map((l) => pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 2),
                child: pw.Text(l.replaceAll('null', '—'),
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
              )),
        ],
      ),
    );
  }

  static pw.Widget _statBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(
              AppTheme.kDeepIndustrialBlue.withValues(alpha: 0.06).value),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white)),
            pw.Text(label,
                style: pw.TextStyle(fontSize: 8, color: PdfColors.white)),
          ],
        ),
      ),
    );
  }
}

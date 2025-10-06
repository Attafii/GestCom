import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/bon_livraison_model.dart';
import '../../data/models/article_livraison_model.dart';

/// Service for generating PDF Bon de Livraison (Delivery Notes)
class PdfBLService {
  static const String companyName = 'GestCom';
  static const String companyAddress = '123 Rue de Commerce\n1000 Tunis, Tunisie';
  static const String companyPhone = 'Tél: +216 71 123 456';
  static const String companyEmail = 'contact@gestcom.tn';

  /// Generate PDF Bon de Livraison
  Future<File> generateBLPdf(BonLivraison bonLivraison) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(bonLivraison),
          pw.SizedBox(height: 20),
          _buildClientInfo(bonLivraison),
          pw.SizedBox(height: 20),
          _buildBLDetails(bonLivraison),
          pw.SizedBox(height: 20),
          _buildArticlesTable(bonLivraison.articles),
          pw.SizedBox(height: 20),
          _buildSummary(bonLivraison),
          if (bonLivraison.commentaire != null && bonLivraison.commentaire!.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            _buildComments(bonLivraison.commentaire!),
          ],
          pw.SizedBox(height: 30),
          _buildSignatureSection(),
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );

    return await _savePdf(pdf, bonLivraison.blNumber);
  }

  /// Build header with company info and BL title
  pw.Widget _buildHeader(BonLivraison bonLivraison) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Company info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              companyName,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              companyAddress,
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              companyPhone,
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              companyEmail,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        // BL title and number
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue900,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Text(
                'BON DE LIVRAISON',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'N° ${bonLivraison.blNumber}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Date: ${_formatDate(bonLivraison.dateLivraison)}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  /// Build client information section
  pw.Widget _buildClientInfo(BonLivraison bonLivraison) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CLIENT',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 5),
          pw.Text(
            bonLivraison.clientName,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (bonLivraison.notes != null && bonLivraison.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              'Notes: ${bonLivraison.notes}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  /// Build BL details (status, etc.)
  pw.Widget _buildBLDetails(BonLivraison bonLivraison) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Statut: ${bonLivraison.statusLabel}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Total articles: ${bonLivraison.totalArticles}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Total pièces: ${bonLivraison.totalPieces}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Créé le: ${_formatDate(bonLivraison.createdAt)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build articles table with treatment info
  pw.Widget _buildArticlesTable(List<ArticleLivraison> articles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ARTICLES LIVRÉS',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FixedColumnWidth(30),  // #
            1: const pw.FlexColumnWidth(2),    // Référence
            2: const pw.FlexColumnWidth(3),    // Désignation
            3: const pw.FlexColumnWidth(2),    // Traitement
            4: const pw.FixedColumnWidth(60),  // Quantité (pcs)
            5: const pw.FlexColumnWidth(2),    // Commentaire
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildTableCell('#', isHeader: true),
                _buildTableCell('Référence', isHeader: true),
                _buildTableCell('Désignation', isHeader: true),
                _buildTableCell('Traitement', isHeader: true),
                _buildTableCell('Qté (pcs)', isHeader: true),
                _buildTableCell('Commentaire', isHeader: true),
              ],
            ),
            // Data rows
            ...articles.asMap().entries.map((entry) {
              final index = entry.key;
              final article = entry.value;
              return pw.TableRow(
                children: [
                  _buildTableCell('${index + 1}'),
                  _buildTableCell(article.articleReference),
                  _buildTableCell(article.articleDesignation),
                  _buildTableCell(article.treatmentName),
                  _buildTableCell('${article.quantityLivree}', isCenter: true),
                  _buildTableCell(article.commentaire ?? '-'),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  /// Build table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false, bool isCenter = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isCenter 
            ? pw.TextAlign.center 
            : (isHeader ? pw.TextAlign.center : pw.TextAlign.left),
      ),
    );
  }

  /// Build summary section
  pw.Widget _buildSummary(BonLivraison bonLivraison) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TOTAL',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.Row(
            children: [
              pw.Text(
                '${bonLivraison.totalArticles} article(s) • ',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${bonLivraison.totalPieces} pièce(s)',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build comments section
  pw.Widget _buildComments(String commentaire) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow50,
        border: pw.Border.all(color: PdfColors.yellow300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'COMMENTAIRES',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            commentaire,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  /// Build signature section
  pw.Widget _buildSignatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSignatureBox('Signature du livreur', 'Date:'),
        _buildSignatureBox('Signature du destinataire', 'Date:'),
      ],
    );
  }

  /// Build individual signature box
  pw.Widget _buildSignatureBox(String title, String dateLabel) {
    return pw.Container(
      width: 200,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 40), // Space for signature
          pw.Divider(color: PdfColors.grey400),
          pw.Text(
            dateLabel,
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 15),
        ],
      ),
    );
  }

  /// Build footer
  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 5),
        pw.Text(
          'Document non valable pour facturation',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red700,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Bon de livraison généré par $companyName - $companyEmail',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// Format date to dd/MM/yyyy
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Save PDF to file
  Future<File> _savePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    return await _saveFile(bytes, 'BL_$fileName.pdf');
  }

  /// Save file to documents directory
  Future<File> _saveFile(Uint8List bytes, String fileName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final blDir = Directory('${appDocumentDir.path}/GestCom/bons_livraison');
    
    if (!await blDir.exists()) {
      await blDir.create(recursive: true);
    }

    final file = File('${blDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Open PDF file
  Future<void> openPdf(String blNumber) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocumentDir.path}/GestCom/bons_livraison/BL_$blNumber.pdf');
    
    if (await file.exists()) {
      // On Windows, use the default PDF viewer
      await Process.run('start', ['', file.path], runInShell: true);
    } else {
      throw Exception('Fichier PDF non trouvé');
    }
  }

  /// Get BL file path
  Future<String> getBLFilePath(String blNumber) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return '${appDocumentDir.path}/GestCom/bons_livraison/BL_$blNumber.pdf';
  }

  /// Check if BL PDF exists
  Future<bool> blPdfExists(String blNumber) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocumentDir.path}/GestCom/bons_livraison/BL_$blNumber.pdf');
    return await file.exists();
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../../data/models/facturation_model.dart';
import '../../data/models/client_model.dart';
import '../../data/repositories/facturation_repository.dart';

class PdfInvoiceService {
  static const String companyName = 'GestCom';
  static const String companyAddress = '123 Rue de Commerce\n1000 Tunis, Tunisie';
  static const String companyPhone = 'Tél: +216 71 123 456';
  static const String companyEmail = 'contact@gestcom.tn';

  // Generate PDF invoice
  Future<File> generateInvoicePdf(Facturation facturation) async {
    final pdf = pw.Document();
    
    // Get client information
    final clientBox = Hive.box<Client>('clients');
    final clientFacture = clientBox.get(facturation.clientFactureId);
    final clientSource = facturation.isThirdPartyBilling 
        ? clientBox.get(facturation.clientSourceId) 
        : null;

    // Get line items
    final repository = FacturationRepository();
    final lineItems = repository.getInvoiceLineItems(facturation.blReferences);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(facturation),
          pw.SizedBox(height: 20),
          _buildClientInfo(clientFacture, clientSource),
          pw.SizedBox(height: 20),
          _buildInvoiceDetails(facturation),
          pw.SizedBox(height: 20),
          _buildLineItems(lineItems),
          pw.SizedBox(height: 20),
          _buildTotals(facturation),
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );

    return await _savePdf(pdf, facturation.factureNumber);
  }

  // Build header with company info
  pw.Widget _buildHeader(Facturation facturation) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              companyName,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(companyPhone, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(companyEmail, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'FACTURE',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'N° ${facturation.factureNumber}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Date: ${_formatDate(facturation.dateFacture)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            if (facturation.datePaiement != null)
              pw.Text(
                'Payée le: ${_formatDate(facturation.datePaiement!)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }

  // Build client information section
  pw.Widget _buildClientInfo(Client? clientFacture, Client? clientSource) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FACTURÉ À:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 5),
              if (clientFacture != null) ...[
                pw.Text(
                  clientFacture.name,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (clientFacture.address.isNotEmpty)
                  pw.Text(clientFacture.address, style: const pw.TextStyle(fontSize: 11)),
                if (clientFacture.phone.isNotEmpty)
                  pw.Text('Tél: ${clientFacture.phone}', style: const pw.TextStyle(fontSize: 11)),
              ] else
                pw.Text('Client non trouvé', style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        ),
        if (clientSource != null) ...[
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LIVRÉ À:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  clientSource.name,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (clientSource.address.isNotEmpty)
                  pw.Text(clientSource.address, style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Build invoice details
  pw.Widget _buildInvoiceDetails(Facturation facturation) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DÉTAILS DE LA FACTURE',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Bons de livraison inclus: ${facturation.blReferences.join(', ')}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          if (facturation.commentaires != null && facturation.commentaires!.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              'Commentaires: ${facturation.commentaires}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
          pw.SizedBox(height: 3),
          pw.Text(
            'Statut: ${facturation.statusText}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  // Build line items table
  pw.Widget _buildLineItems(List<FactureLineItem> lineItems) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DÉTAIL DES PRESTATIONS',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FixedColumnWidth(80), // BL
            1: const pw.FlexColumnWidth(3), // Article
            2: const pw.FlexColumnWidth(2), // Traitement
            3: const pw.FixedColumnWidth(50), // Qté
            4: const pw.FixedColumnWidth(70), // Prix U.
            5: const pw.FixedColumnWidth(80), // Total
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('BL', isHeader: true),
                _buildTableCell('Article', isHeader: true),
                _buildTableCell('Traitement', isHeader: true),
                _buildTableCell('Qté', isHeader: true),
                _buildTableCell('Prix U.', isHeader: true),
                _buildTableCell('Total', isHeader: true),
              ],
            ),
            // Data rows
            ...lineItems.map((item) => pw.TableRow(
              children: [
                _buildTableCell(item.blReference),
                _buildTableCell('${item.articleReference}\n${item.articleDesignation}'),
                _buildTableCell(item.treatmentName),
                _buildTableCell(item.quantity.toString()),
                _buildTableCell('${item.prixUnitaire.toStringAsFixed(3)} DT'),
                _buildTableCell('${item.total.toStringAsFixed(3)} DT'),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }

  // Build table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  // Build totals section
  pw.Widget _buildTotals(Facturation facturation) {
    const tva = 0.19; // 19% TVA
    final ht = facturation.totalAmount / (1 + tva);
    final montantTva = facturation.totalAmount - ht;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              _buildTotalRow('Total HT:', '${ht.toStringAsFixed(3)} DT'),
              _buildTotalRow('TVA (19%):', '${montantTva.toStringAsFixed(3)} DT'),
              pw.Divider(color: PdfColors.grey400),
              _buildTotalRow(
                'TOTAL TTC:',
                '${facturation.totalAmount.toStringAsFixed(3)} DT',
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build total row
  pw.Widget _buildTotalRow(String label, String amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Build footer
  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.Text(
          'Merci pour votre confiance !',
          style: pw.TextStyle(
            fontSize: 10,
            fontStyle: pw.FontStyle.italic,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Cette facture a été générée automatiquement par $companyName',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // Format date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Save PDF to file
  Future<File> _savePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    return await _saveFile(bytes, '$fileName.pdf');
  }

  // Save file to documents directory
  Future<File> _saveFile(Uint8List bytes, String fileName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final invoiceDir = Directory('${appDocumentDir.path}/GestCom/invoices');
    
    if (!await invoiceDir.exists()) {
      await invoiceDir.create(recursive: true);
    }

    final file = File('${invoiceDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  // Open PDF file
  Future<void> openPdf(String fileName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocumentDir.path}/GestCom/invoices/$fileName.pdf');
    
    if (await file.exists()) {
      // On Windows, use the default PDF viewer
      await Process.run('start', ['', file.path], runInShell: true);
    } else {
      throw Exception('Fichier PDF non trouvé');
    }
  }

  // Get invoice file path
  Future<String> getInvoiceFilePath(String fileName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return '${appDocumentDir.path}/GestCom/invoices/$fileName.pdf';
  }

  // Check if invoice PDF exists
  Future<bool> invoicePdfExists(String fileName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocumentDir.path}/GestCom/invoices/$fileName.pdf');
    return await file.exists();
  }
}
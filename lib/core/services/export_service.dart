import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../features/inventaire/data/inventory_models.dart';

class ExportService {
  // Export inventory to PDF
  Future<void> exportInventoryToPdf(List<InventoryItem> items) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    // Create PDF content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text(
                    'INVENTAIRE',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Généré le ${dateFormat.format(now)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),
            ),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        items.length.toString(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Articles Total'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        items.where((item) => item.currentStock > 0).length.toString(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('En Stock'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        items.where((item) => item.currentStock <= 0).length.toString(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Rupture'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        items.fold<int>(0, (sum, item) => sum + item.currentStock).toString(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Unités Total'),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Table
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Client',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Article',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Traitement',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Stock',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Dernière Réception',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // Data rows
                ...items.map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item.clientName, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            item.articleReference,
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            item.articleDesignation,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item.treatmentName, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        item.currentStock.toString(),
                        style: const pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        item.lastReceptionDate != null
                            ? dateFormat.format(item.lastReceptionDate!)
                            : '-',
                        style: const pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ];
        },
      ),
    );

    // Save the PDF
    final output = await getDownloadsDirectory();
    final fileName = 'inventaire_${DateFormat('yyyy-MM-dd_HH-mm').format(now)}.pdf';
    final file = File('${output!.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
  }

  // Export inventory to Excel
  Future<void> exportInventoryToExcel(List<InventoryItem> items) async {
    final excel = Excel.createExcel();
    final sheet = excel['Inventaire'];
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    // Header row
    final headers = [
      'Client',
      'Référence Article',
      'Désignation Article',
      'Traitement',
      'Stock Actuel',
      'Total Reçu',
      'Total Livré',
      'Dernière Réception',
      'Dernière Livraison',
      'Références BR',
      'Références BL',
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#E0E0E0',
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // Data rows
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final rowIndex = i + 1;

      final rowData = [
        item.clientName,
        item.articleReference,
        item.articleDesignation,
        item.treatmentName,
        item.currentStock,
        item.totalReceived,
        item.totalDelivered,
        item.lastReceptionDate != null 
            ? dateFormat.format(item.lastReceptionDate!) 
            : '',
        item.lastDeliveryDate != null 
            ? dateFormat.format(item.lastDeliveryDate!) 
            : '',
        item.receptionReferences.join(', '),
        item.deliveryReferences.join(', '),
      ];

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = rowData[j];
        
        // Color code based on stock
        if (j == 4) { // Stock column
          if (item.currentStock <= 0) {
            cell.cellStyle = CellStyle(backgroundColorHex: '#FFEBEE');
          } else if (item.currentStock <= 5) {
            cell.cellStyle = CellStyle(backgroundColorHex: '#FFF3E0');
          } else {
            cell.cellStyle = CellStyle(backgroundColorHex: '#E8F5E8');
          }
        }
      }
    }

    // Summary sheet
    final summarySheet = excel['Résumé'];
    
    // Summary data
    final totalItems = items.length;
    final itemsWithStock = items.where((item) => item.currentStock > 0).length;
    final itemsWithoutStock = items.where((item) => item.currentStock <= 0).length;
    final totalStockUnits = items.fold<int>(0, (sum, item) => sum + item.currentStock);
    final uniqueClients = items.map((item) => item.clientId).toSet().length;
    final uniqueArticles = items.map((item) => item.articleReference).toSet().length;

    final summaryData = [
      ['Statistiques d\'Inventaire', ''],
      ['Généré le', dateFormat.format(now)],
      ['', ''],
      ['Total Articles', totalItems],
      ['Articles en Stock', itemsWithStock],
      ['Articles en Rupture', itemsWithoutStock],
      ['Total Unités en Stock', totalStockUnits],
      ['Clients Uniques', uniqueClients],
      ['Articles Uniques', uniqueArticles],
    ];

    for (int i = 0; i < summaryData.length; i++) {
      for (int j = 0; j < summaryData[i].length; j++) {
        final cell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i));
        cell.value = summaryData[i][j];
        
        if (i == 0 && j == 0) {
          cell.cellStyle = CellStyle(
            bold: true,
            fontSize: 16,
            backgroundColorHex: '#E3F2FD',
          );
        } else if (j == 0 && summaryData[i][j].toString().isNotEmpty) {
          cell.cellStyle = CellStyle(bold: true);
        }
      }
    }

    // Save the Excel file
    final output = await getDownloadsDirectory();
    final fileName = 'inventaire_${DateFormat('yyyy-MM-dd_HH-mm').format(now)}.xlsx';
    final file = File('${output!.path}/$fileName');
    
    final excelBytes = excel.save();
    if (excelBytes != null) {
      await file.writeAsBytes(excelBytes);
    }
  }

  // Export article history to PDF
  Future<void> exportArticleHistoryToPdf(ArticleHistory history) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text(
                    'HISTORIQUE ARTICLE',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    '${history.articleReference} - ${history.articleDesignation}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text('Client: ${history.clientName}'),
                  pw.Text('Traitement: ${history.treatmentName}'),
                  pw.Text('Généré le ${dateFormat.format(now)}'),
                  pw.SizedBox(height: 20),
                ],
              ),
            ),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        history.currentStock.toString(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Stock Actuel'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        history.totalReceived.toString(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Total Reçu'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        history.totalDelivered.toString(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Total Livré'),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Movements table
            if (history.movements.isNotEmpty) ...[
              pw.Text(
                'Mouvements',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Type',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Date',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Référence',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Quantité',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Data rows
                  ...history.movements.map((movement) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          movement.type == 'reception' ? 'Réception' : 'Livraison',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          dateFormat.format(movement.date),
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          movement.reference,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${movement.type == 'reception' ? '+' : '-'}${movement.quantity}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ],
          ];
        },
      ),
    );

    // Save the PDF
    final output = await getDownloadsDirectory();
    final fileName = 'historique_${history.articleReference}_${DateFormat('yyyy-MM-dd_HH-mm').format(now)}.pdf';
    final file = File('${output!.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
  }
}
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/article_model.dart';
import '../../data/models/client_model.dart';
import '../../data/models/bon_livraison_model.dart';
import '../../data/models/bon_reception_model.dart';

class ExcelExportService {
  /// Export articles to Excel
  Future<File> exportArticles(List<Article> articles) async {
    final excel = Excel.createExcel();
    final sheet = excel['Articles'];

    // Add headers
    final headers = ['Référence', 'Désignation', 'Actif', 'Client ID', 'Date Création'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
      cell.cellStyle = CellStyle(bold: true, backgroundColorHex: '#E0E0E0');
    }

    // Add data rows
    for (int i = 0; i < articles.length; i++) {
      final article = articles[i];
      final rowIndex = i + 1;
      final rowData = [
        article.reference,
        article.designation,
        article.isActive ? 'Oui' : 'Non',
        article.clientId ?? 'Général',
        DateFormat('dd/MM/yyyy').format(article.createdAt),
      ];

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = rowData[j];
      }
    }

    return await _saveExcelFile(excel, 'Articles_Export');
  }

  /// Export clients to Excel
  Future<File> exportClients(List<Client> clients) async {
    final excel = Excel.createExcel();
    final sheet = excel['Clients'];

    // Add headers
    final headers = ['Nom', 'Matricule Fiscal', 'Téléphone', 'Email', 'Adresse', 'Date Création'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
      cell.cellStyle = CellStyle(bold: true, backgroundColorHex: '#E0E0E0');
    }

    // Add data rows
    for (int i = 0; i < clients.length; i++) {
      final client = clients[i];
      final rowIndex = i + 1;
      final rowData = [
        client.name,
        client.matriculeFiscal,
        client.phone,
        client.email,
        client.address,
        DateFormat('dd/MM/yyyy').format(client.createdAt),
      ];

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = rowData[j];
      }
    }

    return await _saveExcelFile(excel, 'Clients_Export');
  }

  /// Export deliveries (Bons de Livraison) to Excel
  Future<File> exportDeliveries(List<BonLivraison> deliveries) async {
    final excel = Excel.createExcel();
    final sheet = excel['Bons de Livraison'];

    // Add headers
    final headers = ['N° BL', 'Client', 'Date Livraison', 'Total Articles', 'Total Pièces', 'Statut', 'Date Création'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
      cell.cellStyle = CellStyle(bold: true, backgroundColorHex: '#E0E0E0');
    }

    // Add data rows
    for (int i = 0; i < deliveries.length; i++) {
      final delivery = deliveries[i];
      final rowIndex = i + 1;
      final rowData = [
        delivery.blNumber,
        delivery.clientName,
        DateFormat('dd/MM/yyyy').format(delivery.dateLivraison),
        delivery.totalArticles,
        delivery.totalPieces,
        delivery.statusLabel,
        DateFormat('dd/MM/yyyy').format(delivery.createdAt),
      ];

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = rowData[j];
      }
    }

    return await _saveExcelFile(excel, 'Livraisons_Export');
  }

  /// Export receptions (Bons de Réception) to Excel
  Future<File> exportReceptions(List<BonReception> receptions) async {
    final excel = Excel.createExcel();
    final sheet = excel['Bons de Réception'];

    // Add headers
    final headers = ['N° BR', 'Client ID', 'Date Réception', 'Total Quantité', 'Date Création'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
      cell.cellStyle = CellStyle(bold: true, backgroundColorHex: '#E0E0E0');
    }

    // Add data rows
    for (int i = 0; i < receptions.length; i++) {
      final reception = receptions[i];
      final rowIndex = i + 1;
      final rowData = [
        reception.id,
        reception.clientId,
        DateFormat('dd/MM/yyyy').format(reception.dateReception),
        reception.totalQuantity,
        DateFormat('dd/MM/yyyy').format(reception.createdAt),
      ];

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = rowData[j];
      }
    }

    return await _saveExcelFile(excel, 'Receptions_Export');
  }

  /// Save Excel file to documents directory
  Future<File> _saveExcelFile(Excel excel, String baseName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${appDocumentDir.path}/GestCom/exports');
    
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${baseName}_$timestamp.xlsx';
    final filePath = '${exportDir.path}/$fileName';

    final file = File(filePath);
    final bytes = excel.save();
    
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }

    return file;
  }

  /// Open Excel file with default application
  Future<void> openExcelFile(File file) async {
    if (Platform.isWindows) {
      await Process.run('start', ['', file.path], runInShell: true);
    }
  }
}

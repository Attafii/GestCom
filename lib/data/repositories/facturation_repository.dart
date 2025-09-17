import 'package:hive/hive.dart';
import '../models/facturation_model.dart';
import '../models/bon_livraison_model.dart';
import '../models/article_livraison_model.dart';
import '../models/client_model.dart';
import '../models/article_model.dart';
import '../models/treatment_model.dart';

class FacturationRepository {
  static const String _boxName = 'facturations';
  
  Box<Facturation> get _box => Hive.box<Facturation>(_boxName);

  // Get all invoices
  List<Facturation> getAllInvoices() {
    return _box.values.toList()
      ..sort((a, b) => b.dateFacture.compareTo(a.dateFacture));
  }

  // Get invoices by client (either facture or source)
  List<Facturation> getInvoicesByClient(String clientId) {
    return _box.values
        .where((invoice) => 
            invoice.clientFactureId == clientId || 
            invoice.clientSourceId == clientId)
        .toList()
      ..sort((a, b) => b.dateFacture.compareTo(a.dateFacture));
  }

  // Get invoices by status
  List<Facturation> getInvoicesByStatus(String status) {
    return _box.values
        .where((invoice) => invoice.status == status)
        .toList()
      ..sort((a, b) => b.dateFacture.compareTo(a.dateFacture));
  }

  // Get pending invoices (brouillon, valide)
  List<Facturation> getPendingInvoices() {
    return _box.values
        .where((invoice) => ['brouillon', 'valide'].contains(invoice.status))
        .toList()
      ..sort((a, b) => b.dateFacture.compareTo(a.dateFacture));
  }

  // Get paid invoices
  List<Facturation> getPaidInvoices() {
    return getInvoicesByStatus('paye');
  }

  // Get invoice by ID
  Facturation? getInvoiceById(String id) {
    return _box.values.firstWhere(
      (invoice) => invoice.id == id,
      orElse: () => throw StateError('Invoice not found'),
    );
  }

  // Get invoice by facture number
  Facturation? getInvoiceByNumber(String factureNumber) {
    try {
      return _box.values.firstWhere(
        (invoice) => invoice.factureNumber == factureNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // Check if BL is already invoiced
  bool isBLInvoiced(String blId) {
    return _box.values.any((invoice) => 
        invoice.blReferences.contains(blId) && 
        invoice.status != 'annule');
  }

  // Get all BLs that are already invoiced
  Set<String> getInvoicedBLs() {
    final invoicedBLs = <String>{};
    for (final invoice in _box.values) {
      if (invoice.status != 'annule') {
        invoicedBLs.addAll(invoice.blReferences);
      }
    }
    return invoicedBLs;
  }

  // Get pending BLs (delivered but not yet invoiced)
  List<BonLivraison> getPendingBLsForInvoicing() {
    final livraisonBox = Hive.box<BonLivraison>('bon_livraison');
    final invoicedBLs = getInvoicedBLs();
    
    return livraisonBox.values
        .where((bl) => 
            bl.status == 'livre' && // Only delivered BLs
            !invoicedBLs.contains(bl.id)) // Not already invoiced
        .toList()
      ..sort((a, b) => b.dateLivraison.compareTo(a.dateLivraison));
  }

  // Get pending BLs for a specific client
  List<BonLivraison> getPendingBLsForClient(String clientId) {
    return getPendingBLsForInvoicing()
        .where((bl) => bl.clientId == clientId)
        .toList();
  }

  // Validate BLs for invoicing
  Map<String, dynamic> validateBLsForInvoicing(List<String> blIds) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (blIds.isEmpty) {
      errors.add('Aucun bon de livraison sélectionné');
      return {'isValid': false, 'errors': errors, 'warnings': warnings};
    }

    final livraisonBox = Hive.box<BonLivraison>('bon_livraison');
    final invoicedBLs = getInvoicedBLs();
    
    for (final blId in blIds) {
      final bl = livraisonBox.get(blId);
      
      if (bl == null) {
        errors.add('Bon de livraison $blId non trouvé');
        continue;
      }
      
      if (bl.status != 'livre') {
        errors.add('BL ${bl.blNumber} n\'est pas encore livré');
      }
      
      if (invoicedBLs.contains(blId)) {
        errors.add('BL ${bl.blNumber} est déjà facturé');
      }
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
    };
  }

  // Calculate total amount from BLs
  double calculateTotalFromBLs(List<String> blIds) {
    final livraisonBox = Hive.box<BonLivraison>('bon_livraison');
    double total = 0.0;
    
    for (final blId in blIds) {
      final bl = livraisonBox.get(blId);
      if (bl != null) {
        total += bl.montantTotal;
      }
    }
    
    return total;
  }

  // Generate next facture number
  String generateNextFactureNumber() {
    final currentYear = DateTime.now().year;
    final prefix = 'FAC$currentYear';
    
    final existingNumbers = _box.values
        .where((invoice) => invoice.factureNumber.startsWith(prefix))
        .map((invoice) => invoice.factureNumber)
        .toList();
    
    int nextNumber = 1;
    while (existingNumbers.contains('$prefix${nextNumber.toString().padLeft(3, '0')}')) {
      nextNumber++;
    }
    
    return '$prefix${nextNumber.toString().padLeft(3, '0')}';
  }

  // Create invoice
  Future<Facturation> createInvoice(Facturation invoice) async {
    // Validate BLs
    final validation = validateBLsForInvoicing(invoice.blReferences);
    if (!validation['isValid']) {
      throw Exception('Validation échouée: ${validation['errors'].join(', ')}');
    }

    await _box.put(invoice.id, invoice);
    return invoice;
  }

  // Update invoice
  Future<Facturation> updateInvoice(Facturation invoice) async {
    if (!invoice.isEditable && invoice.key != null) {
      final existingInvoice = _box.get(invoice.key);
      if (existingInvoice?.status != 'brouillon') {
        throw Exception('Impossible de modifier une facture validée');
      }
    }

    await _box.put(invoice.id, invoice);
    return invoice;
  }

  // Delete invoice
  Future<void> deleteInvoice(String id) async {
    final invoice = getInvoiceById(id);
    if (invoice != null && !invoice.isEditable) {
      throw Exception('Impossible de supprimer une facture validée');
    }

    await _box.delete(id);
  }

  // Mark invoice as paid
  Future<Facturation> markAsPaid(String id, DateTime paymentDate) async {
    final invoice = getInvoiceById(id);
    if (invoice == null) {
      throw Exception('Facture non trouvée');
    }

    final updatedInvoice = invoice.copyWith(
      status: 'paye',
      datePaiement: paymentDate,
    );

    await _box.put(id, updatedInvoice);
    return updatedInvoice;
  }

  // Cancel invoice
  Future<Facturation> cancelInvoice(String id, String reason) async {
    final invoice = getInvoiceById(id);
    if (invoice == null) {
      throw Exception('Facture non trouvée');
    }

    if (invoice.status == 'paye') {
      throw Exception('Impossible d\'annuler une facture payée');
    }

    final updatedInvoice = invoice.copyWith(
      status: 'annule',
      commentaires: reason,
    );

    await _box.put(id, updatedInvoice);
    return updatedInvoice;
  }

  // Get invoice line items from BLs
  List<FactureLineItem> getInvoiceLineItems(List<String> blIds) {
    final livraisonBox = Hive.box<BonLivraison>('bon_livraison');
    final articleBox = Hive.box<Article>('articles');
    final treatmentBox = Hive.box<Treatment>('treatments');
    
    final lineItems = <FactureLineItem>[];
    
    for (final blId in blIds) {
      final bl = livraisonBox.get(blId);
      if (bl == null) continue;
      
      for (final articleLivraison in bl.articles) {
        final article = articleBox.values
            .firstWhere((a) => a.reference == articleLivraison.articleReference,
                orElse: () => Article(
                    reference: articleLivraison.articleReference,
                    designation: 'Article non trouvé',
                    traitementPrix: {}));
        
        final treatment = treatmentBox.get(articleLivraison.treatmentId);
        
        lineItems.add(FactureLineItem(
          articleReference: articleLivraison.articleReference,
          articleDesignation: article.designation,
          treatmentId: articleLivraison.treatmentId,
          treatmentName: treatment?.name ?? 'Traitement non trouvé',
          quantity: articleLivraison.quantityLivree,
          prixUnitaire: articleLivraison.prixUnitaire,
          total: articleLivraison.montantTotal,
          blReference: bl.blNumber,
        ));
      }
    }
    
    return lineItems;
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final invoices = getAllInvoices();
    final currentMonth = DateTime.now();
    final startOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    
    final thisMonthInvoices = invoices.where((invoice) => 
        invoice.dateFacture.isAfter(startOfMonth)).toList();
    
    final paidInvoices = invoices.where((invoice) => 
        invoice.status == 'paye').toList();
    
    final pendingInvoices = invoices.where((invoice) => 
        ['brouillon', 'valide', 'envoye'].contains(invoice.status)).toList();

    final totalAmount = invoices.fold(0.0, (sum, invoice) => 
        sum + (invoice.status != 'annule' ? invoice.totalAmount : 0));
    
    final paidAmount = paidInvoices.fold(0.0, (sum, invoice) => 
        sum + invoice.totalAmount);
    
    final pendingAmount = pendingInvoices.fold(0.0, (sum, invoice) => 
        sum + invoice.totalAmount);

    return {
      'totalInvoices': invoices.length,
      'thisMonthInvoices': thisMonthInvoices.length,
      'paidInvoices': paidInvoices.length,
      'pendingInvoices': pendingInvoices.length,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'pendingBLs': getPendingBLsForInvoicing().length,
    };
  }
}
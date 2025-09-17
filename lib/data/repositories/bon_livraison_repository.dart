import 'package:hive/hive.dart';
import '../models/bon_livraison_model.dart';
import '../models/bon_reception_model.dart';
import '../models/article_model.dart';
import '../models/client_model.dart';

class BonLivraisonRepository {
  static const String _boxName = 'bon_livraison';
  
  Box<BonLivraison> get _box => Hive.box<BonLivraison>(_boxName);

  // Get all delivery notes
  List<BonLivraison> getAllDeliveries() {
    return _box.values.toList()
      ..sort((a, b) => b.dateLivraison.compareTo(a.dateLivraison));
  }

  // Get deliveries by client
  List<BonLivraison> getDeliveriesByClient(String clientId) {
    return _box.values
        .where((delivery) => delivery.clientId == clientId)
        .toList()
      ..sort((a, b) => b.dateLivraison.compareTo(a.dateLivraison));
  }

  // Get deliveries by status
  List<BonLivraison> getDeliveriesByStatus(String status) {
    return _box.values
        .where((delivery) => delivery.status == status)
        .toList()
      ..sort((a, b) => b.dateLivraison.compareTo(a.dateLivraison));
  }

  // Get deliveries by date range
  List<BonLivraison> getDeliveriesByDateRange(DateTime startDate, DateTime endDate) {
    return _box.values
        .where((delivery) => 
            delivery.dateLivraison.isAfter(startDate.subtract(const Duration(days: 1))) &&
            delivery.dateLivraison.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.dateLivraison.compareTo(a.dateLivraison));
  }

  // Get delivery by ID
  BonLivraison? getDeliveryById(String id) {
    try {
      return _box.values.firstWhere((delivery) => delivery.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get delivery by BL number
  BonLivraison? getDeliveryByBlNumber(String blNumber) {
    try {
      return _box.values.firstWhere((delivery) => delivery.blNumber == blNumber);
    } catch (e) {
      return null;
    }
  }

  // Search deliveries
  List<BonLivraison> searchDeliveries(String query, {String? clientId, String? status}) {
    if (query.isEmpty && clientId == null && status == null) {
      return getAllDeliveries();
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _box.values.where((delivery) {
      // Filter by client if specified
      if (clientId != null && delivery.clientId != clientId) return false;
      
      // Filter by status if specified
      if (status != null && delivery.status != status) return false;
      
      // Text search
      if (query.isNotEmpty) {
        return delivery.blNumber.toLowerCase().contains(lowercaseQuery) ||
               delivery.clientName.toLowerCase().contains(lowercaseQuery) ||
               delivery.notes?.toLowerCase().contains(lowercaseQuery) == true ||
               delivery.articles.any((article) => 
                   article.articleReference.toLowerCase().contains(lowercaseQuery) ||
                   article.articleDesignation.toLowerCase().contains(lowercaseQuery));
      }
      
      return true;
    }).toList()
      ..sort((a, b) => b.dateLivraison.compareTo(a.dateLivraison));
  }

  // Generate next BL number
  String generateNextBlNumber() {
    final allDeliveries = getAllDeliveries();
    if (allDeliveries.isEmpty) {
      return 'BL001';
    }
    
    // Extract numbers from existing BL numbers
    final numbers = allDeliveries
        .map((delivery) => delivery.blNumber)
        .where((blNumber) => blNumber.startsWith('BL'))
        .map((blNumber) => int.tryParse(blNumber.substring(2)) ?? 0)
        .toList();
    
    if (numbers.isEmpty) {
      return 'BL001';
    }
    
    final maxNumber = numbers.reduce((a, b) => a > b ? a : b);
    final nextNumber = maxNumber + 1;
    
    return 'BL${nextNumber.toString().padLeft(3, '0')}';
  }

  // Check stock availability for client
  Map<String, Map<String, int>> getAvailableStockForClient(String clientId) {
    final receptionBox = Hive.box<BonReception>('bon_receptions');
    final deliveryBox = _box;
    
    // Get all receptions for this client
    final receptions = receptionBox.values
        .where((reception) => reception.clientId == clientId)
        .toList();
    
    // Calculate received quantities (grouped by article reference only, no treatment)
    final receivedStock = <String, int>{};
    for (final reception in receptions) {
      for (final article in reception.articles) {
        final currentQty = receivedStock[article.articleReference] ?? 0;
        receivedStock[article.articleReference] = currentQty + article.quantity;
      }
    }
    
    // Calculate delivered quantities
    final deliveredStock = <String, Map<String, int>>{};
    final deliveries = getDeliveriesByClient(clientId)
        .where((delivery) => delivery.status != 'annule')
        .toList();
    
    for (final delivery in deliveries) {
      for (final article in delivery.articles) {
        if (!deliveredStock.containsKey(article.articleReference)) {
          deliveredStock[article.articleReference] = {};
        }
        
        final currentQty = deliveredStock[article.articleReference]![article.treatmentId] ?? 0;
        deliveredStock[article.articleReference]![article.treatmentId] = 
            currentQty + article.quantityLivree;
      }
    }
    
    // For available stock calculation, we need to consider that:
    // - Reception doesn't have treatments (total quantity received per article)
    // - Delivery has treatments (specific quantity delivered per article+treatment)
    // - Available stock = received - sum of all delivered treatments for that article
    
    final availableStock = <String, Map<String, int>>{};
    
    for (final articleRef in receivedStock.keys) {
      final receivedQty = receivedStock[articleRef] ?? 0;
      final deliveredQty = deliveredStock[articleRef]?.values.fold(0, (sum, qty) => sum + qty) ?? 0;
      final availableQty = receivedQty - deliveredQty;
      
      if (availableQty > 0) {
        // Since we don't know which treatments were used in reception,
        // we'll assume all treatments are available with the total available quantity
        // This is a simplified approach - in reality, you might want to track treatments in reception too
        availableStock[articleRef] = {'default': availableQty};
      }
    }
    
    return availableStock;
  }

  // Add new delivery
  Future<void> addDelivery(BonLivraison delivery) async {
    // Check if BL number already exists
    final existingDelivery = getDeliveryByBlNumber(delivery.blNumber);
    if (existingDelivery != null) {
      throw Exception('Un bon de livraison avec ce numéro existe déjà');
    }

    // Validate stock availability
    final availableStock = getAvailableStockForClient(delivery.clientId);
    
    for (final article in delivery.articles) {
      final available = availableStock[article.articleReference]?[article.treatmentId] ?? 0;
      if (article.quantityLivree > available) {
        throw Exception(
          'Stock insuffisant pour ${article.articleReference} - ${article.treatmentName}. '
          'Disponible: $available, Demandé: ${article.quantityLivree}'
        );
      }
    }

    await _box.put(delivery.id, delivery);
  }

  // Update existing delivery
  Future<void> updateDelivery(BonLivraison delivery) async {
    if (!_box.containsKey(delivery.id)) {
      throw Exception('Bon de livraison non trouvé');
    }

    // Check if BL number already exists for another delivery
    BonLivraison? existingDelivery;
    try {
      existingDelivery = _box.values.firstWhere(
        (d) => d.blNumber == delivery.blNumber && d.id != delivery.id,
      );
    } catch (e) {
      existingDelivery = null;
    }
    
    if (existingDelivery != null) {
      throw Exception('Un bon de livraison avec ce numéro existe déjà');
    }

    // Validate stock availability (exclude current delivery from calculation)
    final originalDelivery = _box.get(delivery.id);
    if (originalDelivery != null) {
      // Temporarily remove original delivery for stock calculation
      await _box.delete(delivery.id);
      
      try {
        final availableStock = getAvailableStockForClient(delivery.clientId);
        
        for (final article in delivery.articles) {
          final available = availableStock[article.articleReference]?[article.treatmentId] ?? 0;
          if (article.quantityLivree > available) {
            throw Exception(
              'Stock insuffisant pour ${article.articleReference} - ${article.treatmentName}. '
              'Disponible: $available, Demandé: ${article.quantityLivree}'
            );
          }
        }
        
        await _box.put(delivery.id, delivery);
      } catch (e) {
        // Restore original delivery if validation fails
        await _box.put(delivery.id, originalDelivery);
        rethrow;
      }
    } else {
      await _box.put(delivery.id, delivery);
    }
  }

  // Delete delivery
  Future<void> deleteDelivery(String id) async {
    if (!_box.containsKey(id)) {
      throw Exception('Bon de livraison non trouvé');
    }

    await _box.delete(id);
  }

  // Update delivery status
  Future<void> updateDeliveryStatus(String id, String status) async {
    final delivery = _box.get(id);
    if (delivery == null) {
      throw Exception('Bon de livraison non trouvé');
    }

    final updatedDelivery = delivery.copyWith(status: status);
    await _box.put(id, updatedDelivery);
  }

  // Get delivery statistics
  Map<String, dynamic> getDeliveryStatistics() {
    final allDeliveries = getAllDeliveries();
    
    return {
      'total': allDeliveries.length,
      'pending': allDeliveries.where((d) => d.status == 'en_attente').length,
      'delivered': allDeliveries.where((d) => d.status == 'livre').length,
      'cancelled': allDeliveries.where((d) => d.status == 'annule').length,
      'totalAmount': allDeliveries
          .where((d) => d.status != 'annule')
          .fold(0.0, (sum, delivery) => sum + delivery.montantTotal),
      'totalQuantity': allDeliveries
          .where((d) => d.status != 'annule')
          .fold(0, (sum, delivery) => sum + delivery.totalQuantity),
    };
  }

  // Get deliveries by month
  Map<String, List<BonLivraison>> getDeliveriesByMonth(int year) {
    final deliveries = getAllDeliveries()
        .where((delivery) => delivery.dateLivraison.year == year)
        .toList();
    
    final monthlyDeliveries = <String, List<BonLivraison>>{};
    
    for (final delivery in deliveries) {
      final monthKey = '${delivery.dateLivraison.year}-${delivery.dateLivraison.month.toString().padLeft(2, '0')}';
      
      if (!monthlyDeliveries.containsKey(monthKey)) {
        monthlyDeliveries[monthKey] = [];
      }
      
      monthlyDeliveries[monthKey]!.add(delivery);
    }
    
    return monthlyDeliveries;
  }

  // Export deliveries to JSON
  List<Map<String, dynamic>> exportToJson() {
    return _box.values.map((delivery) => delivery.toJson()).toList();
  }

  // Clear all deliveries (for testing or reset)
  Future<void> clearAll() async {
    await _box.clear();
  }

  // Get delivery count
  int getDeliveryCount() {
    return _box.length;
  }

  // Check if BL number exists
  bool blNumberExists(String blNumber, {String? excludeId}) {
    return _box.values.any((delivery) => 
      delivery.blNumber == blNumber && 
      (excludeId == null || delivery.id != excludeId)
    );
  }
}
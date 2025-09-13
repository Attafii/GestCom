import 'package:hive/hive.dart';
import '../models/bon_reception_model.dart';
import '../models/article_reception_model.dart';

class BonReceptionRepository {
  static const String _boxName = 'bon_receptions';
  
  Box<BonReception> get _box => Hive.box<BonReception>(_boxName);

  // Get all receptions
  List<BonReception> getAllReceptions() {
    return _box.values.toList()
      ..sort((a, b) => b.dateReception.compareTo(a.dateReception));
  }

  // Get receptions by client ID
  List<BonReception> getReceptionsByClient(String clientId) {
    return _box.values
        .where((reception) => reception.clientId == clientId)
        .toList()
      ..sort((a, b) => b.dateReception.compareTo(a.dateReception));
  }

  // Get receptions by status
  List<BonReception> getReceptionsByStatus(String status) {
    return _box.values
        .where((reception) => reception.status == status)
        .toList()
      ..sort((a, b) => b.dateReception.compareTo(a.dateReception));
  }

  // Get receptions by date range
  List<BonReception> getReceptionsByDateRange(DateTime startDate, DateTime endDate) {
    return _box.values
        .where((reception) => 
            reception.dateReception.isAfter(startDate.subtract(const Duration(days: 1))) &&
            reception.dateReception.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.dateReception.compareTo(a.dateReception));
  }

  // Get reception by ID
  BonReception? getReceptionById(String id) {
    try {
      return _box.values.firstWhere((reception) => reception.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get reception by commande number
  BonReception? getReceptionByCommandeNumber(String commandeNumber) {
    try {
      return _box.values.firstWhere((reception) => reception.commandeNumber == commandeNumber);
    } catch (e) {
      return null;
    }
  }

  // Search receptions
  List<BonReception> searchReceptions(String query, {String? clientId}) {
    if (query.isEmpty) {
      return clientId != null ? getReceptionsByClient(clientId) : getAllReceptions();
    }
    
    final lowercaseQuery = query.toLowerCase();
    var receptions = _box.values.where((reception) {
      if (clientId != null && reception.clientId != clientId) return false;
      
      return reception.commandeNumber.toLowerCase().contains(lowercaseQuery) ||
             reception.notes?.toLowerCase().contains(lowercaseQuery) == true ||
             reception.articles.any((article) => 
                 article.articleReference.toLowerCase().contains(lowercaseQuery) ||
                 article.articleDesignation.toLowerCase().contains(lowercaseQuery));
    }).toList();
    
    return receptions..sort((a, b) => b.dateReception.compareTo(a.dateReception));
  }

  // Get recent receptions (last 30 days)
  List<BonReception> getRecentReceptions({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _box.values
        .where((reception) => reception.dateReception.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.dateReception.compareTo(a.dateReception));
  }

  // Add new reception
  Future<void> addReception(BonReception reception) async {
    // Check if commande number already exists
    final existingReception = getReceptionByCommandeNumber(reception.commandeNumber);
    
    if (existingReception != null) {
      throw Exception('Un bon de réception avec ce numéro de commande existe déjà');
    }

    await _box.put(reception.id, reception);
  }

  // Update existing reception
  Future<void> updateReception(BonReception reception) async {
    if (!_box.containsKey(reception.id)) {
      throw Exception('Bon de réception non trouvé');
    }

    // Check if commande number already exists for another reception
    final existingReception = _box.values.firstWhere(
      (r) => r.commandeNumber == reception.commandeNumber && r.id != reception.id,
      orElse: () => null!,
    );
    
    if (existingReception != null) {
      throw Exception('Un bon de réception avec ce numéro de commande existe déjà');
    }

    final updatedReception = reception.copyWith(updatedAt: DateTime.now());
    await _box.put(reception.id, updatedReception);
  }

  // Delete reception
  Future<void> deleteReception(String id) async {
    if (!_box.containsKey(id)) {
      throw Exception('Bon de réception non trouvé');
    }

    await _box.delete(id);
  }

  // Update reception status
  Future<void> updateReceptionStatus(String id, String status) async {
    final reception = _box.get(id);
    if (reception == null) {
      throw Exception('Bon de réception non trouvé');
    }

    final updatedReception = reception.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    await _box.put(id, updatedReception);
  }

  // Check if commande number exists
  bool commandeNumberExists(String commandeNumber, {String? excludeId}) {
    return _box.values.any((reception) => 
      reception.commandeNumber == commandeNumber && 
      (excludeId == null || reception.id != excludeId)
    );
  }

  // Get receptions count
  int getReceptionsCount() {
    return _box.length;
  }

  // Get receptions count by status
  int getReceptionsCountByStatus(String status) {
    return _box.values.where((reception) => reception.status == status).length;
  }

  // Get receptions count by client
  int getReceptionsCountByClient(String clientId) {
    return _box.values.where((reception) => reception.clientId == clientId).length;
  }

  // Get total amount for all receptions
  double getTotalAmount() {
    return _box.values.fold(0.0, (sum, reception) => sum + reception.totalAmount);
  }

  // Get total amount by client
  double getTotalAmountByClient(String clientId) {
    return _box.values
        .where((reception) => reception.clientId == clientId)
        .fold(0.0, (sum, reception) => sum + reception.totalAmount);
  }

  // Get total amount by status
  double getTotalAmountByStatus(String status) {
    return _box.values
        .where((reception) => reception.status == status)
        .fold(0.0, (sum, reception) => sum + reception.totalAmount);
  }

  // Get statistics by date range
  Map<String, dynamic> getStatisticsByDateRange(DateTime startDate, DateTime endDate) {
    final receptions = getReceptionsByDateRange(startDate, endDate);
    
    return {
      'count': receptions.length,
      'totalAmount': receptions.fold(0.0, (sum, r) => sum + r.totalAmount),
      'totalQuantity': receptions.fold(0, (sum, r) => sum + r.totalQuantity),
      'avgAmount': receptions.isEmpty ? 0.0 : 
          receptions.fold(0.0, (sum, r) => sum + r.totalAmount) / receptions.length,
      'byStatus': {
        'en_attente': receptions.where((r) => r.status == 'en_attente').length,
        'valide': receptions.where((r) => r.status == 'valide').length,
        'annule': receptions.where((r) => r.status == 'annule').length,
      },
    };
  }

  // Export receptions to JSON
  List<Map<String, dynamic>> exportToJson() {
    return _box.values.map((reception) => reception.toJson()).toList();
  }

  // Clear all receptions (for testing or reset)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
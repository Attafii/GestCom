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

  // Get reception by BR number
  BonReception? getReceptionByBRNumber(String numeroBR) {
    try {
      return _box.values.firstWhere((reception) => reception.numeroBR == numeroBR);
    } catch (e) {
      return null;
    }
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
             reception.numeroBR.toLowerCase().contains(lowercaseQuery) ||
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
    BonReception? existingReception;
    try {
      existingReception = _box.values.firstWhere(
        (r) => r.commandeNumber == reception.commandeNumber && r.id != reception.id,
      );
    } catch (e) {
      existingReception = null;
    }
    
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

  // Get statistics by date range
  Map<String, dynamic> getStatisticsByDateRange(DateTime startDate, DateTime endDate) {
    final receptions = getReceptionsByDateRange(startDate, endDate);
    
    return {
      'count': receptions.length,
      'totalAmount': receptions.fold(0.0, (sum, r) => sum + r.totalAmount),
      'totalQuantity': receptions.fold(0, (sum, r) => sum + r.totalQuantity),
      'avgAmount': receptions.isEmpty ? 0.0 : 
          receptions.fold(0.0, (sum, r) => sum + r.totalAmount) / receptions.length,
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
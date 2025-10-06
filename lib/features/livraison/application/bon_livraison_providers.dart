import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/bon_livraison_model.dart';
import '../../../data/models/bon_reception_model.dart';
import '../../../data/repositories/bon_livraison_repository.dart';

part 'bon_livraison_providers.g.dart';

// Repository provider
@riverpod
BonLivraisonRepository bonLivraisonRepository(BonLivraisonRepositoryRef ref) {
  return BonLivraisonRepository();
}

// Delivery list provider
@riverpod
class BonLivraisonList extends _$BonLivraisonList {
  @override
  List<BonLivraison> build() {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    return repository.getAllDeliveries();
  }

  // Add delivery
  Future<void> addDelivery(BonLivraison delivery) async {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    try {
      await repository.addDelivery(delivery);
      state = repository.getAllDeliveries();
    } catch (e) {
      rethrow;
    }
  }

  // Update delivery
  Future<void> updateDelivery(BonLivraison delivery) async {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    try {
      await repository.updateDelivery(delivery);
      state = repository.getAllDeliveries();
    } catch (e) {
      rethrow;
    }
  }

  // Delete delivery
  Future<void> deleteDelivery(String id) async {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    try {
      await repository.deleteDelivery(id);
      state = repository.getAllDeliveries();
    } catch (e) {
      rethrow;
    }
  }

  // Update delivery status
  Future<void> updateDeliveryStatus(String id, String status) async {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    try {
      await repository.updateDeliveryStatus(id, status);
      state = repository.getAllDeliveries();
    } catch (e) {
      rethrow;
    }
  }

  // Search deliveries
  void searchDeliveries(String query, {String? clientId, String? status}) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    state = repository.searchDeliveries(query, clientId: clientId, status: status);
  }

  // Filter by client
  void filterByClient(String? clientId) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    if (clientId == null) {
      state = repository.getAllDeliveries();
    } else {
      state = repository.getDeliveriesByClient(clientId);
    }
  }

  // Filter by status
  void filterByStatus(String? status) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    if (status == null) {
      state = repository.getAllDeliveries();
    } else {
      state = repository.getDeliveriesByStatus(status);
    }
  }

  // Filter by date range
  void filterByDateRange(DateTime startDate, DateTime endDate) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    state = repository.getDeliveriesByDateRange(startDate, endDate);
  }

  // Refresh deliveries list
  void refresh() {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    state = repository.getAllDeliveries();
  }
}

// Search query provider
@riverpod
class BonLivraisonSearchQuery extends _$BonLivraisonSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
    // Trigger search in delivery list
    final clientFilter = ref.read(bonLivraisonClientFilterProvider);
    final statusFilter = ref.read(bonLivraisonStatusFilterProvider);
    ref.read(bonLivraisonListProvider.notifier).searchDeliveries(
      query, 
      clientId: clientFilter, 
      status: statusFilter
    );
  }

  void clear() {
    state = '';
    ref.read(bonLivraisonListProvider.notifier).refresh();
  }
}

// Client filter provider
@riverpod
class BonLivraisonClientFilter extends _$BonLivraisonClientFilter {
  @override
  String? build() => null;

  void updateFilter(String? clientId) {
    state = clientId;
    final searchQuery = ref.read(bonLivraisonSearchQueryProvider);
    final statusFilter = ref.read(bonLivraisonStatusFilterProvider);
    ref.read(bonLivraisonListProvider.notifier).searchDeliveries(
      searchQuery, 
      clientId: clientId, 
      status: statusFilter
    );
  }

  void clear() {
    state = null;
    ref.read(bonLivraisonListProvider.notifier).refresh();
  }
}

// Status filter provider
@riverpod
class BonLivraisonStatusFilter extends _$BonLivraisonStatusFilter {
  @override
  String? build() => null;

  void updateFilter(String? status) {
    state = status;
    final searchQuery = ref.read(bonLivraisonSearchQueryProvider);
    final clientFilter = ref.read(bonLivraisonClientFilterProvider);
    ref.read(bonLivraisonListProvider.notifier).searchDeliveries(
      searchQuery, 
      clientId: clientFilter, 
      status: status
    );
  }

  void clear() {
    state = null;
    ref.read(bonLivraisonListProvider.notifier).refresh();
  }
}

// Selected delivery provider (for editing)
@riverpod
class SelectedBonLivraison extends _$SelectedBonLivraison {
  @override
  BonLivraison? build() => null;

  void selectDelivery(BonLivraison? delivery) {
    state = delivery;
  }

  void clearSelection() {
    state = null;
  }
}

// Next BL number provider
@riverpod
String nextBlNumber(NextBlNumberRef ref) {
  final repository = ref.read(bonLivraisonRepositoryProvider);
  return repository.generateNextBlNumber();
}

// Available stock provider for specific client
@riverpod
class AvailableStockForClient extends _$AvailableStockForClient {
  @override
  Map<String, Map<String, int>> build(String clientId) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    return repository.getAvailableStockForClient(clientId);
  }

  void refresh(String clientId) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    state = repository.getAvailableStockForClient(clientId);
  }
}

// Delivery statistics provider
@riverpod
Map<String, dynamic> bonLivraisonStatistics(BonLivraisonStatisticsRef ref) {
  final repository = ref.read(bonLivraisonRepositoryProvider);
  return repository.getDeliveryStatistics();
}

// Deliveries by client provider
@riverpod
List<BonLivraison> deliveriesByClient(DeliveriesByClientRef ref, String clientId) {
  final repository = ref.read(bonLivraisonRepositoryProvider);
  return repository.getDeliveriesByClient(clientId);
}

// Deliveries by status provider
@riverpod
List<BonLivraison> deliveriesByStatus(DeliveriesByStatusRef ref, String status) {
  final repository = ref.read(bonLivraisonRepositoryProvider);
  return repository.getDeliveriesByStatus(status);
}

// Pending deliveries provider
@riverpod
List<BonLivraison> pendingDeliveries(PendingDeliveriesRef ref) {
  final repository = ref.read(bonLivraisonRepositoryProvider);
  return repository.getDeliveriesByStatus('en_attente');
}

// Delivered deliveries provider
@riverpod
List<BonLivraison> deliveredDeliveries(DeliveredDeliveriesRef ref) {
  final repository = ref.read(bonLivraisonRepositoryProvider);
  return repository.getDeliveriesByStatus('livre');
}

// Non-delivered BR provider
@riverpod
class NonDeliveredBR extends _$NonDeliveredBR {
  @override
  List<BonReception> build({String? clientId}) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    final allNonDelivered = repository.getNonDeliveredBR();
    
    if (clientId == null) {
      return allNonDelivered;
    }
    
    return allNonDelivered.where((br) => br.clientId == clientId).toList();
  }

  void filterByClient(String? clientId) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    final allNonDelivered = repository.getNonDeliveredBR();
    
    if (clientId == null) {
      state = allNonDelivered;
    } else {
      state = allNonDelivered.where((br) => br.clientId == clientId).toList();
    }
  }

  void refresh({String? clientId}) {
    final repository = ref.read(bonLivraisonRepositoryProvider);
    final allNonDelivered = repository.getNonDeliveredBR();
    
    if (clientId == null) {
      state = allNonDelivered;
    } else {
      state = allNonDelivered.where((br) => br.clientId == clientId).toList();
    }
  }
}

// Remaining quantity for BR article provider
@riverpod
int remainingQuantityForBRArticle(RemainingQuantityForBRArticleRef ref, String brId, String articleReference, String treatmentId) {
  final repository = ref.read(bonLivraisonRepositoryProvider);
  return repository.getRemainingQuantityForBRArticle(brId, articleReference, treatmentId);
}

// Clients with non-delivered BR provider
@riverpod
List<String> clientsWithNonDeliveredBR(ClientsWithNonDeliveredBRRef ref) {
  final repository = ref.read(bonLivraisonRepositoryProvider);
  final clients = repository.getClientsWithNonDeliveredBR();
  return clients.map((client) => client.id).toList();
}

// Form state provider for creating/editing deliveries
@riverpod
class BonLivraisonFormState extends _$BonLivraisonFormState {
  @override
  Map<String, dynamic> build() {
    return {
      'clientId': null,
      'clientName': '',
      'dateLivraison': DateTime.now(),
      'articles': <Map<String, dynamic>>[],
      'signature': null,
      'notes': '',
      'status': 'en_attente',
    };
  }

  void updateField(String field, dynamic value) {
    state = {...state, field: value};
  }

  void loadDelivery(BonLivraison delivery) {
    state = {
      'clientId': delivery.clientId,
      'clientName': delivery.clientName,
      'dateLivraison': delivery.dateLivraison,
      'articles': delivery.articles.map((article) => {
        'articleReference': article.articleReference,
        'articleDesignation': article.articleDesignation,
        'quantityLivree': article.quantityLivree,
        'treatmentId': article.treatmentId,
        'treatmentName': article.treatmentName,
        'receptionId': article.receptionId,
        'commentaire': article.commentaire,
      }).toList(),
      'signature': delivery.signature,
      'notes': delivery.notes,
      'status': delivery.status,
    };
  }

  void addArticle(Map<String, dynamic> article) {
    final articles = List<Map<String, dynamic>>.from(state['articles']);
    articles.add(article);
    state = {...state, 'articles': articles};
  }

  void updateArticle(int index, Map<String, dynamic> article) {
    final articles = List<Map<String, dynamic>>.from(state['articles']);
    if (index >= 0 && index < articles.length) {
      articles[index] = article;
      state = {...state, 'articles': articles};
    }
  }

  void removeArticle(int index) {
    final articles = List<Map<String, dynamic>>.from(state['articles']);
    if (index >= 0 && index < articles.length) {
      articles.removeAt(index);
      state = {...state, 'articles': articles};
    }
  }

  void clear() {
    state = {
      'clientId': null,
      'clientName': '',
      'dateLivraison': DateTime.now(),
      'articles': <Map<String, dynamic>>[],
      'signature': null,
      'notes': '',
      'status': 'en_attente',
    };
  }

  bool get isValid {
    return state['clientId'] != null &&
           state['clientName'].toString().isNotEmpty &&
           (state['articles'] as List).isNotEmpty;
  }

  double get totalAmount {
    final articles = state['articles'] as List<Map<String, dynamic>>;
    return articles.fold(0.0, (sum, article) => 
        sum + (article['quantityLivree'] * article['prixUnitaire']));
  }

  int get totalQuantity {
    final articles = state['articles'] as List<Map<String, dynamic>>;
    return articles.fold(0, (sum, article) => sum + (article['quantityLivree'] as int));
  }
}
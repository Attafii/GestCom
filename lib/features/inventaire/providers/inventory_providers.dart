import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_service.dart';
import '../data/inventory_models.dart';

// Inventory service provider
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService();
});

// Current inventory filter state
final inventoryFilterProvider = StateProvider<InventoryFilter?>((ref) => null);

// Inventory items provider
final inventoryItemsProvider = Provider<List<InventoryItem>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  final filter = ref.watch(inventoryFilterProvider);
  return service.calculateInventory(filter: filter);
});

// Filtered inventory items provider with search
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredInventoryItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return items;
  }
  
  return items.where((item) {
    final query = searchQuery.toLowerCase();
    return item.clientName.toLowerCase().contains(query) ||
           item.articleReference.toLowerCase().contains(query) ||
           item.articleDesignation.toLowerCase().contains(query) ||
           item.treatmentName.toLowerCase().contains(query);
  }).toList();
});

// Inventory statistics provider
final inventoryStatisticsProvider = Provider<InventoryStatistics>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  final filter = ref.watch(inventoryFilterProvider);
  return service.calculateStatistics(filter: filter);
});

// Stock by client summary provider
final stockByClientSummaryProvider = Provider<Map<String, Map<String, dynamic>>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getStockByClientSummary();
});

// Low stock items provider
final lowStockThresholdProvider = StateProvider<int>((ref) => 5);

final lowStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  final threshold = ref.watch(lowStockThresholdProvider);
  return service.getLowStockItems(threshold: threshold);
});

// Items without stock provider
final itemsWithoutStockProvider = Provider<List<InventoryItem>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getItemsWithoutStock();
});

// Article history provider for selected item
final selectedInventoryItemProvider = StateProvider<InventoryItem?>((ref) => null);

final articleHistoryProvider = Provider<ArticleHistory?>((ref) {
  final selectedItem = ref.watch(selectedInventoryItemProvider);
  final service = ref.watch(inventoryServiceProvider);
  
  if (selectedItem == null) return null;
  
  return service.getArticleHistory(
    selectedItem.clientId,
    selectedItem.articleReference,
    selectedItem.treatmentId,
  );
});

// Export loading state
final inventoryExportLoadingProvider = StateProvider<bool>((ref) => false);

// View mode provider (table, cards, summary)
final inventoryViewModeProvider = StateProvider<String>((ref) => 'table');

// Sort configuration
enum InventorySortField { 
  clientName, 
  articleReference, 
  treatmentName, 
  currentStock, 
  lastReceptionDate,
  lastDeliveryDate,
}

final inventorySortFieldProvider = StateProvider<InventorySortField>((ref) => InventorySortField.clientName);
final inventorySortAscendingProvider = StateProvider<bool>((ref) => true);

final sortedInventoryItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(filteredInventoryItemsProvider);
  final sortField = ref.watch(inventorySortFieldProvider);
  final ascending = ref.watch(inventorySortAscendingProvider);
  
  final sortedItems = List<InventoryItem>.from(items);
  
  sortedItems.sort((a, b) {
    int compare = 0;
    
    switch (sortField) {
      case InventorySortField.clientName:
        compare = a.clientName.compareTo(b.clientName);
        break;
      case InventorySortField.articleReference:
        compare = a.articleReference.compareTo(b.articleReference);
        break;
      case InventorySortField.treatmentName:
        compare = a.treatmentName.compareTo(b.treatmentName);
        break;
      case InventorySortField.currentStock:
        compare = a.currentStock.compareTo(b.currentStock);
        break;
      case InventorySortField.lastReceptionDate:
        if (a.lastReceptionDate == null && b.lastReceptionDate == null) {
          compare = 0;
        } else if (a.lastReceptionDate == null) {
          compare = 1;
        } else if (b.lastReceptionDate == null) {
          compare = -1;
        } else {
          compare = a.lastReceptionDate!.compareTo(b.lastReceptionDate!);
        }
        break;
      case InventorySortField.lastDeliveryDate:
        if (a.lastDeliveryDate == null && b.lastDeliveryDate == null) {
          compare = 0;
        } else if (a.lastDeliveryDate == null) {
          compare = 1;
        } else if (b.lastDeliveryDate == null) {
          compare = -1;
        } else {
          compare = a.lastDeliveryDate!.compareTo(b.lastDeliveryDate!);
        }
        break;
    }
    
    return ascending ? compare : -compare;
  });
  
  return sortedItems;
});

// Pagination
final inventoryPageSizeProvider = StateProvider<int>((ref) => 25);
final inventoryCurrentPageProvider = StateProvider<int>((ref) => 0);

final paginatedInventoryItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(sortedInventoryItemsProvider);
  final pageSize = ref.watch(inventoryPageSizeProvider);
  final currentPage = ref.watch(inventoryCurrentPageProvider);
  
  final startIndex = currentPage * pageSize;
  final endIndex = (startIndex + pageSize).clamp(0, items.length);
  
  if (startIndex >= items.length) return [];
  
  return items.sublist(startIndex, endIndex);
});

final inventoryTotalPagesProvider = Provider<int>((ref) {
  final items = ref.watch(sortedInventoryItemsProvider);
  final pageSize = ref.watch(inventoryPageSizeProvider);
  
  return (items.length / pageSize).ceil();
});

// Dashboard providers for quick stats
final totalItemsProvider = Provider<int>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  return items.length;
});

final itemsWithStockCountProvider = Provider<int>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  return items.where((item) => item.currentStock > 0).length;
});

final totalStockUnitsProvider = Provider<int>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  return items.fold<int>(0, (sum, item) => sum + item.currentStock);
});

final uniqueClientsCountProvider = Provider<int>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  final clientIds = items.map((item) => item.clientId).toSet();
  return clientIds.length;
});

final uniqueArticlesCountProvider = Provider<int>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  final articleRefs = items.map((item) => item.articleReference).toSet();
  return articleRefs.length;
});
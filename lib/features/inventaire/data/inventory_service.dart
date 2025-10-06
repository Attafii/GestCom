import 'package:hive/hive.dart';
import '../../../data/models/bon_reception_model.dart';
import '../../../data/models/bon_livraison_model.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/article_model.dart';
import '../../../data/models/treatment_model.dart';
import 'inventory_models.dart';

class InventoryService {
  // Calculate all inventory items
  List<InventoryItem> calculateInventory({InventoryFilter? filter}) {
    final receptionBox = Hive.box<BonReception>('bon_receptions');
    final livraisonBox = Hive.box<BonLivraison>('bon_livraison');
    final clientBox = Hive.box<Client>('clients');
    final articleBox = Hive.box<Article>('articles');
    final treatmentBox = Hive.box<Treatment>('treatments');

    // Get all receptions and deliveries
    final receptions = receptionBox.values.toList();
    final deliveries = livraisonBox.values.where((bl) => bl.status == 'livre').toList();

    // Build inventory map: clientId_articleRef_treatmentId -> InventoryItem
    final inventoryMap = <String, InventoryItem>{};

    // Process receptions
    for (final reception in receptions) {
      for (final articleReception in reception.articles) {
        final client = clientBox.get(reception.clientId);
        final article = articleBox.values.firstWhere(
          (a) => a.reference == articleReception.articleReference,
          orElse: () => Article(
            reference: articleReception.articleReference,
            designation: 'Article non trouvé',
            traitementPrix: {},
          ),
        );

        // Since reception doesn't have treatments, we'll use 'default' as treatment
        final treatmentId = 'default';
        final treatment = Treatment(
          name: 'Standard',
          description: 'Traitement par défaut',
          defaultPrice: 0.0,
        );

        final key = '${reception.clientId}_${articleReception.articleReference}_$treatmentId';

        if (inventoryMap.containsKey(key)) {
          final existing = inventoryMap[key]!;
          inventoryMap[key] = InventoryItem(
            clientId: existing.clientId,
            clientName: existing.clientName,
            articleReference: existing.articleReference,
            articleDesignation: existing.articleDesignation,
            treatmentId: existing.treatmentId,
            treatmentName: existing.treatmentName,
            currentStock: existing.currentStock + articleReception.quantity,
            totalReceived: existing.totalReceived + articleReception.quantity,
            totalDelivered: existing.totalDelivered,
            lastReceptionDate: reception.dateReception.isAfter(existing.lastReceptionDate ?? DateTime(1900))
                ? reception.dateReception
                : existing.lastReceptionDate,
            lastDeliveryDate: existing.lastDeliveryDate,
            receptionReferences: [...existing.receptionReferences, reception.commandeNumber],
            deliveryReferences: existing.deliveryReferences,
            commandeReferences: existing.commandeReferences,
          );
        } else {
          inventoryMap[key] = InventoryItem(
            clientId: reception.clientId,
            clientName: client?.name ?? 'Client non trouvé',
            articleReference: articleReception.articleReference,
            articleDesignation: article.designation,
            treatmentId: treatmentId,
            treatmentName: treatment.name,
            currentStock: articleReception.quantity,
            totalReceived: articleReception.quantity,
            totalDelivered: 0,
            lastReceptionDate: reception.dateReception,
            lastDeliveryDate: null,
            receptionReferences: [reception.commandeNumber],
            deliveryReferences: [],
            commandeReferences: [],
          );
        }
      }
    }

    // Process deliveries (subtract from stock)
    for (final delivery in deliveries) {
      for (final articleLivraison in delivery.articles) {
        final key = '${delivery.clientId}_${articleLivraison.articleReference}_${articleLivraison.treatmentId}';

        if (inventoryMap.containsKey(key)) {
          final existing = inventoryMap[key]!;
          inventoryMap[key] = InventoryItem(
            clientId: existing.clientId,
            clientName: existing.clientName,
            articleReference: existing.articleReference,
            articleDesignation: existing.articleDesignation,
            treatmentId: existing.treatmentId,
            treatmentName: existing.treatmentName,
            currentStock: existing.currentStock - articleLivraison.quantityLivree,
            totalReceived: existing.totalReceived,
            totalDelivered: existing.totalDelivered + articleLivraison.quantityLivree,
            lastReceptionDate: existing.lastReceptionDate,
            lastDeliveryDate: delivery.dateLivraison.isAfter(existing.lastDeliveryDate ?? DateTime(1900))
                ? delivery.dateLivraison
                : existing.lastDeliveryDate,
            receptionReferences: existing.receptionReferences,
            deliveryReferences: [...existing.deliveryReferences, delivery.blNumber],
            commandeReferences: existing.commandeReferences,
          );
        } else {
          // This shouldn't happen in normal operations (delivery without reception)
          // But we'll handle it gracefully
          final client = Hive.box<Client>('clients').get(delivery.clientId);
          final article = articleBox.values.firstWhere(
            (a) => a.reference == articleLivraison.articleReference,
            orElse: () => Article(
              reference: articleLivraison.articleReference,
              designation: 'Article non trouvé',
              traitementPrix: {},
            ),
          );
          final treatment = treatmentBox.get(articleLivraison.treatmentId);

          inventoryMap[key] = InventoryItem(
            clientId: delivery.clientId,
            clientName: client?.name ?? 'Client non trouvé',
            articleReference: articleLivraison.articleReference,
            articleDesignation: article.designation,
            treatmentId: articleLivraison.treatmentId,
            treatmentName: treatment?.name ?? 'Traitement non trouvé',
            currentStock: -articleLivraison.quantityLivree, // Negative stock
            totalReceived: 0,
            totalDelivered: articleLivraison.quantityLivree,
            lastReceptionDate: null,
            lastDeliveryDate: delivery.dateLivraison,
            receptionReferences: [],
            deliveryReferences: [delivery.blNumber],
            commandeReferences: [],
          );
        }
      }
    }

    var items = inventoryMap.values.toList();

    // Apply filters
    if (filter != null) {
      items = _applyFilter(items, filter);
    }

    // Sort by client name, then article reference, then treatment
    items.sort((a, b) {
      final clientCompare = a.clientName.compareTo(b.clientName);
      if (clientCompare != 0) return clientCompare;
      
      final articleCompare = a.articleReference.compareTo(b.articleReference);
      if (articleCompare != 0) return articleCompare;
      
      return a.treatmentName.compareTo(b.treatmentName);
    });

    return items;
  }

  // Get article history for a specific client, article, and treatment
  ArticleHistory getArticleHistory(String clientId, String articleReference, String treatmentId) {
    final receptionBox = Hive.box<BonReception>('bon_receptions');
    final livraisonBox = Hive.box<BonLivraison>('bon_livraison');
    final clientBox = Hive.box<Client>('clients');
    final articleBox = Hive.box<Article>('articles');
    final treatmentBox = Hive.box<Treatment>('treatments');

    final client = clientBox.get(clientId);
    final article = articleBox.values.firstWhere(
      (a) => a.reference == articleReference,
      orElse: () => Article(
        reference: articleReference,
        designation: 'Article non trouvé',
        traitementPrix: {},
      ),
    );
    final treatment = treatmentBox.get(treatmentId);

    final movements = <ArticleMovement>[];
    int totalReceived = 0;
    int totalDelivered = 0;

    // Get reception movements
    final receptions = receptionBox.values
        .where((br) => br.clientId == clientId)
        .toList();

    for (final reception in receptions) {
      for (final articleReception in reception.articles) {
        if (articleReception.articleReference == articleReference) {
          // For receptions, we assume 'default' treatment since it's not stored
          if (treatmentId == 'default') {
            movements.add(ArticleMovement(
              id: '${reception.id}_${articleReception.articleReference}',
              type: 'reception',
              date: reception.dateReception,
              reference: reception.commandeNumber,
              commandeReference: null, // Not stored in current model
              quantity: articleReception.quantity,
              treatmentId: 'default',
              treatmentName: 'Standard',
              unitPrice: null,
              totalAmount: null,
              status: 'reçu',
            ));
            totalReceived += articleReception.quantity;
          }
        }
      }
    }

    // Get delivery movements
    final deliveries = livraisonBox.values
        .where((bl) => bl.clientId == clientId)
        .toList();

    for (final delivery in deliveries) {
      for (final articleLivraison in delivery.articles) {
        if (articleLivraison.articleReference == articleReference &&
            articleLivraison.treatmentId == treatmentId) {
          movements.add(ArticleMovement(
            id: '${delivery.id}_${articleLivraison.articleReference}_${articleLivraison.treatmentId}',
            type: 'livraison',
            date: delivery.dateLivraison,
            reference: delivery.blNumber,
            commandeReference: null, // Not stored in current model
            quantity: articleLivraison.quantityLivree,
            treatmentId: articleLivraison.treatmentId,
            treatmentName: articleLivraison.treatmentName,
            unitPrice: 0.0, // Pricing not tracked in BL
            totalAmount: 0.0, // Pricing not tracked in BL
            status: delivery.status,
          ));
          totalDelivered += articleLivraison.quantityLivree;
        }
      }
    }

    return ArticleHistory(
      clientId: clientId,
      clientName: client?.name ?? 'Client non trouvé',
      articleReference: articleReference,
      articleDesignation: article.designation,
      treatmentId: treatmentId,
      treatmentName: treatment?.name ?? 'Traitement non trouvé',
      movements: movements,
      currentStock: totalReceived - totalDelivered,
      totalReceived: totalReceived,
      totalDelivered: totalDelivered,
    );
  }

  // Calculate inventory statistics
  InventoryStatistics calculateStatistics({InventoryFilter? filter}) {
    final items = calculateInventory(filter: filter);
    
    final clients = <String>{};
    final articles = <String>{};
    final treatments = <String>{};
    final stockByClient = <String, int>{};
    final stockByArticle = <String, int>{};
    
    int itemsWithStock = 0;
    int itemsWithoutStock = 0;
    double totalStockValue = 0.0;

    for (final item in items) {
      clients.add(item.clientId);
      articles.add(item.articleReference);
      treatments.add(item.treatmentId);
      
      if (item.currentStock > 0) {
        itemsWithStock++;
      } else {
        itemsWithoutStock++;
      }

      // Count stock by client
      stockByClient[item.clientName] = 
          (stockByClient[item.clientName] ?? 0) + item.currentStock;
      
      // Count stock by article
      stockByArticle[item.articleReference] = 
          (stockByArticle[item.articleReference] ?? 0) + item.currentStock;
    }

    return InventoryStatistics(
      totalClients: clients.length,
      totalArticles: articles.length,
      totalTreatments: treatments.length,
      totalStockItems: items.length,
      itemsWithStock: itemsWithStock,
      itemsWithoutStock: itemsWithoutStock,
      totalStockValue: totalStockValue,
      stockByClient: stockByClient,
      stockByArticle: stockByArticle,
    );
  }

  // Apply filters to inventory items
  List<InventoryItem> _applyFilter(List<InventoryItem> items, InventoryFilter filter) {
    return items.where((item) {
      // Filter by client
      if (filter.clientId != null && item.clientId != filter.clientId) {
        return false;
      }

      // Filter by article
      if (filter.articleReference != null && 
          !item.articleReference.toLowerCase().contains(filter.articleReference!.toLowerCase())) {
        return false;
      }

      // Filter by treatment
      if (filter.treatmentId != null && item.treatmentId != filter.treatmentId) {
        return false;
      }

      // Filter by stock status
      if (filter.hasStock != null) {
        if (filter.hasStock! && item.currentStock <= 0) {
          return false;
        }
        if (!filter.hasStock! && item.currentStock > 0) {
          return false;
        }
      }

      // Filter by date range (based on last reception date)
      if (filter.fromDate != null && item.lastReceptionDate != null) {
        if (item.lastReceptionDate!.isBefore(filter.fromDate!)) {
          return false;
        }
      }

      if (filter.toDate != null && item.lastReceptionDate != null) {
        if (item.lastReceptionDate!.isAfter(filter.toDate!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Get stock by client summary
  Map<String, Map<String, dynamic>> getStockByClientSummary() {
    final items = calculateInventory();
    final summary = <String, Map<String, dynamic>>{};

    for (final item in items) {
      if (!summary.containsKey(item.clientId)) {
        summary[item.clientId] = {
          'clientName': item.clientName,
          'totalItems': 0,
          'itemsWithStock': 0,
          'totalStock': 0,
        };
      }

      summary[item.clientId]!['totalItems'] += 1;
      if (item.currentStock > 0) {
        summary[item.clientId]!['itemsWithStock'] += 1;
      }
      summary[item.clientId]!['totalStock'] += item.currentStock;
    }

    return summary;
  }

  // Get low stock items (stock <= threshold)
  List<InventoryItem> getLowStockItems({int threshold = 5}) {
    final items = calculateInventory();
    return items.where((item) => 
        item.currentStock > 0 && item.currentStock <= threshold).toList();
  }

  // Get items without stock
  List<InventoryItem> getItemsWithoutStock() {
    final items = calculateInventory();
    return items.where((item) => item.currentStock <= 0).toList();
  }
}
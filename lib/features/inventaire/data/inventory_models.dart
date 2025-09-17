// Inventory data models for stock tracking and history

class InventoryItem {
  final String clientId;
  final String clientName;
  final String articleReference;
  final String articleDesignation;
  final String treatmentId;
  final String treatmentName;
  final int currentStock;
  final int totalReceived;
  final int totalDelivered;
  final DateTime? lastReceptionDate;
  final DateTime? lastDeliveryDate;
  final List<String> receptionReferences;
  final List<String> deliveryReferences;
  final List<String> commandeReferences;

  InventoryItem({
    required this.clientId,
    required this.clientName,
    required this.articleReference,
    required this.articleDesignation,
    required this.treatmentId,
    required this.treatmentName,
    required this.currentStock,
    required this.totalReceived,
    required this.totalDelivered,
    this.lastReceptionDate,
    this.lastDeliveryDate,
    required this.receptionReferences,
    required this.deliveryReferences,
    required this.commandeReferences,
  });

  @override
  String toString() {
    return 'InventoryItem(client: $clientName, article: $articleReference, '
           'treatment: $treatmentName, stock: $currentStock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryItem &&
           other.clientId == clientId &&
           other.articleReference == articleReference &&
           other.treatmentId == treatmentId;
  }

  @override
  int get hashCode {
    return Object.hash(clientId, articleReference, treatmentId);
  }
}

class ArticleMovement {
  final String id;
  final String type; // 'reception' or 'livraison'
  final DateTime date;
  final String reference; // BL number or BR number
  final String? commandeReference;
  final int quantity;
  final String treatmentId;
  final String treatmentName;
  final double? unitPrice;
  final double? totalAmount;
  final String status;

  ArticleMovement({
    required this.id,
    required this.type,
    required this.date,
    required this.reference,
    this.commandeReference,
    required this.quantity,
    required this.treatmentId,
    required this.treatmentName,
    this.unitPrice,
    this.totalAmount,
    required this.status,
  });

  bool get isReception => type == 'reception';
  bool get isDelivery => type == 'livraison';

  @override
  String toString() {
    return 'ArticleMovement(type: $type, date: $date, reference: $reference, '
           'quantity: $quantity, treatment: $treatmentName)';
  }
}

class ArticleHistory {
  final String clientId;
  final String clientName;
  final String articleReference;
  final String articleDesignation;
  final String treatmentId;
  final String treatmentName;
  final List<ArticleMovement> movements;
  final int currentStock;
  final int totalReceived;
  final int totalDelivered;

  ArticleHistory({
    required this.clientId,
    required this.clientName,
    required this.articleReference,
    required this.articleDesignation,
    required this.treatmentId,
    required this.treatmentName,
    required this.movements,
    required this.currentStock,
    required this.totalReceived,
    required this.totalDelivered,
  });

  List<ArticleMovement> get receptions => 
      movements.where((m) => m.isReception).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<ArticleMovement> get deliveries => 
      movements.where((m) => m.isDelivery).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<ArticleMovement> get chronologicalMovements => 
      List<ArticleMovement>.from(movements)
        ..sort((a, b) => a.date.compareTo(b.date));

  @override
  String toString() {
    return 'ArticleHistory(client: $clientName, article: $articleReference, '
           'movements: ${movements.length}, currentStock: $currentStock)';
  }
}

class InventoryFilter {
  final String? clientId;
  final String? articleReference;
  final String? treatmentId;
  final bool? hasStock;
  final DateTime? fromDate;
  final DateTime? toDate;

  const InventoryFilter({
    this.clientId,
    this.articleReference,
    this.treatmentId,
    this.hasStock,
    this.fromDate,
    this.toDate,
  });

  InventoryFilter copyWith({
    String? clientId,
    String? articleReference,
    String? treatmentId,
    bool? hasStock,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return InventoryFilter(
      clientId: clientId ?? this.clientId,
      articleReference: articleReference ?? this.articleReference,
      treatmentId: treatmentId ?? this.treatmentId,
      hasStock: hasStock ?? this.hasStock,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  bool get isEmpty {
    return clientId == null &&
           articleReference == null &&
           treatmentId == null &&
           hasStock == null &&
           fromDate == null &&
           toDate == null;
  }

  @override
  String toString() {
    return 'InventoryFilter(client: $clientId, article: $articleReference, '
           'treatment: $treatmentId, hasStock: $hasStock)';
  }
}

class InventoryStatistics {
  final int totalClients;
  final int totalArticles;
  final int totalTreatments;
  final int totalStockItems;
  final int itemsWithStock;
  final int itemsWithoutStock;
  final double totalStockValue;
  final Map<String, int> stockByClient;
  final Map<String, int> stockByArticle;

  InventoryStatistics({
    required this.totalClients,
    required this.totalArticles,
    required this.totalTreatments,
    required this.totalStockItems,
    required this.itemsWithStock,
    required this.itemsWithoutStock,
    required this.totalStockValue,
    required this.stockByClient,
    required this.stockByArticle,
  });

  @override
  String toString() {
    return 'InventoryStatistics(clients: $totalClients, articles: $totalArticles, '
           'stockItems: $totalStockItems, value: $totalStockValue)';
  }
}
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'article_livraison_model.dart';

part 'bon_livraison_model.g.dart';

@HiveType(typeId: 7)
class BonLivraison extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String blNumber;
  
  @HiveField(2)
  final String clientId;
  
  @HiveField(3)
  final String clientName;
  
  @HiveField(4)
  final DateTime dateLivraison;
  
  @HiveField(5)
  final List<ArticleLivraison> articles;
  
  @HiveField(6)
  final double montantTotal;
  
  @HiveField(7)
  final String? signature;
  
  @HiveField(8)
  final String? notes;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;
  
  @HiveField(11)
  final String status; // 'en_attente', 'livre', 'annule'
  
  @HiveField(12)
  final String? receptionId; // Reference to BonReception if applicable

  BonLivraison({
    String? id,
    required this.blNumber,
    required this.clientId,
    required this.clientName,
    required this.dateLivraison,
    required this.articles,
    this.signature,
    this.notes,
    this.status = 'en_attente',
    this.receptionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        montantTotal = articles.fold(0.0, (sum, article) => sum + article.montantTotal),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Copy with method
  BonLivraison copyWith({
    String? blNumber,
    String? clientId,
    String? clientName,
    DateTime? dateLivraison,
    List<ArticleLivraison>? articles,
    String? signature,
    String? notes,
    String? status,
    String? receptionId,
  }) {
    return BonLivraison(
      id: id,
      blNumber: blNumber ?? this.blNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      dateLivraison: dateLivraison ?? this.dateLivraison,
      articles: articles ?? this.articles,
      signature: signature ?? this.signature,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      receptionId: receptionId ?? this.receptionId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Helper getters
  int get totalQuantity => articles.fold(0, (sum, article) => sum + article.quantityLivree);
  
  int get totalPieces => totalQuantity; // Alias for totalQuantity
  
  int get totalArticles => articles.length;
  
  bool get isDelivered => status == 'livre';
  
  bool get isPending => status == 'en_attente';
  
  bool get isCancelled => status == 'annule';
  
  String get formattedBlNumber => blNumber;
  
  String get statusLabel {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'livre':
        return 'Livré';
      case 'annule':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  // Get articles by treatment
  List<ArticleLivraison> getArticlesByTreatment(String treatmentId) {
    return articles.where((article) => article.treatmentId == treatmentId).toList();
  }

  // Check if has article
  bool hasArticle(String articleReference) {
    return articles.any((article) => article.articleReference == articleReference);
  }

  // Check if has treatment
  bool hasTreatment(String treatmentId) {
    return articles.any((article) => article.treatmentId == treatmentId);
  }

  // Get total quantity for specific article
  int getQuantityForArticle(String articleReference) {
    return articles
        .where((article) => article.articleReference == articleReference)
        .fold(0, (sum, article) => sum + article.quantityLivree);
  }

  // Get total amount for specific treatment
  double getAmountForTreatment(String treatmentId) {
    return articles
        .where((article) => article.treatmentId == treatmentId)
        .fold(0.0, (sum, article) => sum + article.montantTotal);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blNumber': blNumber,
      'clientId': clientId,
      'clientName': clientName,
      'dateLivraison': dateLivraison.toIso8601String(),
      'articles': articles.map((article) => article.toJson()).toList(),
      'montantTotal': montantTotal,
      'signature': signature,
      'notes': notes,
      'status': status,
      'receptionId': receptionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BonLivraison.fromJson(Map<String, dynamic> json) {
    return BonLivraison(
      id: json['id'],
      blNumber: json['blNumber'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      dateLivraison: DateTime.parse(json['dateLivraison']),
      articles: (json['articles'] as List)
          .map((articleJson) => ArticleLivraison.fromJson(articleJson))
          .toList(),
      signature: json['signature'],
      notes: json['notes'],
      status: json['status'] ?? 'en_attente',
      receptionId: json['receptionId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'BonLivraison(id: $id, blNumber: $blNumber, client: $clientName, articles: ${articles.length}, montant: $montantTotal DT)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BonLivraison && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
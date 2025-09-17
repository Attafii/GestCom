import 'package:hive/hive.dart';

part 'article_livraison_model.g.dart';

@HiveType(typeId: 6)
class ArticleLivraison extends HiveObject {
  @HiveField(0)
  final String articleReference;
  
  @HiveField(1)
  final String articleDesignation;
  
  @HiveField(2)
  final int quantityLivree;
  
  @HiveField(3)
  final String treatmentId;
  
  @HiveField(4)
  final String treatmentName;
  
  @HiveField(5)
  final double prixUnitaire;
  
  @HiveField(6)
  final double montantTotal;

  ArticleLivraison({
    required this.articleReference,
    required this.articleDesignation,
    required this.quantityLivree,
    required this.treatmentId,
    required this.treatmentName,
    required this.prixUnitaire,
  }) : montantTotal = quantityLivree * prixUnitaire;

  // Copy with method
  ArticleLivraison copyWith({
    String? articleReference,
    String? articleDesignation,
    int? quantityLivree,
    String? treatmentId,
    String? treatmentName,
    double? prixUnitaire,
  }) {
    return ArticleLivraison(
      articleReference: articleReference ?? this.articleReference,
      articleDesignation: articleDesignation ?? this.articleDesignation,
      quantityLivree: quantityLivree ?? this.quantityLivree,
      treatmentId: treatmentId ?? this.treatmentId,
      treatmentName: treatmentName ?? this.treatmentName,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'articleReference': articleReference,
      'articleDesignation': articleDesignation,
      'quantityLivree': quantityLivree,
      'treatmentId': treatmentId,
      'treatmentName': treatmentName,
      'prixUnitaire': prixUnitaire,
      'montantTotal': montantTotal,
    };
  }

  factory ArticleLivraison.fromJson(Map<String, dynamic> json) {
    return ArticleLivraison(
      articleReference: json['articleReference'],
      articleDesignation: json['articleDesignation'],
      quantityLivree: json['quantityLivree'],
      treatmentId: json['treatmentId'],
      treatmentName: json['treatmentName'],
      prixUnitaire: json['prixUnitaire'],
    );
  }

  @override
  String toString() {
    return 'ArticleLivraison(ref: $articleReference, qty: $quantityLivree, treatment: $treatmentName, prix: $prixUnitaire DT)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleLivraison &&
           other.articleReference == articleReference &&
           other.treatmentId == treatmentId;
  }

  @override
  int get hashCode => articleReference.hashCode ^ treatmentId.hashCode;
}
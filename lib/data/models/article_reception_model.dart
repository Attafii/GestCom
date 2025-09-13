import 'package:hive/hive.dart';

part 'article_reception_model.g.dart';

@HiveType(typeId: 3)
class ArticleReception extends HiveObject {
  @HiveField(0)
  final String articleReference;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double unitPrice;

  @HiveField(3)
  final String articleDesignation;

  ArticleReception({
    required this.articleReference,
    required this.quantity,
    required this.unitPrice,
    required this.articleDesignation,
  });

  // Calculate total price for this article line
  double get totalPrice => quantity * unitPrice;

  // Copy with method for updating
  ArticleReception copyWith({
    String? articleReference,
    int? quantity,
    double? unitPrice,
    String? articleDesignation,
  }) {
    return ArticleReception(
      articleReference: articleReference ?? this.articleReference,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      articleDesignation: articleDesignation ?? this.articleDesignation,
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleReception &&
        other.articleReference == articleReference &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.articleDesignation == articleDesignation;
  }

  @override
  int get hashCode {
    return articleReference.hashCode ^
        quantity.hashCode ^
        unitPrice.hashCode ^
        articleDesignation.hashCode;
  }

  // To JSON for export
  Map<String, dynamic> toJson() {
    return {
      'articleReference': articleReference,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'articleDesignation': articleDesignation,
      'totalPrice': totalPrice,
    };
  }

  // From JSON for import
  factory ArticleReception.fromJson(Map<String, dynamic> json) {
    return ArticleReception(
      articleReference: json['articleReference'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      articleDesignation: json['articleDesignation'] as String,
    );
  }

  @override
  String toString() {
    return 'ArticleReception(ref: $articleReference, qty: $quantity, price: $unitPrice)';
  }
}
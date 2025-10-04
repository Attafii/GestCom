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

  @HiveField(4)
  final String? treatmentId;

  @HiveField(5)
  final String? treatmentName;

  ArticleReception({
    required this.articleReference,
    required this.quantity,
    required this.unitPrice,
    required this.articleDesignation,
    this.treatmentId,
    this.treatmentName,
  });

  // Calculate total price for this article line
  double get totalPrice => quantity * unitPrice;

  // Copy with method for updating
  ArticleReception copyWith({
    String? articleReference,
    int? quantity,
    double? unitPrice,
    String? articleDesignation,
    String? treatmentId,
    String? treatmentName,
  }) {
    return ArticleReception(
      articleReference: articleReference ?? this.articleReference,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      articleDesignation: articleDesignation ?? this.articleDesignation,
      treatmentId: treatmentId ?? this.treatmentId,
      treatmentName: treatmentName ?? this.treatmentName,
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
        other.articleDesignation == articleDesignation &&
        other.treatmentId == treatmentId &&
        other.treatmentName == treatmentName;
  }

  @override
  int get hashCode {
    return articleReference.hashCode ^
        quantity.hashCode ^
        unitPrice.hashCode ^
        articleDesignation.hashCode ^
        treatmentId.hashCode ^
        treatmentName.hashCode;
  }

  // To JSON for export
  Map<String, dynamic> toJson() {
    return {
      'articleReference': articleReference,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'articleDesignation': articleDesignation,
      'treatmentId': treatmentId,
      'treatmentName': treatmentName,
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
      treatmentId: json['treatmentId'] as String?,
      treatmentName: json['treatmentName'] as String?,
    );
  }

  @override
  String toString() {
    return 'ArticleReception(ref: $articleReference, qty: $quantity, price: $unitPrice)';
  }
}
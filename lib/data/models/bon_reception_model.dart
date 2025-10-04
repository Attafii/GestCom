import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'article_reception_model.dart';

part 'bon_reception_model.g.dart';

@HiveType(typeId: 4)
class BonReception extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clientId;

  @HiveField(2)
  final DateTime dateReception;

  @HiveField(3)
  final String commandeNumber;

  @HiveField(4)
  final List<ArticleReception> articles;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final String numeroBR; // Sequential BR number (BR001, BR002, etc.)

  BonReception({
    String? id,
    required this.clientId,
    required this.dateReception,
    required this.commandeNumber,
    required this.articles,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
    required this.numeroBR,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Calculate total amount for all articles
  double get totalAmount {
    return articles.fold(0.0, (sum, article) => sum + article.totalPrice);
  }

  // Calculate total quantity of all articles
  int get totalQuantity {
    return articles.fold(0, (sum, article) => sum + article.quantity);
  }

  // Get number of different articles
  int get articlesCount => articles.length;

  // Check if reception is valid (has at least one article)
  bool get isValid => articles.isNotEmpty;

  // Copy with method for updating
  BonReception copyWith({
    String? id,
    String? clientId,
    DateTime? dateReception,
    String? commandeNumber,
    List<ArticleReception>? articles,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? numeroBR,
  }) {
    return BonReception(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      dateReception: dateReception ?? this.dateReception,
      commandeNumber: commandeNumber ?? this.commandeNumber,
      articles: articles ?? List.from(this.articles),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
      numeroBR: numeroBR ?? this.numeroBR,
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BonReception && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // To JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'dateReception': dateReception.toIso8601String(),
      'commandeNumber': commandeNumber,
      'articles': articles.map((article) => article.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'numeroBR': numeroBR,
      'totalAmount': totalAmount,
      'totalQuantity': totalQuantity,
      'articlesCount': articlesCount,
    };
  }

  // From JSON for import
  factory BonReception.fromJson(Map<String, dynamic> json) {
    return BonReception(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      dateReception: DateTime.parse(json['dateReception'] as String),
      commandeNumber: json['commandeNumber'] as String,
      articles: (json['articles'] as List)
          .map((article) => ArticleReception.fromJson(article as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      numeroBR: json['numeroBR'] as String? ?? 'BR000', // Fallback for existing data
    );
  }

  @override
  String toString() {
    return 'BonReception(id: $id, numeroBR: $numeroBR, commande: $commandeNumber, client: $clientId, articles: ${articles.length})';
  }
}
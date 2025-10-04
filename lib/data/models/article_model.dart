import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'article_model.g.dart';

@HiveType(typeId: 1)
class Article extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String reference;
  
  @HiveField(2)
  final String designation;
  
  @HiveField(3)
  final Map<String, double> traitementPrix;
  
  @HiveField(4)
  final bool isActive;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime updatedAt;

  /// Optional client ID - links article to a specific client
  @HiveField(7)
  final String? clientId;

  Article({
    String? id,
    required this.reference,
    required this.designation,
    required this.traitementPrix,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.clientId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for updates
  Article copyWith({
    String? reference,
    String? designation,
    Map<String, double>? traitementPrix,
    bool? isActive,
    String? clientId,
  }) {
    return Article(
      id: id,
      reference: reference ?? this.reference,
      designation: designation ?? this.designation,
      traitementPrix: traitementPrix ?? Map.from(this.traitementPrix),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      clientId: clientId ?? this.clientId,
    );
  }

  // Get price for a specific treatment
  double? getPriceForTreatment(String treatmentId) {
    return traitementPrix[treatmentId];
  }

  // Set price for a specific treatment
  Article setPriceForTreatment(String treatmentId, double price) {
    final newPrices = Map<String, double>.from(traitementPrix);
    newPrices[treatmentId] = price;
    return copyWith(traitementPrix: newPrices);
  }

  // Remove treatment price
  Article removeTreatmentPrice(String treatmentId) {
    final newPrices = Map<String, double>.from(traitementPrix);
    newPrices.remove(treatmentId);
    return copyWith(traitementPrix: newPrices);
  }

  // Get all treatment IDs
  List<String> get treatmentIds => traitementPrix.keys.toList();

  // Check if article has price for treatment
  bool hasTreatment(String treatmentId) {
    return traitementPrix.containsKey(treatmentId);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'designation': designation,
      'traitementPrix': traitementPrix,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'clientId': clientId,
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      reference: json['reference'],
      designation: json['designation'],
      traitementPrix: Map<String, double>.from(json['traitementPrix']),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      clientId: json['clientId'],
    );
  }

  @override
  String toString() {
    return 'Article(id: $id, reference: $reference, designation: $designation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
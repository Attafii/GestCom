import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'treatment_model.g.dart';

@HiveType(typeId: 2)
class Treatment extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final double defaultPrice;
  
  @HiveField(4)
  final bool isActive;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime updatedAt;

  Treatment({
    String? id,
    required this.name,
    required this.description,
    required this.defaultPrice,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for updates
  Treatment copyWith({
    String? name,
    String? description,
    double? defaultPrice,
    bool? isActive,
  }) {
    return Treatment(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'defaultPrice': defaultPrice,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      defaultPrice: json['defaultPrice'].toDouble(),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'Treatment(id: $id, name: $name, defaultPrice: $defaultPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Treatment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
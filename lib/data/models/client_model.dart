import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'client_model.g.dart';

@HiveType(typeId: 0)
class Client extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String address;
  
  @HiveField(3)
  final String matriculeFiscal;
  
  @HiveField(4)
  final String phone;
  
  @HiveField(5)
  final String email;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;

  Client({
    String? id,
    required this.name,
    required this.address,
    required this.matriculeFiscal,
    required this.phone,
    required this.email,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for updates
  Client copyWith({
    String? name,
    String? address,
    String? matriculeFiscal,
    String? phone,
    String? email,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      matriculeFiscal: matriculeFiscal ?? this.matriculeFiscal,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // JSON serialization (for backup/restore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'matriculeFiscal': matriculeFiscal,
      'phone': phone,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      matriculeFiscal: json['matriculeFiscal'],
      phone: json['phone'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'Client(id: $id, name: $name, matriculeFiscal: $matriculeFiscal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
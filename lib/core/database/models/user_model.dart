import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_model.g.dart';

@HiveType(typeId: 10)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String firstName;

  @HiveField(4)
  final String lastName;

  @HiveField(5)
  final String? phoneNumber;

  @HiveField(6)
  final String? profileImagePath;

  @HiveField(7)
  final UserRole role;

  @HiveField(8)
  final UserStatus status;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final DateTime? lastLoginAt;

  @HiveField(12)
  final Map<String, dynamic> preferences;

  @HiveField(13)
  final bool isEmailVerified;

  @HiveField(14)
  final String? department;

  @HiveField(15)
  final String? position;

  User({
    String? id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImagePath,
    this.role = UserRole.user,
    this.status = UserStatus.active,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastLoginAt,
    Map<String, dynamic>? preferences,
    this.isEmailVerified = false,
    this.department,
    this.position,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        preferences = preferences ?? {};

  // Computed properties
  String get fullName => '$firstName $lastName';
  
  String get displayName => username.isNotEmpty ? username : fullName;
  
  bool get isActive => status == UserStatus.active;
  
  bool get isAdmin => role == UserRole.admin;
  
  bool get isModerator => role == UserRole.moderator || role == UserRole.admin;

  // Copy with method
  User copyWith({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImagePath,
    UserRole? role,
    UserStatus? status,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
    String? department,
    String? position,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? Map.from(this.preferences),
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      department: department ?? this.department,
      position: position ?? this.position,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImagePath': profileImagePath,
      'role': role.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
      'department': department,
      'position': position,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      profileImagePath: json['profileImagePath'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.user,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => UserStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      isEmailVerified: json['isEmailVerified'] ?? false,
      department: json['department'],
      position: json['position'],
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 11)
enum UserRole {
  @HiveField(0)
  user,
  
  @HiveField(1)
  moderator,
  
  @HiveField(2)
  admin,
  
  @HiveField(3)
  superAdmin,
}

@HiveType(typeId: 12)
enum UserStatus {
  @HiveField(0)
  active,
  
  @HiveField(1)
  inactive,
  
  @HiveField(2)
  suspended,
  
  @HiveField(3)
  deleted,
  
  @HiveField(4)
  pending,
}
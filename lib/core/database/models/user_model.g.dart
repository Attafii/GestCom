// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 10;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String?,
      username: fields[1] as String,
      email: fields[2] as String,
      firstName: fields[3] as String,
      lastName: fields[4] as String,
      phoneNumber: fields[5] as String?,
      profileImagePath: fields[6] as String?,
      role: fields[7] as UserRole,
      status: fields[8] as UserStatus,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
      lastLoginAt: fields[11] as DateTime?,
      preferences: (fields[12] as Map?)?.cast<String, dynamic>(),
      isEmailVerified: fields[13] as bool,
      department: fields[14] as String?,
      position: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.firstName)
      ..writeByte(4)
      ..write(obj.lastName)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.profileImagePath)
      ..writeByte(7)
      ..write(obj.role)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.lastLoginAt)
      ..writeByte(12)
      ..write(obj.preferences)
      ..writeByte(13)
      ..write(obj.isEmailVerified)
      ..writeByte(14)
      ..write(obj.department)
      ..writeByte(15)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 11;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.user;
      case 1:
        return UserRole.moderator;
      case 2:
        return UserRole.admin;
      case 3:
        return UserRole.superAdmin;
      default:
        return UserRole.user;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.user:
        writer.writeByte(0);
        break;
      case UserRole.moderator:
        writer.writeByte(1);
        break;
      case UserRole.admin:
        writer.writeByte(2);
        break;
      case UserRole.superAdmin:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 12;

  @override
  UserStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserStatus.active;
      case 1:
        return UserStatus.inactive;
      case 2:
        return UserStatus.suspended;
      case 3:
        return UserStatus.deleted;
      case 4:
        return UserStatus.pending;
      default:
        return UserStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    switch (obj) {
      case UserStatus.active:
        writer.writeByte(0);
        break;
      case UserStatus.inactive:
        writer.writeByte(1);
        break;
      case UserStatus.suspended:
        writer.writeByte(2);
        break;
      case UserStatus.deleted:
        writer.writeByte(3);
        break;
      case UserStatus.pending:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

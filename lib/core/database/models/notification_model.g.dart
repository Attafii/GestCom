// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationAdapter extends TypeAdapter<Notification> {
  @override
  final int typeId = 19;

  @override
  Notification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notification(
      id: fields[0] as String?,
      title: fields[1] as String,
      message: fields[2] as String,
      recipientUserId: fields[3] as String,
      senderUserId: fields[4] as String?,
      type: fields[5] as NotificationType,
      priority: fields[6] as NotificationPriority,
      status: fields[7] as NotificationStatus,
      createdAt: fields[8] as DateTime?,
      readAt: fields[9] as DateTime?,
      scheduledFor: fields[10] as DateTime?,
      expiresAt: fields[11] as DateTime?,
      relatedEntityId: fields[12] as String?,
      relatedEntityType: fields[13] as String?,
      actionData: (fields[14] as Map?)?.cast<String, dynamic>(),
      actions: (fields[15] as List?)?.cast<NotificationAction>(),
      iconPath: fields[16] as String?,
      imageUrl: fields[17] as String?,
      isSystemNotification: fields[18] as bool,
      metadata: (fields[19] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Notification obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.recipientUserId)
      ..writeByte(4)
      ..write(obj.senderUserId)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.readAt)
      ..writeByte(10)
      ..write(obj.scheduledFor)
      ..writeByte(11)
      ..write(obj.expiresAt)
      ..writeByte(12)
      ..write(obj.relatedEntityId)
      ..writeByte(13)
      ..write(obj.relatedEntityType)
      ..writeByte(14)
      ..write(obj.actionData)
      ..writeByte(15)
      ..write(obj.actions)
      ..writeByte(16)
      ..write(obj.iconPath)
      ..writeByte(17)
      ..write(obj.imageUrl)
      ..writeByte(18)
      ..write(obj.isSystemNotification)
      ..writeByte(19)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationActionAdapter extends TypeAdapter<NotificationAction> {
  @override
  final int typeId = 23;

  @override
  NotificationAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationAction(
      id: fields[0] as String?,
      label: fields[1] as String,
      actionType: fields[2] as String,
      actionData: (fields[3] as Map?)?.cast<String, dynamic>(),
      iconName: fields[4] as String?,
      isPrimary: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationAction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.actionType)
      ..writeByte(3)
      ..write(obj.actionData)
      ..writeByte(4)
      ..write(obj.iconName)
      ..writeByte(5)
      ..write(obj.isPrimary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationChannelAdapter extends TypeAdapter<NotificationChannel> {
  @override
  final int typeId = 24;

  @override
  NotificationChannel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationChannel(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String,
      defaultPriority: fields[3] as NotificationPriority,
      isEnabled: fields[4] as bool,
      soundEnabled: fields[5] as bool,
      vibrationEnabled: fields[6] as bool,
      soundPath: fields[7] as String?,
      settings: (fields[8] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationChannel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.defaultPriority)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.soundEnabled)
      ..writeByte(6)
      ..write(obj.vibrationEnabled)
      ..writeByte(7)
      ..write(obj.soundPath)
      ..writeByte(8)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 20;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.info;
      case 1:
        return NotificationType.warning;
      case 2:
        return NotificationType.error;
      case 3:
        return NotificationType.success;
      case 4:
        return NotificationType.taskAssigned;
      case 5:
        return NotificationType.taskCompleted;
      case 6:
        return NotificationType.taskOverdue;
      case 7:
        return NotificationType.userMention;
      case 8:
        return NotificationType.systemUpdate;
      case 9:
        return NotificationType.reminder;
      default:
        return NotificationType.info;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.info:
        writer.writeByte(0);
        break;
      case NotificationType.warning:
        writer.writeByte(1);
        break;
      case NotificationType.error:
        writer.writeByte(2);
        break;
      case NotificationType.success:
        writer.writeByte(3);
        break;
      case NotificationType.taskAssigned:
        writer.writeByte(4);
        break;
      case NotificationType.taskCompleted:
        writer.writeByte(5);
        break;
      case NotificationType.taskOverdue:
        writer.writeByte(6);
        break;
      case NotificationType.userMention:
        writer.writeByte(7);
        break;
      case NotificationType.systemUpdate:
        writer.writeByte(8);
        break;
      case NotificationType.reminder:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationPriorityAdapter extends TypeAdapter<NotificationPriority> {
  @override
  final int typeId = 21;

  @override
  NotificationPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationPriority.low;
      case 1:
        return NotificationPriority.normal;
      case 2:
        return NotificationPriority.high;
      case 3:
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationPriority obj) {
    switch (obj) {
      case NotificationPriority.low:
        writer.writeByte(0);
        break;
      case NotificationPriority.normal:
        writer.writeByte(1);
        break;
      case NotificationPriority.high:
        writer.writeByte(2);
        break;
      case NotificationPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationStatusAdapter extends TypeAdapter<NotificationStatus> {
  @override
  final int typeId = 22;

  @override
  NotificationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationStatus.unread;
      case 1:
        return NotificationStatus.read;
      case 2:
        return NotificationStatus.dismissed;
      case 3:
        return NotificationStatus.archived;
      default:
        return NotificationStatus.unread;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationStatus obj) {
    switch (obj) {
      case NotificationStatus.unread:
        writer.writeByte(0);
        break;
      case NotificationStatus.read:
        writer.writeByte(1);
        break;
      case NotificationStatus.dismissed:
        writer.writeByte(2);
        break;
      case NotificationStatus.archived:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

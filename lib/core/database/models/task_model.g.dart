// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 13;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      assignedUserId: fields[3] as String,
      createdByUserId: fields[4] as String?,
      status: fields[5] as TaskStatus,
      priority: fields[6] as TaskPriority,
      category: fields[7] as TaskCategory,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
      dueDate: fields[10] as DateTime?,
      startDate: fields[11] as DateTime?,
      completedAt: fields[12] as DateTime?,
      tags: (fields[13] as List?)?.cast<String>(),
      attachments: (fields[14] as List?)?.cast<TaskAttachment>(),
      comments: (fields[15] as List?)?.cast<TaskComment>(),
      estimatedHours: fields[16] as double?,
      actualHours: fields[17] as double?,
      progressPercentage: fields[18] as int,
      parentTaskId: fields[19] as String?,
      subtaskIds: (fields[20] as List?)?.cast<String>(),
      metadata: (fields[21] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.assignedUserId)
      ..writeByte(4)
      ..write(obj.createdByUserId)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.dueDate)
      ..writeByte(11)
      ..write(obj.startDate)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.attachments)
      ..writeByte(15)
      ..write(obj.comments)
      ..writeByte(16)
      ..write(obj.estimatedHours)
      ..writeByte(17)
      ..write(obj.actualHours)
      ..writeByte(18)
      ..write(obj.progressPercentage)
      ..writeByte(19)
      ..write(obj.parentTaskId)
      ..writeByte(20)
      ..write(obj.subtaskIds)
      ..writeByte(21)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskAttachmentAdapter extends TypeAdapter<TaskAttachment> {
  @override
  final int typeId = 17;

  @override
  TaskAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskAttachment(
      id: fields[0] as String?,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      mimeType: fields[3] as String,
      fileSize: fields[4] as int,
      uploadedByUserId: fields[5] as String,
      uploadedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskAttachment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.mimeType)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.uploadedByUserId)
      ..writeByte(6)
      ..write(obj.uploadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCommentAdapter extends TypeAdapter<TaskComment> {
  @override
  final int typeId = 18;

  @override
  TaskComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskComment(
      id: fields[0] as String?,
      content: fields[1] as String,
      authorUserId: fields[2] as String,
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
      parentCommentId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskComment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.authorUserId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.parentCommentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 14;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.todo;
      case 1:
        return TaskStatus.inProgress;
      case 2:
        return TaskStatus.completed;
      case 3:
        return TaskStatus.cancelled;
      case 4:
        return TaskStatus.onHold;
      case 5:
        return TaskStatus.review;
      default:
        return TaskStatus.todo;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.todo:
        writer.writeByte(0);
        break;
      case TaskStatus.inProgress:
        writer.writeByte(1);
        break;
      case TaskStatus.completed:
        writer.writeByte(2);
        break;
      case TaskStatus.cancelled:
        writer.writeByte(3);
        break;
      case TaskStatus.onHold:
        writer.writeByte(4);
        break;
      case TaskStatus.review:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 15;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      case 3:
        return TaskPriority.urgent;
      case 4:
        return TaskPriority.critical;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
      case TaskPriority.urgent:
        writer.writeByte(3);
        break;
      case TaskPriority.critical:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 16;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.general;
      case 1:
        return TaskCategory.development;
      case 2:
        return TaskCategory.design;
      case 3:
        return TaskCategory.testing;
      case 4:
        return TaskCategory.documentation;
      case 5:
        return TaskCategory.maintenance;
      case 6:
        return TaskCategory.meeting;
      case 7:
        return TaskCategory.research;
      default:
        return TaskCategory.general;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    switch (obj) {
      case TaskCategory.general:
        writer.writeByte(0);
        break;
      case TaskCategory.development:
        writer.writeByte(1);
        break;
      case TaskCategory.design:
        writer.writeByte(2);
        break;
      case TaskCategory.testing:
        writer.writeByte(3);
        break;
      case TaskCategory.documentation:
        writer.writeByte(4);
        break;
      case TaskCategory.maintenance:
        writer.writeByte(5);
        break;
      case TaskCategory.meeting:
        writer.writeByte(6);
        break;
      case TaskCategory.research:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

@HiveType(typeId: 13)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String assignedUserId;

  @HiveField(4)
  final String? createdByUserId;

  @HiveField(5)
  final TaskStatus status;

  @HiveField(6)
  final TaskPriority priority;

  @HiveField(7)
  final TaskCategory category;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final DateTime? dueDate;

  @HiveField(11)
  final DateTime? startDate;

  @HiveField(12)
  final DateTime? completedAt;

  @HiveField(13)
  final List<String> tags;

  @HiveField(14)
  final List<TaskAttachment> attachments;

  @HiveField(15)
  final List<TaskComment> comments;

  @HiveField(16)
  final double? estimatedHours;

  @HiveField(17)
  final double? actualHours;

  @HiveField(18)
  final int progressPercentage;

  @HiveField(19)
  final String? parentTaskId;

  @HiveField(20)
  final List<String> subtaskIds;

  @HiveField(21)
  final Map<String, dynamic> metadata;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.assignedUserId,
    this.createdByUserId,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.general,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dueDate,
    this.startDate,
    this.completedAt,
    List<String>? tags,
    List<TaskAttachment>? attachments,
    List<TaskComment>? comments,
    this.estimatedHours,
    this.actualHours,
    this.progressPercentage = 0,
    this.parentTaskId,
    List<String>? subtaskIds,
    Map<String, dynamic>? metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [],
        attachments = attachments ?? [],
        comments = comments ?? [],
        subtaskIds = subtaskIds ?? [],
        metadata = metadata ?? {};

  // Computed properties
  bool get isCompleted => status == TaskStatus.completed;
  
  bool get isOverdue => dueDate != null && 
      dueDate!.isBefore(DateTime.now()) && 
      !isCompleted;
  
  bool get isInProgress => status == TaskStatus.inProgress;
  
  bool get hasSubtasks => subtaskIds.isNotEmpty;
  
  bool get isSubtask => parentTaskId != null;
  
  Duration? get timeUntilDue => dueDate?.difference(DateTime.now());
  
  Duration? get timeSpentWorking => completedAt?.difference(startDate ?? createdAt);

  // Copy with method
  Task copyWith({
    String? title,
    String? description,
    String? assignedUserId,
    String? createdByUserId,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedAt,
    List<String>? tags,
    List<TaskAttachment>? attachments,
    List<TaskComment>? comments,
    double? estimatedHours,
    double? actualHours,
    int? progressPercentage,
    String? parentTaskId,
    List<String>? subtaskIds,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? List.from(this.tags),
      attachments: attachments ?? List.from(this.attachments),
      comments: comments ?? List.from(this.comments),
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      subtaskIds: subtaskIds ?? List.from(this.subtaskIds),
      metadata: metadata ?? Map.from(this.metadata),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedUserId': assignedUserId,
      'createdByUserId': createdByUserId,
      'status': status.toString(),
      'priority': priority.toString(),
      'category': category.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'progressPercentage': progressPercentage,
      'parentTaskId': parentTaskId,
      'subtaskIds': subtaskIds,
      'metadata': metadata,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      assignedUserId: json['assignedUserId'],
      createdByUserId: json['createdByUserId'],
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => TaskCategory.general,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      attachments: (json['attachments'] as List?)
          ?.map((a) => TaskAttachment.fromJson(a))
          .toList() ?? [],
      comments: (json['comments'] as List?)
          ?.map((c) => TaskComment.fromJson(c))
          .toList() ?? [],
      estimatedHours: json['estimatedHours']?.toDouble(),
      actualHours: json['actualHours']?.toDouble(),
      progressPercentage: json['progressPercentage'] ?? 0,
      parentTaskId: json['parentTaskId'],
      subtaskIds: List<String>.from(json['subtaskIds'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, priority: $priority, assignedTo: $assignedUserId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 14)
enum TaskStatus {
  @HiveField(0)
  todo,
  
  @HiveField(1)
  inProgress,
  
  @HiveField(2)
  completed,
  
  @HiveField(3)
  cancelled,
  
  @HiveField(4)
  onHold,
  
  @HiveField(5)
  review,
}

@HiveType(typeId: 15)
enum TaskPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
  
  @HiveField(4)
  critical,
}

@HiveType(typeId: 16)
enum TaskCategory {
  @HiveField(0)
  general,
  
  @HiveField(1)
  development,
  
  @HiveField(2)
  design,
  
  @HiveField(3)
  testing,
  
  @HiveField(4)
  documentation,
  
  @HiveField(5)
  maintenance,
  
  @HiveField(6)
  meeting,
  
  @HiveField(7)
  research,
}

@HiveType(typeId: 17)
class TaskAttachment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fileName;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final String mimeType;

  @HiveField(4)
  final int fileSize;

  @HiveField(5)
  final String uploadedByUserId;

  @HiveField(6)
  final DateTime uploadedAt;

  TaskAttachment({
    String? id,
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
    required this.uploadedByUserId,
    DateTime? uploadedAt,
  })  : id = id ?? const Uuid().v4(),
        uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'uploadedByUserId': uploadedByUserId,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      mimeType: json['mimeType'],
      fileSize: json['fileSize'],
      uploadedByUserId: json['uploadedByUserId'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

@HiveType(typeId: 18)
class TaskComment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String authorUserId;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  @HiveField(5)
  final String? parentCommentId;

  TaskComment({
    String? id,
    required this.content,
    required this.authorUserId,
    DateTime? createdAt,
    this.updatedAt,
    this.parentCommentId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  TaskComment copyWith({
    String? content,
    DateTime? updatedAt,
  }) {
    return TaskComment(
      id: id,
      content: content ?? this.content,
      authorUserId: authorUserId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      parentCommentId: parentCommentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorUserId': authorUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'parentCommentId': parentCommentId,
    };
  }

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'],
      content: json['content'],
      authorUserId: json['authorUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      parentCommentId: json['parentCommentId'],
    );
  }
}
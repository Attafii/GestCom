import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 19)
class Notification extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final String recipientUserId;

  @HiveField(4)
  final String? senderUserId;

  @HiveField(5)
  final NotificationType type;

  @HiveField(6)
  final NotificationPriority priority;

  @HiveField(7)
  final NotificationStatus status;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? readAt;

  @HiveField(10)
  final DateTime? scheduledFor;

  @HiveField(11)
  final DateTime? expiresAt;

  @HiveField(12)
  final String? relatedEntityId;

  @HiveField(13)
  final String? relatedEntityType;

  @HiveField(14)
  final Map<String, dynamic> actionData;

  @HiveField(15)
  final List<NotificationAction> actions;

  @HiveField(16)
  final String? iconPath;

  @HiveField(17)
  final String? imageUrl;

  @HiveField(18)
  final bool isSystemNotification;

  @HiveField(19)
  final Map<String, dynamic> metadata;

  Notification({
    String? id,
    required this.title,
    required this.message,
    required this.recipientUserId,
    this.senderUserId,
    this.type = NotificationType.info,
    this.priority = NotificationPriority.normal,
    this.status = NotificationStatus.unread,
    DateTime? createdAt,
    this.readAt,
    this.scheduledFor,
    this.expiresAt,
    this.relatedEntityId,
    this.relatedEntityType,
    Map<String, dynamic>? actionData,
    List<NotificationAction>? actions,
    this.iconPath,
    this.imageUrl,
    this.isSystemNotification = false,
    Map<String, dynamic>? metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        actionData = actionData ?? {},
        actions = actions ?? [],
        metadata = metadata ?? {};

  // Computed properties
  bool get isRead => status == NotificationStatus.read;
  
  bool get isUnread => status == NotificationStatus.unread;
  
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  
  bool get isScheduled => scheduledFor != null && scheduledFor!.isAfter(DateTime.now());
  
  bool get shouldShow => !isExpired && 
      (scheduledFor == null || scheduledFor!.isBefore(DateTime.now())) &&
      status != NotificationStatus.dismissed;
  
  bool get hasActions => actions.isNotEmpty;
  
  Duration? get timeSinceCreated => DateTime.now().difference(createdAt);
  
  Duration? get timeUntilExpiry => expiresAt?.difference(DateTime.now());

  // Copy with method
  Notification copyWith({
    String? title,
    String? message,
    String? recipientUserId,
    String? senderUserId,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? readAt,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    String? relatedEntityId,
    String? relatedEntityType,
    Map<String, dynamic>? actionData,
    List<NotificationAction>? actions,
    String? iconPath,
    String? imageUrl,
    bool? isSystemNotification,
    Map<String, dynamic>? metadata,
  }) {
    return Notification(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      senderUserId: senderUserId ?? this.senderUserId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      expiresAt: expiresAt ?? this.expiresAt,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      actionData: actionData ?? Map.from(this.actionData),
      actions: actions ?? List.from(this.actions),
      iconPath: iconPath ?? this.iconPath,
      imageUrl: imageUrl ?? this.imageUrl,
      isSystemNotification: isSystemNotification ?? this.isSystemNotification,
      metadata: metadata ?? Map.from(this.metadata),
    );
  }

  // Mark as read
  Notification markAsRead() {
    return copyWith(
      status: NotificationStatus.read,
      readAt: DateTime.now(),
    );
  }

  // Mark as dismissed
  Notification dismiss() {
    return copyWith(status: NotificationStatus.dismissed);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'recipientUserId': recipientUserId,
      'senderUserId': senderUserId,
      'type': type.toString(),
      'priority': priority.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'actionData': actionData,
      'actions': actions.map((a) => a.toJson()).toList(),
      'iconPath': iconPath,
      'imageUrl': imageUrl,
      'isSystemNotification': isSystemNotification,
      'metadata': metadata,
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      recipientUserId: json['recipientUserId'],
      senderUserId: json['senderUserId'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.info,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => NotificationStatus.unread,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      scheduledFor: json['scheduledFor'] != null ? DateTime.parse(json['scheduledFor']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      relatedEntityId: json['relatedEntityId'],
      relatedEntityType: json['relatedEntityType'],
      actionData: Map<String, dynamic>.from(json['actionData'] ?? {}),
      actions: (json['actions'] as List?)
          ?.map((a) => NotificationAction.fromJson(a))
          .toList() ?? [],
      iconPath: json['iconPath'],
      imageUrl: json['imageUrl'],
      isSystemNotification: json['isSystemNotification'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, type: $type, status: $status, recipient: $recipientUserId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 20)
enum NotificationType {
  @HiveField(0)
  info,
  
  @HiveField(1)
  warning,
  
  @HiveField(2)
  error,
  
  @HiveField(3)
  success,
  
  @HiveField(4)
  taskAssigned,
  
  @HiveField(5)
  taskCompleted,
  
  @HiveField(6)
  taskOverdue,
  
  @HiveField(7)
  userMention,
  
  @HiveField(8)
  systemUpdate,
  
  @HiveField(9)
  reminder,
}

@HiveType(typeId: 21)
enum NotificationPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  normal,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
}

@HiveType(typeId: 22)
enum NotificationStatus {
  @HiveField(0)
  unread,
  
  @HiveField(1)
  read,
  
  @HiveField(2)
  dismissed,
  
  @HiveField(3)
  archived,
}

@HiveType(typeId: 23)
class NotificationAction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String label;

  @HiveField(2)
  final String actionType;

  @HiveField(3)
  final Map<String, dynamic> actionData;

  @HiveField(4)
  final String? iconName;

  @HiveField(5)
  final bool isPrimary;

  NotificationAction({
    String? id,
    required this.label,
    required this.actionType,
    Map<String, dynamic>? actionData,
    this.iconName,
    this.isPrimary = false,
  })  : id = id ?? const Uuid().v4(),
        actionData = actionData ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'actionType': actionType,
      'actionData': actionData,
      'iconName': iconName,
      'isPrimary': isPrimary,
    };
  }

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'],
      label: json['label'],
      actionType: json['actionType'],
      actionData: Map<String, dynamic>.from(json['actionData'] ?? {}),
      iconName: json['iconName'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

@HiveType(typeId: 24)
class NotificationChannel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final NotificationPriority defaultPriority;

  @HiveField(4)
  final bool isEnabled;

  @HiveField(5)
  final bool soundEnabled;

  @HiveField(6)
  final bool vibrationEnabled;

  @HiveField(7)
  final String? soundPath;

  @HiveField(8)
  final Map<String, dynamic> settings;

  NotificationChannel({
    String? id,
    required this.name,
    required this.description,
    this.defaultPriority = NotificationPriority.normal,
    this.isEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.soundPath,
    Map<String, dynamic>? settings,
  })  : id = id ?? const Uuid().v4(),
        settings = settings ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'defaultPriority': defaultPriority.toString(),
      'isEnabled': isEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'soundPath': soundPath,
      'settings': settings,
    };
  }

  factory NotificationChannel.fromJson(Map<String, dynamic> json) {
    return NotificationChannel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      defaultPriority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['defaultPriority'],
        orElse: () => NotificationPriority.normal,
      ),
      isEnabled: json['isEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      soundPath: json['soundPath'],
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }
}
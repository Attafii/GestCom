import '../models/notification_model.dart';
import '../services/hive_service.dart';

/// Repository for Notification entity operations with business logic
class NotificationRepository {
  /// Create a new notification
  Future<String> createNotification({
    required String title,
    required String message,
    required String recipientUserId,
    String? senderUserId,
    NotificationType type = NotificationType.info,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? actionData,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    String? relatedEntityId,
    String? relatedEntityType,
    Map<String, dynamic>? metadata,
  }) async {
    // Validate user exists
    final user = HiveService.getUser(recipientUserId);
    if (user == null) {
      throw Exception('Recipient user not found');
    }

    // Validate scheduled time is in future
    if (scheduledFor != null && scheduledFor.isBefore(DateTime.now())) {
      throw Exception('Scheduled time must be in the future');
    }

    // Validate expiry time is after scheduled time
    if (scheduledFor != null && expiresAt != null && expiresAt.isBefore(scheduledFor)) {
      throw Exception('Expiry time must be after scheduled time');
    }

    final notification = Notification(
      title: title,
      message: message,
      recipientUserId: recipientUserId,
      senderUserId: senderUserId,
      type: type,
      priority: priority,
      actionData: actionData,
      scheduledFor: scheduledFor,
      expiresAt: expiresAt,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
      metadata: metadata,
    );

    return await HiveService.createNotification(notification);
  }

  /// Get notification by ID
  Notification? getNotificationById(String id) {
    return HiveService.getNotification(id);
  }

  /// Get all notifications with optional filtering
  List<Notification> getAllNotifications({
    String? recipientUserId,
    NotificationType? type,
    NotificationStatus? status,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool includeExpired = false,
  }) {
    var notifications = HiveService.getAllNotifications();

    if (recipientUserId != null) {
      notifications = notifications.where((n) => n.recipientUserId == recipientUserId).toList();
    }

    if (type != null) {
      notifications = notifications.where((n) => n.type == type).toList();
    }

    if (status != null) {
      notifications = notifications.where((n) => n.status == status).toList();
    }

    if (priority != null) {
      notifications = notifications.where((n) => n.priority == priority).toList();
    }

    if (isRead != null) {
      notifications = notifications.where((n) => n.isRead == isRead).toList();
    }

    if (createdAfter != null) {
      notifications = notifications.where((n) => n.createdAt.isAfter(createdAfter)).toList();
    }

    if (createdBefore != null) {
      notifications = notifications.where((n) => n.createdAt.isBefore(createdBefore)).toList();
    }

    if (!includeExpired) {
      notifications = notifications.where((n) => !n.isExpired).toList();
    }

    return notifications;
  }

  /// Update notification
  Future<bool> updateNotification(String id, {
    String? title,
    String? message,
    NotificationType? type,
    NotificationStatus? status,
    NotificationPriority? priority,
    Map<String, dynamic>? actionData,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    bool? isRead,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) async {
    final notification = HiveService.getNotification(id);
    if (notification == null) {
      throw Exception('Notification not found');
    }

    // Validate scheduled time is in future (if changing)
    if (scheduledFor != null && scheduledFor.isBefore(DateTime.now())) {
      throw Exception('Scheduled time must be in the future');
    }

    // Auto-set readAt when marking as read
    DateTime? finalReadAt = readAt;
    NotificationStatus? finalStatus = status;
    if (isRead == true && !notification.isRead) {
      finalReadAt = DateTime.now();
      finalStatus = NotificationStatus.read;
    } else if (isRead == false) {
      finalReadAt = null;
      finalStatus = NotificationStatus.unread;
    }

    final updatedNotification = notification.copyWith(
      title: title,
      message: message,
      type: type,
      status: finalStatus,
      priority: priority,
      actionData: actionData,
      scheduledFor: scheduledFor,
      expiresAt: expiresAt,
      readAt: finalReadAt,
      metadata: metadata,
    );

    return await HiveService.updateNotification(updatedNotification);
  }

  /// Delete notification
  Future<bool> deleteNotification(String id) async {
    final notification = HiveService.getNotification(id);
    if (notification == null) {
      throw Exception('Notification not found');
    }

    return await HiveService.deleteNotification(id);
  }

  /// Get notifications for user
  List<Notification> getNotificationsForUser(String userId, {
    bool unreadOnly = false,
    int? limit,
    bool includeExpired = false,
  }) {
    var notifications = HiveService.getAllNotifications()
        .where((n) => n.recipientUserId == userId)
        .toList();

    if (unreadOnly) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }

    if (!includeExpired) {
      notifications = notifications.where((n) => !n.isExpired).toList();
    }

    // Sort by creation date (newest first)
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null && limit > 0) {
      notifications = notifications.take(limit).toList();
    }

    return notifications;
  }

  /// Mark notification as read
  Future<bool> markAsRead(String id) async {
    return await updateNotification(
      id,
      status: NotificationStatus.read,
      readAt: DateTime.now(),
    );
  }

  /// Mark all notifications as read for user
  Future<List<String>> markAllAsReadForUser(String userId) async {
    final unreadNotifications = getNotificationsForUser(userId, unreadOnly: true);
    final updatedIds = <String>[];

    for (final notification in unreadNotifications) {
      final success = await markAsRead(notification.id);
      if (success) {
        updatedIds.add(notification.id);
      }
    }

    return updatedIds;
  }

  /// Mark notification as dismissed
  Future<bool> dismiss(String id) async {
    return await updateNotification(
      id,
      status: NotificationStatus.dismissed,
    );
  }

  /// Send notification (change status to sent)
  Future<bool> sendNotification(String id) async {
    final notification = HiveService.getNotification(id);
    if (notification == null) {
      throw Exception('Notification not found');
    }

    if (notification.status != NotificationStatus.unread) {
      throw Exception('Only unread notifications can be sent');
    }

    return await updateNotification(
      id,
      status: NotificationStatus.read,
    );
  }

  /// Get pending notifications ready to send
  List<Notification> getPendingNotifications() {
    final now = DateTime.now();
    return HiveService.getAllNotifications()
        .where((n) => 
            n.status == NotificationStatus.unread &&
            (n.scheduledFor == null || n.scheduledFor!.isBefore(now)) &&
            !n.isExpired
        )
        .toList();
  }

  /// Get unread notifications count for user
  int getUnreadCount(String userId) {
    return getNotificationsForUser(userId, unreadOnly: true).length;
  }

  /// Get notification statistics
  Map<String, dynamic> getNotificationStatistics({String? userId}) {
    List<Notification> notifications = HiveService.getAllNotifications();
    
    if (userId != null) {
      notifications = notifications.where((n) => n.recipientUserId == userId).toList();
    }

    final stats = <String, dynamic>{
      'total': notifications.length,
      'unread': notifications.where((n) => !n.isRead).length,
      'read': notifications.where((n) => n.isRead).length,
      'dismissed': notifications.where((n) => n.status == NotificationStatus.dismissed).length,
      'expired': notifications.where((n) => n.isExpired).length,
      'byType': <String, int>{},
      'byPriority': <String, int>{},
    };

    // Count by type
    for (final type in NotificationType.values) {
      stats['byType'][type.toString()] = notifications.where((n) => n.type == type).length;
    }

    // Count by priority
    for (final priority in NotificationPriority.values) {
      stats['byPriority'][priority.toString()] = notifications.where((n) => n.priority == priority).length;
    }

    // Calculate read rate
    if (notifications.isNotEmpty) {
      stats['readRate'] = (stats['read'] / notifications.length * 100).round();
    } else {
      stats['readRate'] = 0;
    }

    return stats;
  }

  /// Search notifications
  List<Notification> searchNotifications(String query, {String? userId}) {
    final notifications = userId != null 
        ? getNotificationsForUser(userId)
        : HiveService.getAllNotifications();

    final lowercaseQuery = query.toLowerCase();

    return notifications.where((notification) =>
        notification.title.toLowerCase().contains(lowercaseQuery) ||
        notification.message.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Clean up expired notifications
  Future<List<String>> cleanupExpiredNotifications({String? userId}) async {
    List<Notification> notifications = userId != null
        ? getNotificationsForUser(userId, includeExpired: true)
        : HiveService.getAllNotifications();

    final expiredNotifications = notifications.where((n) => n.isExpired).toList();
    final deletedIds = <String>[];

    for (final notification in expiredNotifications) {
      final success = await deleteNotification(notification.id);
      if (success) {
        deletedIds.add(notification.id);
      }
    }

    return deletedIds;
  }

  /// Schedule notification for later delivery
  Future<String> scheduleNotification({
    required String title,
    required String message,
    required String recipientUserId,
    required DateTime scheduledFor,
    NotificationType type = NotificationType.info,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? actionData,
    DateTime? expiresAt,
    String? relatedEntityId,
    String? relatedEntityType,
    Map<String, dynamic>? metadata,
  }) async {
    if (scheduledFor.isBefore(DateTime.now())) {
      throw Exception('Scheduled time must be in the future');
    }

    return await createNotification(
      title: title,
      message: message,
      recipientUserId: recipientUserId,
      type: type,
      priority: priority,
      actionData: actionData,
      scheduledFor: scheduledFor,
      expiresAt: expiresAt,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
      metadata: metadata,
    );
  }

  /// Get recent notifications for user (last 30 days)
  List<Notification> getRecentNotifications(String userId, {int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return getNotificationsForUser(userId, includeExpired: true)
        .where((n) => n.createdAt.isAfter(cutoffDate))
        .toList();
  }

  /// Bulk delete notifications by IDs
  Future<List<String>> bulkDeleteNotifications(List<String> ids) async {
    final deletedIds = <String>[];

    for (final id in ids) {
      try {
        final success = await deleteNotification(id);
        if (success) {
          deletedIds.add(id);
        }
      } catch (e) {
        // Continue with other notifications even if one fails
        continue;
      }
    }

    return deletedIds;
  }
}
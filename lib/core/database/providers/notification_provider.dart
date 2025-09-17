import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

/// Provider for NotificationRepository instance
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Provider for all notifications
final notificationsProvider = FutureProvider<List<Notification>>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getAllNotifications();
});

/// Provider for a specific notification by ID
final notificationProvider = FutureProvider.family<Notification?, String>((ref, notificationId) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getNotificationById(notificationId);
});

/// Provider for notifications for a specific user
final userNotificationsProvider = FutureProvider.family<List<Notification>, String>((ref, userId) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getNotificationsForUser(userId);
});

/// Provider for unread notifications for a specific user
final unreadNotificationsProvider = FutureProvider.family<List<Notification>, String>((ref, userId) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getNotificationsForUser(userId, unreadOnly: true);
});

/// Provider for unread notifications count
final unreadNotificationsCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getUnreadCount(userId);
});

/// Provider for pending notifications
final pendingNotificationsProvider = FutureProvider<List<Notification>>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getPendingNotifications();
});

/// Provider for recent notifications
final recentNotificationsProvider = FutureProvider.family<List<Notification>, String>((ref, userId) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getRecentNotifications(userId);
});

/// Provider for notification statistics
final notificationStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, userId) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getNotificationStatistics(userId: userId);
});

/// Provider for notification search results
final notificationSearchProvider = StateNotifierProvider<NotificationSearchNotifier, AsyncValue<List<Notification>>>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return NotificationSearchNotifier(repository);
});

/// State notifier for notification search functionality
class NotificationSearchNotifier extends StateNotifier<AsyncValue<List<Notification>>> {
  final NotificationRepository _repository;
  String _lastQuery = '';
  String? _lastUserId;

  NotificationSearchNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> searchNotifications(String query, {String? userId}) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      _lastQuery = '';
      _lastUserId = null;
      return;
    }

    if (query == _lastQuery && userId == _lastUserId) return;

    state = const AsyncValue.loading();
    _lastQuery = query;
    _lastUserId = userId;

    try {
      final results = _repository.searchNotifications(query, userId: userId);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
    _lastQuery = '';
    _lastUserId = null;
  }
}

/// Provider for notification operations (create, update, delete)
final notificationOperationsProvider = StateNotifierProvider<NotificationOperationsNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return NotificationOperationsNotifier(repository, ref);
});

/// State notifier for notification operations
class NotificationOperationsNotifier extends StateNotifier<AsyncValue<String?>> {
  final NotificationRepository _repository;
  final Ref _ref;

  NotificationOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<String?> createNotification({
    required String title,
    required String message,
    required String userId,
    NotificationType type = NotificationType.info,
    String? actionUrl,
    Map<String, dynamic>? actionData,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    NotificationChannel channel = NotificationChannel.inApp,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();

    try {
      final notificationId = await _repository.createNotification(
        title: title,
        message: message,
        userId: userId,
        type: type,
        actionUrl: actionUrl,
        actionData: actionData,
        scheduledFor: scheduledFor,
        expiresAt: expiresAt,
        channel: channel,
        metadata: metadata,
      );

      state = AsyncValue.data(notificationId);
      
      // Refresh related providers
      _refreshNotificationProviders(userId);

      return notificationId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<String?> scheduleNotification({
    required String title,
    required String message,
    required String userId,
    required DateTime scheduledFor,
    NotificationType type = NotificationType.info,
    String? actionUrl,
    Map<String, dynamic>? actionData,
    DateTime? expiresAt,
    NotificationChannel channel = NotificationChannel.inApp,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();

    try {
      final notificationId = await _repository.scheduleNotification(
        title: title,
        message: message,
        userId: userId,
        scheduledFor: scheduledFor,
        type: type,
        actionUrl: actionUrl,
        actionData: actionData,
        expiresAt: expiresAt,
        channel: channel,
        metadata: metadata,
      );

      state = AsyncValue.data(notificationId);
      
      // Refresh related providers
      _refreshNotificationProviders(userId);

      return notificationId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<bool> updateNotification(String id, {
    String? title,
    String? message,
    NotificationType? type,
    NotificationStatus? status,
    String? actionUrl,
    Map<String, dynamic>? actionData,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    NotificationChannel? channel,
    bool? isRead,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();

    try {
      final notification = _repository.getNotificationById(id);
      final userId = notification?.userId;

      final success = await _repository.updateNotification(
        id,
        title: title,
        message: message,
        type: type,
        status: status,
        actionUrl: actionUrl,
        actionData: actionData,
        scheduledFor: scheduledFor,
        expiresAt: expiresAt,
        channel: channel,
        isRead: isRead,
        readAt: readAt,
        metadata: metadata,
      );

      state = AsyncValue.data(success ? id : null);

      if (success && userId != null) {
        // Refresh related providers
        _refreshNotificationProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteNotification(String id) async {
    state = const AsyncValue.loading();

    try {
      final notification = _repository.getNotificationById(id);
      final userId = notification?.userId;

      final success = await _repository.deleteNotification(id);
      state = AsyncValue.data(success ? id : null);

      if (success && userId != null) {
        // Refresh related providers
        _refreshNotificationProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> markAsRead(String id) async {
    return await updateNotification(id, isRead: true, readAt: DateTime.now());
  }

  Future<bool> dismiss(String id) async {
    return await updateNotification(id, status: NotificationStatus.dismissed);
  }

  Future<bool> sendNotification(String id) async {
    return await updateNotification(id, status: NotificationStatus.sent);
  }

  Future<List<String>> markAllAsReadForUser(String userId) async {
    state = const AsyncValue.loading();

    try {
      final updatedIds = await _repository.markAllAsReadForUser(userId);
      state = AsyncValue.data(userId);

      if (updatedIds.isNotEmpty) {
        // Refresh related providers
        _refreshNotificationProviders(userId);
      }

      return updatedIds;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  Future<List<String>> cleanupExpiredNotifications({String? userId}) async {
    state = const AsyncValue.loading();

    try {
      final deletedIds = await _repository.cleanupExpiredNotifications(userId: userId);
      state = AsyncValue.data(userId ?? 'cleanup');

      if (deletedIds.isNotEmpty) {
        // Refresh all notification providers
        _ref.invalidate(notificationsProvider);
        _ref.invalidate(pendingNotificationsProvider);
        _ref.invalidate(notificationStatisticsProvider(null));
        
        if (userId != null) {
          _refreshNotificationProviders(userId);
        }
      }

      return deletedIds;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  Future<List<String>> bulkDeleteNotifications(List<String> ids) async {
    state = const AsyncValue.loading();

    try {
      final deletedIds = await _repository.bulkDeleteNotifications(ids);
      state = AsyncValue.data('bulk_delete');

      if (deletedIds.isNotEmpty) {
        // Refresh all notification providers since we don't know all affected users
        _ref.invalidate(notificationsProvider);
        _ref.invalidate(pendingNotificationsProvider);
        _ref.invalidate(notificationStatisticsProvider(null));
      }

      return deletedIds;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  void _refreshNotificationProviders(String userId) {
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(userNotificationsProvider(userId));
    _ref.invalidate(unreadNotificationsProvider(userId));
    _ref.invalidate(unreadNotificationsCountProvider(userId));
    _ref.invalidate(recentNotificationsProvider(userId));
    _ref.invalidate(pendingNotificationsProvider);
    _ref.invalidate(notificationStatisticsProvider(userId));
    _ref.invalidate(notificationStatisticsProvider(null));
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for filtered notifications
final filteredNotificationsProvider = StateNotifierProvider<NotificationFilterNotifier, NotificationFilter>((ref) {
  return NotificationFilterNotifier();
});

/// Notification filter state
class NotificationFilter {
  final String? userId;
  final NotificationType? type;
  final NotificationStatus? status;
  final NotificationChannel? channel;
  final bool? isRead;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final bool includeExpired;

  const NotificationFilter({
    this.userId,
    this.type,
    this.status,
    this.channel,
    this.isRead,
    this.createdAfter,
    this.createdBefore,
    this.includeExpired = false,
  });

  NotificationFilter copyWith({
    String? userId,
    NotificationType? type,
    NotificationStatus? status,
    NotificationChannel? channel,
    bool? isRead,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool? includeExpired,
  }) {
    return NotificationFilter(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      channel: channel ?? this.channel,
      isRead: isRead ?? this.isRead,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      includeExpired: includeExpired ?? this.includeExpired,
    );
  }
}

/// State notifier for notification filtering
class NotificationFilterNotifier extends StateNotifier<NotificationFilter> {
  NotificationFilterNotifier() : super(const NotificationFilter());

  void updateFilter({
    String? userId,
    NotificationType? type,
    NotificationStatus? status,
    NotificationChannel? channel,
    bool? isRead,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool? includeExpired,
  }) {
    state = state.copyWith(
      userId: userId,
      type: type,
      status: status,
      channel: channel,
      isRead: isRead,
      createdAfter: createdAfter,
      createdBefore: createdBefore,
      includeExpired: includeExpired,
    );
  }

  void clearFilter() {
    state = const NotificationFilter();
  }
}

/// Provider for filtered notifications results
final filteredNotificationsResultsProvider = FutureProvider<List<Notification>>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  final filter = ref.watch(filteredNotificationsProvider);

  return repository.getAllNotifications(
    recipientUserId: filter.userId,
    type: filter.type,
    status: filter.status,
    isRead: filter.isRead,
    createdAfter: filter.createdAfter,
    createdBefore: filter.createdBefore,
    includeExpired: filter.includeExpired,
  );
});
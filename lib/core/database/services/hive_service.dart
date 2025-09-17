import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/notification_model.dart';
import '../models/settings_model.dart';

/// Comprehensive Hive database service with initialization, adapter registration,
/// and CRUD operations for all entities.
class HiveService {
  static const String _usersBoxName = 'users';
  static const String _tasksBoxName = 'tasks';
  static const String _notificationsBoxName = 'notifications';
  static const String _settingsBoxName = 'settings';

  // Box references
  static Box<User>? _usersBox;
  static Box<Task>? _tasksBox;
  static Box<Notification>? _notificationsBox;
  static Box<Settings>? _settingsBox;

  // Getters for boxes with null checks
  static Box<User> get usersBox {
    if (_usersBox == null || !_usersBox!.isOpen) {
      throw StateError('Users box is not initialized or has been closed');
    }
    return _usersBox!;
  }

  static Box<Task> get tasksBox {
    if (_tasksBox == null || !_tasksBox!.isOpen) {
      throw StateError('Tasks box is not initialized or has been closed');
    }
    return _tasksBox!;
  }

  static Box<Notification> get notificationsBox {
    if (_notificationsBox == null || !_notificationsBox!.isOpen) {
      throw StateError('Notifications box is not initialized or has been closed');
    }
    return _notificationsBox!;
  }

  static Box<Settings> get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw StateError('Settings box is not initialized or has been closed');
    }
    return _settingsBox!;
  }

  /// Initialize Hive database with all adapters and boxes
  static Future<void> initialize() async {
    try {
      // Initialize Hive directory
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final hiveDir = Directory('${directory.path}/hive_database');
        if (!await hiveDir.exists()) {
          await hiveDir.create(recursive: true);
        }
        Hive.init(hiveDir.path);
      }

      // Register all adapters
      await _registerAdapters();

      // Open all boxes
      await _openBoxes();

      debugPrint('HiveService: Database initialized successfully');
    } catch (e) {
      debugPrint('HiveService: Failed to initialize database: $e');
      rethrow;
    }
  }

  /// Register all Hive type adapters
  static Future<void> _registerAdapters() async {
    // User related adapters
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(UserStatusAdapter());
    }

    // Task related adapters
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(TaskCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(TaskAttachmentAdapter());
    }
    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(TaskCommentAdapter());
    }

    // Notification related adapters
    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(NotificationAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(NotificationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(NotificationPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(NotificationStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(NotificationActionAdapter());
    }

    // Settings related adapters
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(SettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(25)) {
      Hive.registerAdapter(ThemeSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(ThemeModeAdapter());
    }
    if (!Hive.isAdapterRegistered(27)) {
      Hive.registerAdapter(NotificationSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(28)) {
      Hive.registerAdapter(NotificationFrequencyAdapter());
    }
    if (!Hive.isAdapterRegistered(29)) {
      Hive.registerAdapter(LanguageSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(PrivacySettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(31)) {
      Hive.registerAdapter(DataRetentionPeriodAdapter());
    }
    if (!Hive.isAdapterRegistered(32)) {
      Hive.registerAdapter(GeneralSettingsAdapter());
    }
  }

  /// Open all required Hive boxes
  static Future<void> _openBoxes() async {
    _usersBox = await Hive.openBox<User>(_usersBoxName);
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _notificationsBox = await Hive.openBox<Notification>(_notificationsBoxName);
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);
  }

  /// Close all boxes and clean up resources
  static Future<void> dispose() async {
    try {
      await _usersBox?.close();
      await _tasksBox?.close();
      await _notificationsBox?.close();
      await _settingsBox?.close();
      await Hive.close();
      debugPrint('HiveService: Database disposed successfully');
    } catch (e) {
      debugPrint('HiveService: Error disposing database: $e');
    }
  }

  /// Clear all data from the database
  static Future<void> clearAllData() async {
    try {
      await usersBox.clear();
      await tasksBox.clear();
      await notificationsBox.clear();
      await settingsBox.clear();
      debugPrint('HiveService: All data cleared successfully');
    } catch (e) {
      debugPrint('HiveService: Error clearing data: $e');
      rethrow;
    }
  }

  /// Backup database to a file
  static Future<String> backupDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = '${backupDir.path}/backup_$timestamp.json';

      final backup = {
        'timestamp': timestamp,
        'version': '1.0.0',
        'users': usersBox.values.map((u) => u.toJson()).toList(),
        'tasks': tasksBox.values.map((t) => t.toJson()).toList(),
        'notifications': notificationsBox.values.map((n) => n.toJson()).toList(),
        'settings': settingsBox.values.map((s) => s.toJson()).toList(),
      };

      final file = File(backupPath);
      await file.writeAsString(backup.toString());

      debugPrint('HiveService: Database backed up to $backupPath');
      return backupPath;
    } catch (e) {
      debugPrint('HiveService: Error backing up database: $e');
      rethrow;
    }
  }

  /// Get database statistics
  static Map<String, dynamic> getDatabaseStats() {
    return {
      'users': usersBox.length,
      'tasks': tasksBox.length,
      'notifications': notificationsBox.length,
      'settings': settingsBox.length,
      'totalRecords': usersBox.length + tasksBox.length + notificationsBox.length + settingsBox.length,
      'isInitialized': _usersBox != null && _tasksBox != null && _notificationsBox != null && _settingsBox != null,
    };
  }

  // ============================================================================
  // USER CRUD OPERATIONS
  // ============================================================================

  /// Create a new user
  static Future<String> createUser(User user) async {
    try {
      await usersBox.put(user.id, user);
      debugPrint('HiveService: User created with ID: ${user.id}');
      return user.id;
    } catch (e) {
      debugPrint('HiveService: Error creating user: $e');
      rethrow;
    }
  }

  /// Get user by ID
  static User? getUser(String id) {
    try {
      return usersBox.get(id);
    } catch (e) {
      debugPrint('HiveService: Error getting user: $e');
      return null;
    }
  }

  /// Get all users
  static List<User> getAllUsers() {
    try {
      return usersBox.values.toList();
    } catch (e) {
      debugPrint('HiveService: Error getting all users: $e');
      return [];
    }
  }

  /// Update user
  static Future<bool> updateUser(User user) async {
    try {
      await usersBox.put(user.id, user);
      debugPrint('HiveService: User updated with ID: ${user.id}');
      return true;
    } catch (e) {
      debugPrint('HiveService: Error updating user: $e');
      return false;
    }
  }

  /// Delete user
  static Future<bool> deleteUser(String id) async {
    try {
      await usersBox.delete(id);
      debugPrint('HiveService: User deleted with ID: $id');
      return true;
    } catch (e) {
      debugPrint('HiveService: Error deleting user: $e');
      return false;
    }
  }

  /// Get users by role
  static List<User> getUsersByRole(UserRole role) {
    try {
      return usersBox.values.where((user) => user.role == role).toList();
    } catch (e) {
      debugPrint('HiveService: Error getting users by role: $e');
      return [];
    }
  }

  /// Get users by status
  static List<User> getUsersByStatus(UserStatus status) {
    try {
      return usersBox.values.where((user) => user.status == status).toList();
    } catch (e) {
      debugPrint('HiveService: Error getting users by status: $e');
      return [];
    }
  }

  /// Search users by name or email
  static List<User> searchUsers(String query) {
    try {
      final lowerQuery = query.toLowerCase();
      return usersBox.values.where((user) =>
          user.fullName.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery) ||
          user.username.toLowerCase().contains(lowerQuery)
      ).toList();
    } catch (e) {
      debugPrint('HiveService: Error searching users: $e');
      return [];
    }
  }

  // ============================================================================
  // TASK CRUD OPERATIONS
  // ============================================================================

  /// Create a new task
  static Future<String> createTask(Task task) async {
    try {
      await tasksBox.put(task.id, task);
      debugPrint('HiveService: Task created with ID: ${task.id}');
      return task.id;
    } catch (e) {
      debugPrint('HiveService: Error creating task: $e');
      rethrow;
    }
  }

  /// Get task by ID
  static Task? getTask(String id) {
    try {
      return tasksBox.get(id);
    } catch (e) {
      debugPrint('HiveService: Error getting task: $e');
      return null;
    }
  }

  /// Get all tasks
  static List<Task> getAllTasks() {
    try {
      return tasksBox.values.toList();
    } catch (e) {
      debugPrint('HiveService: Error getting all tasks: $e');
      return [];
    }
  }

  /// Update task
  static Future<bool> updateTask(Task task) async {
    try {
      await tasksBox.put(task.id, task);
      debugPrint('HiveService: Task updated with ID: ${task.id}');
      return true;
    } catch (e) {
      debugPrint('HiveService: Error updating task: $e');
      return false;
    }
  }

  /// Delete task
  static Future<bool> deleteTask(String id) async {
    try {
      await tasksBox.delete(id);
      debugPrint('HiveService: Task deleted with ID: $id');
      return true;
    } catch (e) {
      debugPrint('HiveService: Error deleting task: $e');
      return false;
    }
  }

  /// Get tasks by assigned user
  static List<Task> getTasksByUser(String userId) {
    try {
      return tasksBox.values.where((task) => task.assignedUserId == userId).toList();
    } catch (e) {
      debugPrint('HiveService: Error getting tasks by user: $e');
      return [];
    }
  }

  /// Get tasks by status
  static List<Task> getTasksByStatus(TaskStatus status) {
    try {
      return tasksBox.values.where((task) => task.status == status).toList();
    } catch (e) {
      debugPrint('HiveService: Error getting tasks by status: $e');
      return [];
    }
  }

  /// Get tasks by priority
  static List<Task> getTasksByPriority(TaskPriority priority) {
    try {
      return tasksBox.values.where((task) => task.priority == priority).toList();
    } catch (e) {
      debugPrint('HiveService: Error getting tasks by priority: $e');
      return [];
    }
  }

  /// Get overdue tasks
  static List<Task> getOverdueTasks() {
    try {
      final now = DateTime.now();
      return tasksBox.values.where((task) =>
          task.dueDate != null &&
          task.dueDate!.isBefore(now) &&
          !task.isCompleted
      ).toList();
    } catch (e) {
      debugPrint('HiveService: Error getting overdue tasks: $e');
      return [];
    }
  }

  /// Search tasks by title or description
  static List<Task> searchTasks(String query) {
    try {
      final lowerQuery = query.toLowerCase();
      return tasksBox.values.where((task) =>
          task.title.toLowerCase().contains(lowerQuery) ||
          task.description.toLowerCase().contains(lowerQuery)
      ).toList();
    } catch (e) {
      debugPrint('HiveService: Error searching tasks: $e');
      return [];
    }
  }

  // ============================================================================
  // NOTIFICATION CRUD OPERATIONS
  // ============================================================================

  /// Create a new notification
  static Future<String> createNotification(Notification notification) async {
    try {
      await notificationsBox.put(notification.id, notification);
      debugPrint('HiveService: Notification created with ID: ${notification.id}');
      return notification.id;
    } catch (e) {
      debugPrint('HiveService: Error creating notification: $e');
      rethrow;
    }
  }

  /// Get notification by ID
  static Notification? getNotification(String id) {
    try {
      return notificationsBox.get(id);
    } catch (e) {
      debugPrint('HiveService: Error getting notification: $e');
      return null;
    }
  }

  /// Get all notifications
  static List<Notification> getAllNotifications() {
    try {
      return notificationsBox.values.toList();
    } catch (e) {
      debugPrint('HiveService: Error getting all notifications: $e');
      return [];
    }
  }

  /// Update notification
  static Future<bool> updateNotification(Notification notification) async {
    try {
      await notificationsBox.put(notification.id, notification);
      debugPrint('HiveService: Notification updated with ID: ${notification.id}');
      return true;
    } catch (e) {
      debugPrint('HiveService: Error updating notification: $e');
      return false;
    }
  }

  /// Delete notification
  static Future<bool> deleteNotification(String id) async {
    try {
      await notificationsBox.delete(id);
      debugPrint('HiveService: Notification deleted with ID: $id');
      return true;
    } catch (e) {
      debugPrint('HiveService: Error deleting notification: $e');
      return false;
    }
  }

  /// Get notifications for user
  static List<Notification> getNotificationsForUser(String userId) {
    try {
      return notificationsBox.values.where((notification) =>
          notification.recipientUserId == userId
      ).toList();
    } catch (e) {
      debugPrint('HiveService: Error getting notifications for user: $e');
      return [];
    }
  }

  /// Get unread notifications for user
  static List<Notification> getUnreadNotificationsForUser(String userId) {
    try {
      return notificationsBox.values.where((notification) =>
          notification.recipientUserId == userId && notification.isUnread
      ).toList();
    } catch (e) {
      debugPrint('HiveService: Error getting unread notifications for user: $e');
      return [];
    }
  }

  /// Mark notification as read
  static Future<bool> markNotificationAsRead(String id) async {
    try {
      final notification = notificationsBox.get(id);
      if (notification != null) {
        final updatedNotification = notification.markAsRead();
        await notificationsBox.put(id, updatedNotification);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('HiveService: Error marking notification as read: $e');
      return false;
    }
  }

  /// Delete expired notifications
  static Future<int> deleteExpiredNotifications() async {
    try {
      final now = DateTime.now();
      final expiredIds = <String>[];
      
      for (final notification in notificationsBox.values) {
        if (notification.isExpired) {
          expiredIds.add(notification.id);
        }
      }
      
      for (final id in expiredIds) {
        await notificationsBox.delete(id);
      }
      
      debugPrint('HiveService: Deleted ${expiredIds.length} expired notifications');
      return expiredIds.length;
    } catch (e) {
      debugPrint('HiveService: Error deleting expired notifications: $e');
      return 0;
    }
  }

  // ============================================================================
  // SETTINGS CRUD OPERATIONS
  // ============================================================================

  /// Create or update settings for user
  static Future<String> saveSettings(Settings settings) async {
    try {
      await settingsBox.put(settings.id, settings);
      debugPrint('HiveService: Settings saved with ID: ${settings.id}');
      return settings.id;
    } catch (e) {
      debugPrint('HiveService: Error saving settings: $e');
      rethrow;
    }
  }

  /// Get settings by ID
  static Settings? getSettings(String id) {
    try {
      return settingsBox.get(id);
    } catch (e) {
      debugPrint('HiveService: Error getting settings: $e');
      return null;
    }
  }

  /// Get settings for user
  static Settings? getSettingsForUser(String userId) {
    try {
      return settingsBox.values.firstWhere(
        (settings) => settings.userId == userId,
        orElse: () => Settings(userId: userId),
      );
    } catch (e) {
      debugPrint('HiveService: Error getting settings for user: $e');
      return Settings(userId: userId);
    }
  }

  /// Get all settings
  static List<Settings> getAllSettings() {
    try {
      return settingsBox.values.toList();
    } catch (e) {
      debugPrint('HiveService: Error getting all settings: $e');
      return [];
    }
  }

  /// Delete settings
  static Future<bool> deleteSettings(String id) async {
    try {
      await settingsBox.delete(id);
      debugPrint('HiveService: Settings deleted with ID: $id');
      return true;
    } catch (e) {
      debugPrint('HiveService: Error deleting settings: $e');
      return false;
    }
  }

  /// Reset settings to defaults for user
  static Future<bool> resetSettingsToDefaults(String userId) async {
    try {
      final currentSettings = getSettingsForUser(userId);
      if (currentSettings != null) {
        final defaultSettings = currentSettings.resetToDefaults();
        await saveSettings(defaultSettings);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('HiveService: Error resetting settings to defaults: $e');
      return false;
    }
  }

  /// Create settings
  static Future<String> createSettings(Settings settings) async {
    try {
      await settingsBox.put(settings.id, settings);
      debugPrint('HiveService: Settings created with ID: ${settings.id}');
      return settings.id;
    } catch (e) {
      debugPrint('HiveService: Error creating settings: $e');
      throw Exception('Failed to create settings: $e');
    }
  }

  /// Update settings
  static Future<bool> updateSettings(Settings settings) async {
    try {
      await settingsBox.put(settings.id, settings);
      debugPrint('HiveService: Settings updated with ID: ${settings.id}');
      return true;
    } catch (e) {
      debugPrint('HiveService: Error updating settings: $e');
      return false;
    }
  }
}
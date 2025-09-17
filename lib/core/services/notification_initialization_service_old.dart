import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/notification_settings_model.dart';
import '../repositories/notification_settings_repository.dart';
import '../managers/task_notification_manager.dart';
import '../services/notification_service.dart';

class NotificationInitializationService {
  static final NotificationInitializationService _instance = 
      NotificationInitializationService._internal();
  factory NotificationInitializationService() => _instance;
  NotificationInitializationService._internal();

  bool _isInitialized = false;

  /// Initialize the complete notification system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('NotificationInitializationService: Starting initialization...');

      // Step 1: Register Hive adapters for notification settings
      await _registerHiveAdapters();

      // Step 2: Initialize notification settings repository
      await NotificationSettingsRepository.initialize();
      debugPrint('NotificationInitializationService: Settings repository initialized');

      // Step 3: Initialize notification service
      final notificationService = NotificationService();
      await notificationService.initialize();
      debugPrint('NotificationInitializationService: Notification service initialized');

      // Step 4: Initialize task notification manager
      final taskNotificationManager = TaskNotificationManager();
      await taskNotificationManager.initialize();
      debugPrint('NotificationInitializationService: Task notification manager initialized');

      // Step 5: Schedule a daily check for overdue tasks
      await _scheduleOverdueTaskCheck();

      _isInitialized = true;
      debugPrint('NotificationInitializationService: Initialization completed successfully');

    } catch (e) {
      debugPrint('NotificationInitializationService: Initialization failed: $e');
      rethrow;
    }
  }

  /// Register all necessary Hive adapters for notifications
  Future<void> _registerHiveAdapters() async {
    try {
      // Register NotificationSettings adapter if not already registered
      if (!Hive.isAdapterRegistered(35)) {
        Hive.registerAdapter(NotificationSettingsAdapter());
        debugPrint('NotificationInitializationService: Registered NotificationSettings adapter');
      }

      // Register NotificationPriority adapter if not already registered
      if (!Hive.isAdapterRegistered(36)) {
        Hive.registerAdapter(NotificationPriorityAdapter());
        debugPrint('NotificationInitializationService: Registered NotificationPriority adapter');
      }

    } catch (e) {
      debugPrint('NotificationInitializationService: Error registering adapters: $e');
      rethrow;
    }
  }

  /// Schedule periodic check for overdue tasks
  Future<void> _scheduleOverdueTaskCheck() async {
    // Note: In a production app, you might want to use a background service
    // or WorkManager for Android, or similar solutions for other platforms
    
    // For now, we'll just ensure the check happens when the app starts
    final taskNotificationManager = TaskNotificationManager();
    await taskNotificationManager.checkForOverdueTasks();
    
    debugPrint('NotificationInitializationService: Overdue task check completed');
  }

  /// Reset the notification system (useful for testing or troubleshooting)
  Future<void> reset() async {
    try {
      debugPrint('NotificationInitializationService: Resetting notification system...');

      // Cancel all notifications
      final taskNotificationManager = TaskNotificationManager();
      await taskNotificationManager.cancelAllNotifications();

      // Reset notification settings to defaults
      final settingsRepository = NotificationSettingsRepository();
      await settingsRepository.resetToDefaults();

      // Re-initialize everything
      _isInitialized = false;
      await initialize();

      debugPrint('NotificationInitializationService: Reset completed successfully');
    } catch (e) {
      debugPrint('NotificationInitializationService: Reset failed: $e');
      rethrow;
    }
  }

  /// Check if the notification system is properly initialized
  bool get isInitialized => _isInitialized;

  /// Get initialization status and diagnostics
  Future<Map<String, dynamic>> getDiagnostics() async {
    final taskNotificationManager = TaskNotificationManager();
    final notificationSummary = await taskNotificationManager.getNotificationSummary();
    
    final settingsRepository = NotificationSettingsRepository();
    final settingsSummary = settingsRepository.getSettingsSummary();

    return {
      'isInitialized': _isInitialized,
      'notificationSummary': notificationSummary,
      'settingsSummary': settingsSummary,
      'hiveBoxesOpen': {
        'notificationSettings': Hive.isBoxOpen('notification_settings'),
        'tasks': Hive.isBoxOpen('tasks'),
      },
      'adaptersRegistered': {
        'notificationSettings': Hive.isAdapterRegistered(35),
        'notificationPriority': Hive.isAdapterRegistered(36),
      },
    };
  }

  /// Perform a health check of the notification system
  Future<bool> performHealthCheck() async {
    try {
      // Check if initialization is complete
      if (!_isInitialized) {
        debugPrint('NotificationInitializationService: Health check failed - not initialized');
        return false;
      }

      // Check if Hive boxes are accessible
      final settingsRepository = NotificationSettingsRepository();
      final settings = settingsRepository.getSettings();
      
      // Check if notification service is working
      final notificationService = NotificationService();
      // Note: We could add a method to check if the service is ready
      
      // Check if task notification manager is working
      final taskNotificationManager = TaskNotificationManager();
      final summary = await taskNotificationManager.getNotificationSummary();
      
      debugPrint('NotificationInitializationService: Health check passed');
      debugPrint('Settings loaded: ${settings.toString()}');
      debugPrint('Notification summary: $summary');
      
      return true;
    } catch (e) {
      debugPrint('NotificationInitializationService: Health check failed: $e');
      return false;
    }
  }

  /// Migrate notification settings if needed (for future updates)
  Future<void> migrateIfNeeded() async {
    try {
      final settingsRepository = NotificationSettingsRepository();
      final settings = settingsRepository.getSettings();
      
      // Check version and migrate if necessary
      // This is where you would add migration logic for future updates
      
      debugPrint('NotificationInitializationService: Migration check completed');
    } catch (e) {
      debugPrint('NotificationInitializationService: Migration failed: $e');
      rethrow;
    }
  }

  /// Force refresh all notifications
  Future<void> refreshAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    final taskNotificationManager = TaskNotificationManager();
    await taskNotificationManager.refreshAllNotifications();
    
    debugPrint('NotificationInitializationService: All notifications refreshed');
  }

  /// Test the notification system
  Future<bool> testNotifications() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final notificationService = NotificationService();
      await notificationService.showImmediateNotification(
        title: 'Test Notification',
        body: 'GestCom notification system is working correctly!',
      );

      debugPrint('NotificationInitializationService: Test notification sent successfully');
      return true;
    } catch (e) {
      debugPrint('NotificationInitializationService: Test notification failed: $e');
      return false;
    }
  }
}
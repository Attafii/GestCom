import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings_model.dart';
import '../repositories/notification_settings_repository.dart';
import '../managers/task_notification_manager.dart';
import '../services/notification_service.dart';

// Repository provider
final notificationSettingsRepositoryProvider = Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepository();
});

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Task notification manager provider
final taskNotificationManagerProvider = Provider<TaskNotificationManager>((ref) {
  return TaskNotificationManager();
});

// Current notification settings provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  final repository = ref.watch(notificationSettingsRepositoryProvider);
  return NotificationSettingsNotifier(repository);
});

// Notification summary provider
final notificationSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final manager = ref.watch(taskNotificationManagerProvider);
  return await manager.getNotificationSummary();
});

// Pending notifications count provider
final pendingNotificationsCountProvider = FutureProvider<int>((ref) async {
  final manager = ref.watch(taskNotificationManagerProvider);
  return await manager.getPendingNotificationsCount();
});

// Are notifications currently allowed provider
final notificationsAllowedProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.shouldSendNotificationNow();
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationSettingsRepository _repository;
  
  NotificationSettingsNotifier(this._repository) : super(_repository.getSettings());

  /// Update task deadline notifications setting
  Future<void> updateTaskDeadlineNotifications(bool enabled) async {
    await _repository.updateTaskDeadlineNotifications(enabled);
    state = _repository.getSettings();
  }

  /// Update task reminders setting
  Future<void> updateTaskReminders(bool enabled) async {
    await _repository.updateTaskReminders(enabled);
    state = _repository.getSettings();
  }

  /// Update overdue task notifications setting
  Future<void> updateOverdueTaskNotifications(bool enabled) async {
    await _repository.updateOverdueTaskNotifications(enabled);
    state = _repository.getSettings();
  }

  /// Update task completion notifications setting
  Future<void> updateTaskCompletionNotifications(bool enabled) async {
    await _repository.updateTaskCompletionNotifications(enabled);
    state = _repository.getSettings();
  }

  /// Update system tray notifications setting
  Future<void> updateSystemTrayNotifications(bool enabled) async {
    await _repository.updateSystemTrayNotifications(enabled);
    state = _repository.getSettings();
  }

  /// Update sound and vibration settings
  Future<void> updateSoundSettings(bool enableSounds, bool enableVibration) async {
    await _repository.updateSoundSettings(enableSounds, enableVibration);
    state = _repository.getSettings();
  }

  /// Update default notification priority
  Future<void> updateDefaultPriority(NotificationPriority priority) async {
    await _repository.updateDefaultPriority(priority);
    state = _repository.getSettings();
  }

  /// Update quiet hours settings
  Future<void> updateQuietHours({
    required bool enabled,
    required String startTime,
    required String endTime,
  }) async {
    if (!_repository.isValidTimeFormat(startTime) || !_repository.isValidTimeFormat(endTime)) {
      throw ArgumentError('Invalid time format. Use HH:mm format.');
    }
    
    await _repository.updateQuietHours(
      enabled: enabled,
      startTime: startTime,
      endTime: endTime,
    );
    state = _repository.getSettings();
  }

  /// Update quiet days (0-6, Sunday-Saturday)
  Future<void> updateQuietDays(List<int> days) async {
    final validDays = days.where((day) => day >= 0 && day <= 6).toList();
    await _repository.updateQuietDays(validDays);
    state = _repository.getSettings();
  }

  /// Update weekend notifications setting
  Future<void> updateWeekendNotifications(bool enabled) async {
    await _repository.updateWeekendNotifications(enabled);
    state = _repository.getSettings();
  }

  /// Update maximum notifications per day
  Future<void> updateMaxNotificationsPerDay(int maxNotifications) async {
    if (maxNotifications < 1 || maxNotifications > 100) {
      throw ArgumentError('Max notifications per day must be between 1 and 100');
    }
    
    await _repository.updateMaxNotificationsPerDay(maxNotifications);
    state = _repository.getSettings();
  }

  /// Update reminder intervals
  Future<void> updateReminderIntervals(List<int> intervals) async {
    // Validate intervals (must be positive)
    final validIntervals = intervals.where((interval) => interval > 0).toList();
    if (validIntervals.isEmpty) {
      throw ArgumentError('At least one valid reminder interval is required');
    }
    
    await _repository.updateReminderIntervals(validIntervals);
    state = _repository.getSettings();
  }

  /// Add a custom reminder interval
  Future<void> addReminderInterval(int minutes) async {
    if (minutes <= 0) {
      throw ArgumentError('Reminder interval must be positive');
    }
    
    await _repository.addReminderInterval(minutes);
    state = _repository.getSettings();
  }

  /// Remove a reminder interval
  Future<void> removeReminderInterval(int minutes) async {
    await _repository.removeReminderInterval(minutes);
    state = _repository.getSettings();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await _repository.resetToDefaults();
    state = _repository.getSettings();
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> json) async {
    await _repository.importSettings(json);
    state = _repository.getSettings();
  }

  /// Get settings summary
  Map<String, dynamic> getSettingsSummary() {
    return _repository.getSettingsSummary();
  }

  /// Export settings to JSON
  Map<String, dynamic> exportSettings() {
    return _repository.exportSettings();
  }

  /// Refresh settings from repository
  void refresh() {
    state = _repository.getSettings();
  }
}

// Provider for reminder intervals as readable strings
final reminderIntervalsStringProvider = Provider<List<String>>((ref) {
  final repository = ref.watch(notificationSettingsRepositoryProvider);
  return repository.getReminderIntervalsAsStrings();
});

// Provider for settings summary
final settingsSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.watch(notificationSettingsProvider.notifier);
  return notifier.getSettingsSummary();
});

// Provider to check if notifications are enabled for specific types
final deadlineNotificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableTaskDeadlineNotifications;
});

final remindersEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableTaskReminders;
});

final overdueNotificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableOverdueTaskNotifications;
});

final completionNotificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableTaskCompletionNotifications;
});

final systemTrayNotificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableSystemTrayNotifications;
});

final soundsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableSounds;
});

final vibrationEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableVibration;
});

final quietHoursEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableQuietHours;
});

final weekendNotificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.enableWeekendNotifications;
});
import 'package:hive/hive.dart';
import '../models/notification_settings_model.dart';

class NotificationSettingsRepository {
  static const String _boxName = 'notification_settings';
  static const String _defaultKey = 'user_notification_settings';
  
  Box<NotificationSettings> get _box => Hive.box<NotificationSettings>(_boxName);

  /// Initialize the notification settings box
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<NotificationSettings>(_boxName);
    }
  }

  /// Get current notification settings (creates default if doesn't exist)
  NotificationSettings getSettings() {
    final settings = _box.get(_defaultKey);
    if (settings == null) {
      final defaultSettings = NotificationSettings();
      _box.put(_defaultKey, defaultSettings);
      return defaultSettings;
    }
    return settings;
  }

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings settings) async {
    final updatedSettings = settings.copyWith(updatedAt: DateTime.now());
    await _box.put(_defaultKey, updatedSettings);
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    final defaultSettings = NotificationSettings();
    await _box.put(_defaultKey, defaultSettings);
  }

  /// Update specific setting - task deadline notifications
  Future<void> updateTaskDeadlineNotifications(bool enabled) async {
    final settings = getSettings();
    final updated = settings.copyWith(enableTaskDeadlineNotifications: enabled);
    await updateSettings(updated);
  }

  /// Update specific setting - task reminders
  Future<void> updateTaskReminders(bool enabled) async {
    final settings = getSettings();
    final updated = settings.copyWith(enableTaskReminders: enabled);
    await updateSettings(updated);
  }

  /// Update specific setting - overdue task notifications
  Future<void> updateOverdueTaskNotifications(bool enabled) async {
    final settings = getSettings();
    final updated = settings.copyWith(enableOverdueTaskNotifications: enabled);
    await updateSettings(updated);
  }

  /// Update specific setting - task completion notifications
  Future<void> updateTaskCompletionNotifications(bool enabled) async {
    final settings = getSettings();
    final updated = settings.copyWith(enableTaskCompletionNotifications: enabled);
    await updateSettings(updated);
  }

  /// Update specific setting - system tray notifications
  Future<void> updateSystemTrayNotifications(bool enabled) async {
    final settings = getSettings();
    final updated = settings.copyWith(enableSystemTrayNotifications: enabled);
    await updateSettings(updated);
  }

  /// Update reminder intervals (in minutes)
  Future<void> updateReminderIntervals(List<int> intervals) async {
    final settings = getSettings();
    final updated = settings.copyWith(reminderIntervals: intervals);
    await updateSettings(updated);
  }

  /// Update sound settings
  Future<void> updateSoundSettings(bool enableSounds, bool enableVibration) async {
    final settings = getSettings();
    final updated = settings.copyWith(
      enableSounds: enableSounds,
      enableVibration: enableVibration,
    );
    await updateSettings(updated);
  }

  /// Update default priority
  Future<void> updateDefaultPriority(NotificationPriority priority) async {
    final settings = getSettings();
    final updated = settings.copyWith(defaultPriority: priority);
    await updateSettings(updated);
  }

  /// Update quiet hours
  Future<void> updateQuietHours({
    required bool enabled,
    required String startTime,
    required String endTime,
  }) async {
    final settings = getSettings();
    final updated = settings.copyWith(
      enableQuietHours: enabled,
      quietHoursStart: startTime,
      quietHoursEnd: endTime,
    );
    await updateSettings(updated);
  }

  /// Update quiet days (0-6, Sunday-Saturday)
  Future<void> updateQuietDays(List<int> days) async {
    final settings = getSettings();
    final updated = settings.copyWith(quietDays: days);
    await updateSettings(updated);
  }

  /// Update weekend notifications setting
  Future<void> updateWeekendNotifications(bool enabled) async {
    final settings = getSettings();
    final updated = settings.copyWith(enableWeekendNotifications: enabled);
    await updateSettings(updated);
  }

  /// Update max notifications per day
  Future<void> updateMaxNotificationsPerDay(int maxNotifications) async {
    final settings = getSettings();
    final updated = settings.copyWith(maxNotificationsPerDay: maxNotifications);
    await updateSettings(updated);
  }

  /// Add a custom reminder interval
  Future<void> addReminderInterval(int minutes) async {
    final settings = getSettings();
    final intervals = List<int>.from(settings.reminderIntervals);
    if (!intervals.contains(minutes)) {
      intervals.add(minutes);
      intervals.sort((a, b) => b.compareTo(a)); // Sort descending
      final updated = settings.copyWith(reminderIntervals: intervals);
      await updateSettings(updated);
    }
  }

  /// Remove a reminder interval
  Future<void> removeReminderInterval(int minutes) async {
    final settings = getSettings();
    final intervals = List<int>.from(settings.reminderIntervals);
    intervals.remove(minutes);
    final updated = settings.copyWith(reminderIntervals: intervals);
    await updateSettings(updated);
  }

  /// Check if notifications are currently allowed
  bool areNotificationsAllowed() {
    final settings = getSettings();
    return settings.shouldSendNotificationNow();
  }

  /// Get notification settings summary
  Map<String, dynamic> getSettingsSummary() {
    final settings = getSettings();
    
    return {
      'deadlineNotifications': settings.enableTaskDeadlineNotifications,
      'reminders': settings.enableTaskReminders,
      'overdueNotifications': settings.enableOverdueTaskNotifications,
      'completionNotifications': settings.enableTaskCompletionNotifications,
      'systemTray': settings.enableSystemTrayNotifications,
      'sounds': settings.enableSounds,
      'vibration': settings.enableVibration,
      'quietHours': settings.enableQuietHours,
      'weekendNotifications': settings.enableWeekendNotifications,
      'reminderCount': settings.reminderIntervals.length,
      'maxPerDay': settings.maxNotificationsPerDay,
      'isCurrentlyAllowed': settings.shouldSendNotificationNow(),
    };
  }

  /// Export settings to JSON
  Map<String, dynamic> exportSettings() {
    final settings = getSettings();
    return settings.toJson();
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> json) async {
    try {
      final settings = NotificationSettings.fromJson(json);
      await updateSettings(settings);
    } catch (e) {
      throw Exception('Invalid notification settings format: $e');
    }
  }

  /// Get default reminder intervals as readable strings
  List<String> getReminderIntervalsAsStrings() {
    final settings = getSettings();
    return settings.reminderIntervals.map((minutes) {
      if (minutes >= 1440) {
        final days = minutes ~/ 1440;
        return '$days day${days > 1 ? 's' : ''} before';
      } else if (minutes >= 60) {
        final hours = minutes ~/ 60;
        return '$hours hour${hours > 1 ? 's' : ''} before';
      } else {
        return '$minutes minute${minutes > 1 ? 's' : ''} before';
      }
    }).toList();
  }

  /// Validate time format (HH:mm)
  bool isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  /// Clear all settings
  Future<void> clearAllSettings() async {
    await _box.clear();
  }
}
import '../models/settings_model.dart';
import '../services/hive_service.dart';

/// Repository for Settings entity operations with business logic
class SettingsRepository {
  /// Create default settings for a user
  Future<String> createDefaultSettings(String userId) async {
    // Validate user exists
    final user = HiveService.getUser(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // Check if settings already exist for this user
    final existingSettings = HiveService.getAllSettings()
        .where((s) => s.userId == userId)
        .firstOrNull;
    if (existingSettings != null) {
      throw Exception('Settings already exist for this user');
    }

    final settings = Settings(
      userId: userId,
    );

    return await HiveService.createSettings(settings);
  }

  /// Get settings by ID
  Settings? getSettingsById(String id) {
    return HiveService.getSettings(id);
  }

  /// Get settings by user ID
  Settings? getSettingsByUserId(String userId) {
    return HiveService.getAllSettings()
        .where((s) => s.userId == userId)
        .firstOrNull;
  }

  /// Get or create settings for user
  Future<Settings> getOrCreateSettingsForUser(String userId) async {
    var settings = getSettingsByUserId(userId);
    
    if (settings == null) {
      final settingsId = await createDefaultSettings(userId);
      settings = getSettingsById(settingsId);
      if (settings == null) {
        throw Exception('Failed to create settings');
      }
    }
    
    return settings;
  }

  /// Update settings
  Future<bool> updateSettings(String id, {
    ThemeSettings? theme,
    NotificationSettings? notifications,
    LanguageSettings? language,
    PrivacySettings? privacy,
    GeneralSettings? general,
    Map<String, dynamic>? customSettings,
  }) async {
    final settings = HiveService.getSettings(id);
    if (settings == null) {
      throw Exception('Settings not found');
    }

    final updatedSettings = settings.copyWith(
      theme: theme,
      notifications: notifications,
      language: language,
      privacy: privacy,
      general: general,
      customSettings: customSettings,
    );

    return await HiveService.updateSettings(updatedSettings);
  }

  /// Update theme settings
  Future<bool> updateThemeSettings(String userId, {
    ThemeMode? themeMode,
    String? primaryColor,
    String? accentColor,
    double? fontSize,
    String? fontFamily,
    bool? useSystemTheme,
    bool? highContrast,
    Map<String, dynamic>? customColors,
  }) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedThemeSettings = settings.theme.copyWith(
      themeMode: themeMode,
      primaryColor: primaryColor,
      accentColor: accentColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      useSystemTheme: useSystemTheme,
      highContrast: highContrast,
      customColors: customColors,
    );

    return await updateSettings(
      settings.id,
      theme: updatedThemeSettings,
    );
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(String userId, {
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? inAppNotifications,
    bool? taskReminders,
    bool? systemAlerts,
    bool? marketingEmails,
    String? quietHoursStart,
    String? quietHoursEnd,
    List<String>? allowedNotificationTypes,
  }) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedNotificationSettings = settings.notifications.copyWith(
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
      smsNotifications: smsNotifications,
      inAppNotifications: inAppNotifications,
      taskReminders: taskReminders,
      systemAlerts: systemAlerts,
      marketingEmails: marketingEmails,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
      allowedNotificationTypes: allowedNotificationTypes,
    );

    return await updateSettings(
      settings.id,
      notifications: updatedNotificationSettings,
    );
  }

  /// Update language settings
  Future<bool> updateLanguageSettings(String userId, {
    String? language,
    String? region,
    String? dateFormat,
    String? timeFormat,
    String? numberFormat,
    String? currency,
    String? timezone,
  }) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedLanguageSettings = settings.language.copyWith(
      language: language,
      region: region,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      numberFormat: numberFormat,
      currency: currency,
      timezone: timezone,
    );

    return await updateSettings(
      settings.id,
      language: updatedLanguageSettings,
    );
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(String userId, {
    bool? profileVisibility,
    bool? activityTracking,
    bool? dataCollection,
    bool? thirdPartySharing,
    bool? locationTracking,
    bool? analyticsOptOut,
    List<String>? blockedUsers,
    Map<String, bool>? permissionSettings,
  }) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedPrivacySettings = settings.privacy.copyWith(
      profileVisibility: profileVisibility,
      activityTracking: activityTracking,
      dataCollection: dataCollection,
      thirdPartySharing: thirdPartySharing,
      locationTracking: locationTracking,
      analyticsOptOut: analyticsOptOut,
      blockedUsers: blockedUsers,
      permissionSettings: permissionSettings,
    );

    return await updateSettings(
      settings.id,
      privacy: updatedPrivacySettings,
    );
  }

  /// Update currency settings
  Future<bool> updateCurrencySettings(String userId, {
    required String currency,
    double? eurToTndRate,
  }) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedGeneralSettings = settings.general.copyWith(
      currency: currency,
      eurToTndRate: eurToTndRate,
    );

    return await updateSettings(
      settings.id,
      general: updatedGeneralSettings,
    );
  }

  /// Get current currency for user
  String getCurrency(String userId) {
    final settings = getSettingsByUserId(userId);
    return settings?.general.currency ?? 'EUR';
  }

  /// Get EUR to TND conversion rate
  double getEurToTndRate(String userId) {
    final settings = getSettingsByUserId(userId);
    return settings?.general.eurToTndRate ?? 3.3;
  }

  /// Delete settings
  Future<bool> deleteSettings(String id) async {
    final settings = HiveService.getSettings(id);
    if (settings == null) {
      throw Exception('Settings not found');
    }

    return await HiveService.deleteSettings(id);
  }

  /// Reset settings to default for user
  Future<bool> resetToDefaults(String userId) async {
    final existingSettings = getSettingsByUserId(userId);
    if (existingSettings != null) {
      await deleteSettings(existingSettings.id);
    }

    await createDefaultSettings(userId);
    return true;
  }

  /// Get all settings
  List<Settings> getAllSettings() {
    return HiveService.getAllSettings();
  }

  /// Export settings for user
  Map<String, dynamic> exportUserSettings(String userId) {
    final settings = getSettingsByUserId(userId);
    if (settings == null) {
      throw Exception('Settings not found for user');
    }

    return settings.toJson();
  }

  /// Import settings for user
  Future<bool> importUserSettings(String userId, Map<String, dynamic> settingsData) async {
    try {
      // Delete existing settings if they exist
      final existingSettings = getSettingsByUserId(userId);
      if (existingSettings != null) {
        await deleteSettings(existingSettings.id);
      }

      // Create settings from imported data
      final settings = Settings.fromJson({...settingsData, 'userId': userId});
      await HiveService.createSettings(settings);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has specific permission
  bool hasPermission(String userId, String permission) {
    final settings = getSettingsByUserId(userId);
    if (settings == null) return false;

    return settings.privacy.permissionSettings[permission] ?? false;
  }

  /// Grant permission to user
  Future<bool> grantPermission(String userId, String permission) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedPermissions = Map<String, bool>.from(
      settings.privacySettings.permissionSettings
    );
    updatedPermissions[permission] = true;

    return await updatePrivacySettings(
      userId,
      permissionSettings: updatedPermissions,
    );
  }

  /// Revoke permission from user
  Future<bool> revokePermission(String userId, String permission) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedPermissions = Map<String, bool>.from(
      settings.privacySettings.permissionSettings
    );
    updatedPermissions[permission] = false;

    return await updatePrivacySettings(
      userId,
      permissionSettings: updatedPermissions,
    );
  }

  /// Add recent file to user settings
  Future<bool> addRecentFile(String userId, String filePath) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final recentFiles = List<String>.from(settings.general.recentFiles);
    
    // Remove if already exists
    recentFiles.remove(filePath);
    
    // Add to beginning
    recentFiles.insert(0, filePath);
    
    // Keep only last 10 files
    if (recentFiles.length > 10) {
      recentFiles.removeRange(10, recentFiles.length);
    }

    return await updateGeneralSettings(
      userId,
      recentFiles: recentFiles,
    );
  }

  /// Clear recent files for user
  Future<bool> clearRecentFiles(String userId) async {
    return await updateGeneralSettings(
      userId,
      recentFiles: [],
    );
  }

  /// Get user preference
  T? getUserPreference<T>(String userId, String key) {
    final settings = getSettingsByUserId(userId);
    if (settings == null) return null;

    return settings.general.preferences[key] as T?;
  }

  /// Set user preference
  Future<bool> setUserPreference(String userId, String key, dynamic value) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedPreferences = Map<String, dynamic>.from(
      settings.general.preferences
    );
    updatedPreferences[key] = value;

    return await updateGeneralSettings(
      userId,
      preferences: updatedPreferences,
    );
  }

  /// Remove user preference
  Future<bool> removeUserPreference(String userId, String key) async {
    final settings = await getOrCreateSettingsForUser(userId);
    
    final updatedPreferences = Map<String, dynamic>.from(
      settings.general.preferences
    );
    updatedPreferences.remove(key);

    return await updateGeneralSettings(
      userId,
      preferences: updatedPreferences,
    );
  }

  /// Check if notifications are enabled for user
  bool areNotificationsEnabled(String userId) {
    final settings = getSettingsByUserId(userId);
    if (settings == null) return true; // Default to enabled

    final notifSettings = settings.notifications;
    return notifSettings.emailNotifications ||
           notifSettings.pushNotifications ||
           notifSettings.smsNotifications ||
           notifSettings.inAppNotifications;
  }

  /// Check if user is in quiet hours
  bool isInQuietHours(String userId) {
    final settings = getSettingsByUserId(userId);
    if (settings == null) return false;

    final notifSettings = settings.notifications;
    final startTime = notifSettings.quietHoursStart;
    final endTime = notifSettings.quietHoursEnd;

    if (startTime == null || endTime == null) return false;

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Handle quiet hours spanning midnight
    if (startTime.compareTo(endTime) > 0) {
      return currentTime.compareTo(startTime) >= 0 || currentTime.compareTo(endTime) <= 0;
    } else {
      return currentTime.compareTo(startTime) >= 0 && currentTime.compareTo(endTime) <= 0;
    }
  }

  /// Get settings validation errors
  List<String> validateSettings(Settings settings) {
    final errors = <String>[];

    // Validate theme settings
    if (settings.theme.fontSize < 8 || settings.theme.fontSize > 24) {
      errors.add('Font size must be between 8 and 24');
    }

    // Validate notification settings
    final startTime = settings.notifications.quietHoursStart;
    final endTime = settings.notifications.quietHoursEnd;
    
    if (startTime != null && !RegExp(r'^\d{2}:\d{2}$').hasMatch(startTime)) {
      errors.add('Invalid quiet hours start time format');
    }
    
    if (endTime != null && !RegExp(r'^\d{2}:\d{2}$').hasMatch(endTime)) {
      errors.add('Invalid quiet hours end time format');
    }

    // Validate general settings
    if (settings.general.autoSaveInterval < 1 || settings.general.autoSaveInterval > 3600) {
      errors.add('Auto save interval must be between 1 and 3600 seconds');
    }
    
    if (settings.general.itemsPerPage < 10 || settings.general.itemsPerPage > 100) {
      errors.add('Items per page must be between 10 and 100');
    }

    return errors;
  }
}
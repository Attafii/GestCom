import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../repositories/settings_repository.dart';

/// Provider for SettingsRepository instance
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Provider for all settings
final allSettingsProvider = FutureProvider<List<Settings>>((ref) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.getAllSettings();
});

/// Provider for a specific settings by ID
final settingsProvider = FutureProvider.family<Settings?, String>((ref, settingsId) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.getSettingsById(settingsId);
});

/// Provider for settings by user ID
final userSettingsProvider = FutureProvider.family<Settings?, String>((ref, userId) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.getSettingsByUserId(userId);
});

/// Provider for settings by user ID (get or create)
final userSettingsOrCreateProvider = FutureProvider.family<Settings, String>((ref, userId) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.getOrCreateSettingsForUser(userId);
});

/// Provider for theme settings by user ID
final userThemeSettingsProvider = FutureProvider.family<ThemeSettings, String>((ref, userId) async {
  final settings = await ref.watch(userSettingsOrCreateProvider(userId).future);
  return settings.theme;
});

/// Provider for notification settings by user ID
final userNotificationSettingsProvider = FutureProvider.family<NotificationSettings, String>((ref, userId) async {
  final settings = await ref.watch(userSettingsOrCreateProvider(userId).future);
  return settings.notifications;
});

/// Provider for language settings by user ID
final userLanguageSettingsProvider = FutureProvider.family<LanguageSettings, String>((ref, userId) async {
  final settings = await ref.watch(userSettingsOrCreateProvider(userId).future);
  return settings.language;
});

/// Provider for privacy settings by user ID
final userPrivacySettingsProvider = FutureProvider.family<PrivacySettings, String>((ref, userId) async {
  final settings = await ref.watch(userSettingsOrCreateProvider(userId).future);
  return settings.privacy;
});

/// Provider for general settings by user ID
final userGeneralSettingsProvider = FutureProvider.family<GeneralSettings, String>((ref, userId) async {
  final settings = await ref.watch(userSettingsOrCreateProvider(userId).future);
  return settings.general;
});

/// Provider for settings operations (create, update, delete)
final settingsOperationsProvider = StateNotifierProvider<SettingsOperationsNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return SettingsOperationsNotifier(repository, ref);
});

/// State notifier for settings operations
class SettingsOperationsNotifier extends StateNotifier<AsyncValue<String?>> {
  final SettingsRepository _repository;
  final Ref _ref;

  SettingsOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<String?> createDefaultSettings(String userId) async {
    state = const AsyncValue.loading();

    try {
      final settingsId = await _repository.createDefaultSettings(userId);
      state = AsyncValue.data(settingsId);
      
      // Refresh related providers
      _refreshSettingsProviders(userId);

      return settingsId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

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
    state = const AsyncValue.loading();

    try {
      final success = await _repository.updateThemeSettings(
        userId,
        themeMode: themeMode,
        primaryColor: primaryColor,
        accentColor: accentColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        useSystemTheme: useSystemTheme,
        highContrast: highContrast,
        customColors: customColors,
      );

      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

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
    state = const AsyncValue.loading();

    try {
      final success = await _repository.updateNotificationSettings(
        userId,
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

      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateLanguageSettings(String userId, {
    String? language,
    String? region,
    String? dateFormat,
    String? timeFormat,
    String? numberFormat,
    String? currency,
    String? timezone,
  }) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.updateLanguageSettings(
        userId,
        language: language,
        region: region,
        dateFormat: dateFormat,
        timeFormat: timeFormat,
        numberFormat: numberFormat,
        currency: currency,
        timezone: timezone,
      );

      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

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
    state = const AsyncValue.loading();

    try {
      final success = await _repository.updatePrivacySettings(
        userId,
        profileVisibility: profileVisibility,
        activityTracking: activityTracking,
        dataCollection: dataCollection,
        thirdPartySharing: thirdPartySharing,
        locationTracking: locationTracking,
        analyticsOptOut: analyticsOptOut,
        blockedUsers: blockedUsers,
        permissionSettings: permissionSettings,
      );

      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateGeneralSettings(String userId, {
    bool? autoSave,
    int? autoSaveInterval,
    bool? confirmBeforeDelete,
    bool? showTooltips,
    String? defaultView,
    int? itemsPerPage,
    bool? enableShortcuts,
    Map<String, String>? shortcuts,
    List<String>? recentFiles,
    Map<String, dynamic>? preferences,
  }) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.updateGeneralSettings(
        userId,
        autoSave: autoSave,
        autoSaveInterval: autoSaveInterval,
        confirmBeforeDelete: confirmBeforeDelete,
        showTooltips: showTooltips,
        defaultView: defaultView,
        itemsPerPage: itemsPerPage,
        enableShortcuts: enableShortcuts,
        shortcuts: shortcuts,
        recentFiles: recentFiles,
        preferences: preferences,
      );

      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteSettings(String id) async {
    state = const AsyncValue.loading();

    try {
      final settings = _repository.getSettingsById(id);
      final userId = settings?.userId;

      final success = await _repository.deleteSettings(id);
      state = AsyncValue.data(success ? id : null);

      if (success && userId != null) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> resetToDefaults(String userId) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.resetToDefaults(userId);
      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> grantPermission(String userId, String permission) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.grantPermission(userId, permission);
      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> revokePermission(String userId, String permission) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.revokePermission(userId, permission);
      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> addRecentFile(String userId, String filePath) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.addRecentFile(userId, filePath);
      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> clearRecentFiles(String userId) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.clearRecentFiles(userId);
      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> setUserPreference(String userId, String key, dynamic value) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.setUserPreference(userId, key, value);
      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> removeUserPreference(String userId, String key) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.removeUserPreference(userId, key);
      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> importUserSettings(String userId, Map<String, dynamic> settingsData) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.importUserSettings(userId, settingsData);
      state = AsyncValue.data(success ? userId : null);

      if (success) {
        _refreshSettingsProviders(userId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  void _refreshSettingsProviders(String userId) {
    _ref.invalidate(allSettingsProvider);
    _ref.invalidate(userSettingsProvider(userId));
    _ref.invalidate(userSettingsOrCreateProvider(userId));
    _ref.invalidate(userThemeSettingsProvider(userId));
    _ref.invalidate(userNotificationSettingsProvider(userId));
    _ref.invalidate(userLanguageSettingsProvider(userId));
    _ref.invalidate(userPrivacySettingsProvider(userId));
    _ref.invalidate(userGeneralSettingsProvider(userId));
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for user permissions
final userPermissionProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final repository = ref.read(settingsRepositoryProvider);
  final userId = params['userId']!;
  final permission = params['permission']!;
  return repository.hasPermission(userId, permission);
});

/// Provider for user preferences
final userPreferenceProvider = FutureProvider.family<dynamic, Map<String, String>>((ref, params) async {
  final repository = ref.read(settingsRepositoryProvider);
  final userId = params['userId']!;
  final key = params['key']!;
  return repository.getUserPreference(userId, key);
});

/// Provider for notifications enabled status
final notificationsEnabledProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.areNotificationsEnabled(userId);
});

/// Provider for quiet hours status
final inQuietHoursProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.isInQuietHours(userId);
});

/// Provider for settings export
final exportUserSettingsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.exportUserSettings(userId);
});

/// Provider for settings validation
final settingsValidationProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  final repository = ref.read(settingsRepositoryProvider);
  final settings = repository.getSettingsByUserId(userId);
  if (settings == null) return [];
  return repository.validateSettings(settings);
});
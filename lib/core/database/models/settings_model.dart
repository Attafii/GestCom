import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 24)
class Settings extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final ThemeSettings theme;

  @HiveField(3)
  final NotificationSettings notifications;

  @HiveField(4)
  final LanguageSettings language;

  @HiveField(5)
  final PrivacySettings privacy;

  @HiveField(6)
  final GeneralSettings general;

  @HiveField(7)
  final Map<String, dynamic> customSettings;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final String version;

  Settings({
    String? id,
    required this.userId,
    ThemeSettings? theme,
    NotificationSettings? notifications,
    LanguageSettings? language,
    PrivacySettings? privacy,
    GeneralSettings? general,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.version = '1.0.0',
  })  : id = id ?? const Uuid().v4(),
        theme = theme ?? ThemeSettings(),
        notifications = notifications ?? NotificationSettings(),
        language = language ?? LanguageSettings(),
        privacy = privacy ?? PrivacySettings(),
        general = general ?? GeneralSettings(),
        customSettings = customSettings ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Copy with method
  Settings copyWith({
    String? userId,
    ThemeSettings? theme,
    NotificationSettings? notifications,
    LanguageSettings? language,
    PrivacySettings? privacy,
    GeneralSettings? general,
    Map<String, dynamic>? customSettings,
    String? version,
  }) {
    return Settings(
      id: id,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      language: language ?? this.language,
      privacy: privacy ?? this.privacy,
      general: general ?? this.general,
      customSettings: customSettings ?? Map.from(this.customSettings),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      version: version ?? this.version,
    );
  }

  // Reset to defaults
  Settings resetToDefaults() {
    return Settings(
      id: id,
      userId: userId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      version: version,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'theme': theme.toJson(),
      'notifications': notifications.toJson(),
      'language': language.toJson(),
      'privacy': privacy.toJson(),
      'general': general.toJson(),
      'customSettings': customSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      id: json['id'],
      userId: json['userId'],
      theme: ThemeSettings.fromJson(json['theme']),
      notifications: NotificationSettings.fromJson(json['notifications']),
      language: LanguageSettings.fromJson(json['language']),
      privacy: PrivacySettings.fromJson(json['privacy']),
      general: GeneralSettings.fromJson(json['general']),
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['version'] ?? '1.0.0',
    );
  }

  @override
  String toString() {
    return 'Settings(id: $id, userId: $userId, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 25)
class ThemeSettings extends HiveObject {
  @HiveField(0)
  final ThemeMode themeMode;

  @HiveField(1)
  final String primaryColor;

  @HiveField(2)
  final String accentColor;

  @HiveField(3)
  final double fontSize;

  @HiveField(4)
  final String fontFamily;

  @HiveField(5)
  final bool useMaterialYou;

  @HiveField(6)
  final bool useSystemFont;

  @HiveField(7)
  final double borderRadius;

  @HiveField(8)
  final bool enableAnimations;

  ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = '#2196F3',
    this.accentColor = '#FF4081',
    this.fontSize = 14.0,
    this.fontFamily = 'Roboto',
    this.useMaterialYou = true,
    this.useSystemFont = false,
    this.borderRadius = 8.0,
    this.enableAnimations = true,
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    String? primaryColor,
    String? accentColor,
    double? fontSize,
    String? fontFamily,
    bool? useMaterialYou,
    bool? useSystemFont,
    double? borderRadius,
    bool? enableAnimations,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      useSystemFont: useSystemFont ?? this.useSystemFont,
      borderRadius: borderRadius ?? this.borderRadius,
      enableAnimations: enableAnimations ?? this.enableAnimations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.toString(),
      'primaryColor': primaryColor,
      'accentColor': accentColor,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'useMaterialYou': useMaterialYou,
      'useSystemFont': useSystemFont,
      'borderRadius': borderRadius,
      'enableAnimations': enableAnimations,
    };
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString() == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      primaryColor: json['primaryColor'] ?? '#2196F3',
      accentColor: json['accentColor'] ?? '#FF4081',
      fontSize: json['fontSize']?.toDouble() ?? 14.0,
      fontFamily: json['fontFamily'] ?? 'Roboto',
      useMaterialYou: json['useMaterialYou'] ?? true,
      useSystemFont: json['useSystemFont'] ?? false,
      borderRadius: json['borderRadius']?.toDouble() ?? 8.0,
      enableAnimations: json['enableAnimations'] ?? true,
    );
  }
}

@HiveType(typeId: 26)
enum ThemeMode {
  @HiveField(0)
  light,
  
  @HiveField(1)
  dark,
  
  @HiveField(2)
  system,
}

@HiveType(typeId: 27)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  final bool enablePushNotifications;

  @HiveField(1)
  final bool enableEmailNotifications;

  @HiveField(2)
  final bool enableTaskReminders;

  @HiveField(3)
  final bool enableSystemNotifications;

  @HiveField(4)
  final bool playSounds;

  @HiveField(5)
  final bool showBadges;

  @HiveField(6)
  final NotificationFrequency reminderFrequency;

  @HiveField(7)
  final List<String> mutedNotificationTypes;

  @HiveField(8)
  final Map<String, bool> categorySettings;

  NotificationSettings({
    this.enablePushNotifications = true,
    this.enableEmailNotifications = true,
    this.enableTaskReminders = true,
    this.enableSystemNotifications = true,
    this.playSounds = true,
    this.showBadges = true,
    this.reminderFrequency = NotificationFrequency.daily,
    List<String>? mutedNotificationTypes,
    Map<String, bool>? categorySettings,
  })  : mutedNotificationTypes = mutedNotificationTypes ?? [],
        categorySettings = categorySettings ?? {};

  NotificationSettings copyWith({
    bool? enablePushNotifications,
    bool? enableEmailNotifications,
    bool? enableTaskReminders,
    bool? enableSystemNotifications,
    bool? playSounds,
    bool? showBadges,
    NotificationFrequency? reminderFrequency,
    List<String>? mutedNotificationTypes,
    Map<String, bool>? categorySettings,
  }) {
    return NotificationSettings(
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableEmailNotifications: enableEmailNotifications ?? this.enableEmailNotifications,
      enableTaskReminders: enableTaskReminders ?? this.enableTaskReminders,
      enableSystemNotifications: enableSystemNotifications ?? this.enableSystemNotifications,
      playSounds: playSounds ?? this.playSounds,
      showBadges: showBadges ?? this.showBadges,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      mutedNotificationTypes: mutedNotificationTypes ?? List.from(this.mutedNotificationTypes),
      categorySettings: categorySettings ?? Map.from(this.categorySettings),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'enableEmailNotifications': enableEmailNotifications,
      'enableTaskReminders': enableTaskReminders,
      'enableSystemNotifications': enableSystemNotifications,
      'playSounds': playSounds,
      'showBadges': showBadges,
      'reminderFrequency': reminderFrequency.toString(),
      'mutedNotificationTypes': mutedNotificationTypes,
      'categorySettings': categorySettings,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enablePushNotifications: json['enablePushNotifications'] ?? true,
      enableEmailNotifications: json['enableEmailNotifications'] ?? true,
      enableTaskReminders: json['enableTaskReminders'] ?? true,
      enableSystemNotifications: json['enableSystemNotifications'] ?? true,
      playSounds: json['playSounds'] ?? true,
      showBadges: json['showBadges'] ?? true,
      reminderFrequency: NotificationFrequency.values.firstWhere(
        (e) => e.toString() == json['reminderFrequency'],
        orElse: () => NotificationFrequency.daily,
      ),
      mutedNotificationTypes: List<String>.from(json['mutedNotificationTypes'] ?? []),
      categorySettings: Map<String, bool>.from(json['categorySettings'] ?? {}),
    );
  }
}

@HiveType(typeId: 28)
enum NotificationFrequency {
  @HiveField(0)
  never,
  
  @HiveField(1)
  daily,
  
  @HiveField(2)
  weekly,
  
  @HiveField(3)
  monthly,
}

@HiveType(typeId: 29)
class LanguageSettings extends HiveObject {
  @HiveField(0)
  final String locale;

  @HiveField(1)
  final String timeFormat;

  @HiveField(2)
  final String dateFormat;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final String timezone;

  LanguageSettings({
    this.locale = 'en_US',
    this.timeFormat = '24h',
    this.dateFormat = 'dd/MM/yyyy',
    this.currency = 'USD',
    this.timezone = 'UTC',
  });

  LanguageSettings copyWith({
    String? locale,
    String? timeFormat,
    String? dateFormat,
    String? currency,
    String? timezone,
  }) {
    return LanguageSettings(
      locale: locale ?? this.locale,
      timeFormat: timeFormat ?? this.timeFormat,
      dateFormat: dateFormat ?? this.dateFormat,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'timeFormat': timeFormat,
      'dateFormat': dateFormat,
      'currency': currency,
      'timezone': timezone,
    };
  }

  factory LanguageSettings.fromJson(Map<String, dynamic> json) {
    return LanguageSettings(
      locale: json['locale'] ?? 'en_US',
      timeFormat: json['timeFormat'] ?? '24h',
      dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
      currency: json['currency'] ?? 'USD',
      timezone: json['timezone'] ?? 'UTC',
    );
  }
}

@HiveType(typeId: 30)
class PrivacySettings extends HiveObject {
  @HiveField(0)
  final bool shareUsageData;

  @HiveField(1)
  final bool allowCrashReports;

  @HiveField(2)
  final bool showOnlineStatus;

  @HiveField(3)
  final bool allowProfileVisibility;

  @HiveField(4)
  final bool enableActivityTracking;

  @HiveField(5)
  final DataRetentionPeriod dataRetention;

  PrivacySettings({
    this.shareUsageData = false,
    this.allowCrashReports = true,
    this.showOnlineStatus = true,
    this.allowProfileVisibility = true,
    this.enableActivityTracking = true,
    this.dataRetention = DataRetentionPeriod.oneYear,
  });

  PrivacySettings copyWith({
    bool? shareUsageData,
    bool? allowCrashReports,
    bool? showOnlineStatus,
    bool? allowProfileVisibility,
    bool? enableActivityTracking,
    DataRetentionPeriod? dataRetention,
  }) {
    return PrivacySettings(
      shareUsageData: shareUsageData ?? this.shareUsageData,
      allowCrashReports: allowCrashReports ?? this.allowCrashReports,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowProfileVisibility: allowProfileVisibility ?? this.allowProfileVisibility,
      enableActivityTracking: enableActivityTracking ?? this.enableActivityTracking,
      dataRetention: dataRetention ?? this.dataRetention,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareUsageData': shareUsageData,
      'allowCrashReports': allowCrashReports,
      'showOnlineStatus': showOnlineStatus,
      'allowProfileVisibility': allowProfileVisibility,
      'enableActivityTracking': enableActivityTracking,
      'dataRetention': dataRetention.toString(),
    };
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      shareUsageData: json['shareUsageData'] ?? false,
      allowCrashReports: json['allowCrashReports'] ?? true,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      allowProfileVisibility: json['allowProfileVisibility'] ?? true,
      enableActivityTracking: json['enableActivityTracking'] ?? true,
      dataRetention: DataRetentionPeriod.values.firstWhere(
        (e) => e.toString() == json['dataRetention'],
        orElse: () => DataRetentionPeriod.oneYear,
      ),
    );
  }
}

@HiveType(typeId: 31)
enum DataRetentionPeriod {
  @HiveField(0)
  oneMonth,
  
  @HiveField(1)
  threeMonths,
  
  @HiveField(2)
  sixMonths,
  
  @HiveField(3)
  oneYear,
  
  @HiveField(4)
  forever,
}

@HiveType(typeId: 32)
class GeneralSettings extends HiveObject {
  @HiveField(0)
  final bool autoSave;

  @HiveField(1)
  final int autoSaveInterval;

  @HiveField(2)
  final bool confirmBeforeDelete;

  @HiveField(3)
  final bool enableBackup;

  @HiveField(4)
  final String backupLocation;

  @HiveField(5)
  final bool startWithSystem;

  @HiveField(6)
  final bool minimizeToTray;

  @HiveField(7)
  final int defaultPageSize;

  GeneralSettings({
    this.autoSave = true,
    this.autoSaveInterval = 300, // 5 minutes
    this.confirmBeforeDelete = true,
    this.enableBackup = true,
    this.backupLocation = '',
    this.startWithSystem = false,
    this.minimizeToTray = true,
    this.defaultPageSize = 25,
  });

  GeneralSettings copyWith({
    bool? autoSave,
    int? autoSaveInterval,
    bool? confirmBeforeDelete,
    bool? enableBackup,
    String? backupLocation,
    bool? startWithSystem,
    bool? minimizeToTray,
    int? defaultPageSize,
  }) {
    return GeneralSettings(
      autoSave: autoSave ?? this.autoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      enableBackup: enableBackup ?? this.enableBackup,
      backupLocation: backupLocation ?? this.backupLocation,
      startWithSystem: startWithSystem ?? this.startWithSystem,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      defaultPageSize: defaultPageSize ?? this.defaultPageSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
      'confirmBeforeDelete': confirmBeforeDelete,
      'enableBackup': enableBackup,
      'backupLocation': backupLocation,
      'startWithSystem': startWithSystem,
      'minimizeToTray': minimizeToTray,
      'defaultPageSize': defaultPageSize,
    };
  }

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      autoSave: json['autoSave'] ?? true,
      autoSaveInterval: json['autoSaveInterval'] ?? 300,
      confirmBeforeDelete: json['confirmBeforeDelete'] ?? true,
      enableBackup: json['enableBackup'] ?? true,
      backupLocation: json['backupLocation'] ?? '',
      startWithSystem: json['startWithSystem'] ?? false,
      minimizeToTray: json['minimizeToTray'] ?? true,
      defaultPageSize: json['defaultPageSize'] ?? 25,
    );
  }
}
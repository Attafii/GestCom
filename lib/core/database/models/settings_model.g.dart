// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 24;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      id: fields[0] as String?,
      userId: fields[1] as String,
      theme: fields[2] as ThemeSettings?,
      notifications: fields[3] as NotificationSettings?,
      language: fields[4] as LanguageSettings?,
      privacy: fields[5] as PrivacySettings?,
      general: fields[6] as GeneralSettings?,
      customSettings: (fields[7] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
      version: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.theme)
      ..writeByte(3)
      ..write(obj.notifications)
      ..writeByte(4)
      ..write(obj.language)
      ..writeByte(5)
      ..write(obj.privacy)
      ..writeByte(6)
      ..write(obj.general)
      ..writeByte(7)
      ..write(obj.customSettings)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemeSettingsAdapter extends TypeAdapter<ThemeSettings> {
  @override
  final int typeId = 25;

  @override
  ThemeSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeSettings(
      themeMode: fields[0] as ThemeMode,
      primaryColor: fields[1] as String,
      accentColor: fields[2] as String,
      fontSize: fields[3] as double,
      fontFamily: fields[4] as String,
      useMaterialYou: fields[5] as bool,
      useSystemFont: fields[6] as bool,
      borderRadius: fields[7] as double,
      enableAnimations: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.primaryColor)
      ..writeByte(2)
      ..write(obj.accentColor)
      ..writeByte(3)
      ..write(obj.fontSize)
      ..writeByte(4)
      ..write(obj.fontFamily)
      ..writeByte(5)
      ..write(obj.useMaterialYou)
      ..writeByte(6)
      ..write(obj.useSystemFont)
      ..writeByte(7)
      ..write(obj.borderRadius)
      ..writeByte(8)
      ..write(obj.enableAnimations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 27;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      enablePushNotifications: fields[0] as bool,
      enableEmailNotifications: fields[1] as bool,
      enableTaskReminders: fields[2] as bool,
      enableSystemNotifications: fields[3] as bool,
      playSounds: fields[4] as bool,
      showBadges: fields[5] as bool,
      reminderFrequency: fields[6] as NotificationFrequency,
      mutedNotificationTypes: (fields[7] as List?)?.cast<String>(),
      categorySettings: (fields[8] as Map?)?.cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.enablePushNotifications)
      ..writeByte(1)
      ..write(obj.enableEmailNotifications)
      ..writeByte(2)
      ..write(obj.enableTaskReminders)
      ..writeByte(3)
      ..write(obj.enableSystemNotifications)
      ..writeByte(4)
      ..write(obj.playSounds)
      ..writeByte(5)
      ..write(obj.showBadges)
      ..writeByte(6)
      ..write(obj.reminderFrequency)
      ..writeByte(7)
      ..write(obj.mutedNotificationTypes)
      ..writeByte(8)
      ..write(obj.categorySettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LanguageSettingsAdapter extends TypeAdapter<LanguageSettings> {
  @override
  final int typeId = 29;

  @override
  LanguageSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LanguageSettings(
      locale: fields[0] as String,
      timeFormat: fields[1] as String,
      dateFormat: fields[2] as String,
      currency: fields[3] as String,
      timezone: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LanguageSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.locale)
      ..writeByte(1)
      ..write(obj.timeFormat)
      ..writeByte(2)
      ..write(obj.dateFormat)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.timezone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrivacySettingsAdapter extends TypeAdapter<PrivacySettings> {
  @override
  final int typeId = 30;

  @override
  PrivacySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivacySettings(
      shareUsageData: fields[0] as bool,
      allowCrashReports: fields[1] as bool,
      showOnlineStatus: fields[2] as bool,
      allowProfileVisibility: fields[3] as bool,
      enableActivityTracking: fields[4] as bool,
      dataRetention: fields[5] as DataRetentionPeriod,
    );
  }

  @override
  void write(BinaryWriter writer, PrivacySettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.shareUsageData)
      ..writeByte(1)
      ..write(obj.allowCrashReports)
      ..writeByte(2)
      ..write(obj.showOnlineStatus)
      ..writeByte(3)
      ..write(obj.allowProfileVisibility)
      ..writeByte(4)
      ..write(obj.enableActivityTracking)
      ..writeByte(5)
      ..write(obj.dataRetention);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GeneralSettingsAdapter extends TypeAdapter<GeneralSettings> {
  @override
  final int typeId = 32;

  @override
  GeneralSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeneralSettings(
      autoSave: fields[0] as bool,
      autoSaveInterval: fields[1] as int,
      confirmBeforeDelete: fields[2] as bool,
      enableBackup: fields[3] as bool,
      backupLocation: fields[4] as String,
      startWithSystem: fields[5] as bool,
      minimizeToTray: fields[6] as bool,
      defaultPageSize: fields[7] as int,
      currency: fields[8] as String,
      eurToTndRate: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GeneralSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.autoSave)
      ..writeByte(1)
      ..write(obj.autoSaveInterval)
      ..writeByte(2)
      ..write(obj.confirmBeforeDelete)
      ..writeByte(3)
      ..write(obj.enableBackup)
      ..writeByte(4)
      ..write(obj.backupLocation)
      ..writeByte(5)
      ..write(obj.startWithSystem)
      ..writeByte(6)
      ..write(obj.minimizeToTray)
      ..writeByte(7)
      ..write(obj.defaultPageSize)
      ..writeByte(8)
      ..write(obj.currency)
      ..writeByte(9)
      ..write(obj.eurToTndRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 26;

  @override
  ThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    switch (obj) {
      case ThemeMode.light:
        writer.writeByte(0);
        break;
      case ThemeMode.dark:
        writer.writeByte(1);
        break;
      case ThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationFrequencyAdapter extends TypeAdapter<NotificationFrequency> {
  @override
  final int typeId = 28;

  @override
  NotificationFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationFrequency.never;
      case 1:
        return NotificationFrequency.daily;
      case 2:
        return NotificationFrequency.weekly;
      case 3:
        return NotificationFrequency.monthly;
      default:
        return NotificationFrequency.never;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationFrequency obj) {
    switch (obj) {
      case NotificationFrequency.never:
        writer.writeByte(0);
        break;
      case NotificationFrequency.daily:
        writer.writeByte(1);
        break;
      case NotificationFrequency.weekly:
        writer.writeByte(2);
        break;
      case NotificationFrequency.monthly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataRetentionPeriodAdapter extends TypeAdapter<DataRetentionPeriod> {
  @override
  final int typeId = 31;

  @override
  DataRetentionPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DataRetentionPeriod.oneMonth;
      case 1:
        return DataRetentionPeriod.threeMonths;
      case 2:
        return DataRetentionPeriod.sixMonths;
      case 3:
        return DataRetentionPeriod.oneYear;
      case 4:
        return DataRetentionPeriod.forever;
      default:
        return DataRetentionPeriod.oneMonth;
    }
  }

  @override
  void write(BinaryWriter writer, DataRetentionPeriod obj) {
    switch (obj) {
      case DataRetentionPeriod.oneMonth:
        writer.writeByte(0);
        break;
      case DataRetentionPeriod.threeMonths:
        writer.writeByte(1);
        break;
      case DataRetentionPeriod.sixMonths:
        writer.writeByte(2);
        break;
      case DataRetentionPeriod.oneYear:
        writer.writeByte(3);
        break;
      case DataRetentionPeriod.forever:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataRetentionPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

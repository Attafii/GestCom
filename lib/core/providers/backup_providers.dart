import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/backup_service.dart';

/// Provider for BackupService instance
final backupServiceProvider = Provider<BackupService>((ref) {
  final service = BackupService();
  
  // Start automatic backup based on settings
  final settings = ref.watch(backupSettingsProvider);
  if (settings != null && settings.autoBackupEnabled) {
    service.startAutomaticBackup(settings.backupIntervalHours);
  }
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for backup settings
final backupSettingsProvider = StateNotifierProvider<BackupSettingsNotifier, BackupSettings?>((ref) {
  return BackupSettingsNotifier();
});

/// Notifier for backup settings
class BackupSettingsNotifier extends StateNotifier<BackupSettings?> {
  static const String _boxName = 'backup_settings';
  static const String _settingsKey = 'settings';
  
  BackupSettingsNotifier() : super(null) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      Box box;
      if (!Hive.isBoxOpen(_boxName)) {
        box = await Hive.openBox(_boxName);
      } else {
        box = Hive.box(_boxName);
      }
      
      final data = box.get(_settingsKey);
      if (data != null && data is Map) {
        state = BackupSettings.fromJson(Map<String, dynamic>.from(data));
      } else {
        // Default settings
        state = BackupSettings(
          autoBackupEnabled: true,
          backupIntervalHours: 24,
          keepBackupCount: 10,
          lastBackupTime: null,
        );
        await _saveSettings();
      }
    } catch (e) {
      print('Error loading backup settings: $e');
      // Use default settings
      state = BackupSettings(
        autoBackupEnabled: true,
        backupIntervalHours: 24,
        keepBackupCount: 10,
        lastBackupTime: null,
      );
    }
  }
  
  Future<void> _saveSettings() async {
    if (state == null) return;
    
    try {
      Box box;
      if (!Hive.isBoxOpen(_boxName)) {
        box = await Hive.openBox(_boxName);
      } else {
        box = Hive.box(_boxName);
      }
      
      await box.put(_settingsKey, state!.toJson());
    } catch (e) {
      print('Error saving backup settings: $e');
    }
  }
  
  Future<void> updateSettings(BackupSettings settings) async {
    state = settings;
    await _saveSettings();
  }
  
  Future<void> updateAutoBackupEnabled(bool enabled) async {
    if (state == null) return;
    state = state!.copyWith(autoBackupEnabled: enabled);
    await _saveSettings();
  }
  
  Future<void> updateBackupInterval(int hours) async {
    if (state == null) return;
    state = state!.copyWith(backupIntervalHours: hours);
    await _saveSettings();
  }
  
  Future<void> updateLastBackupTime(DateTime time) async {
    if (state == null) return;
    state = state!.copyWith(lastBackupTime: time);
    await _saveSettings();
  }
}

/// Provider for available backups list
final availableBackupsProvider = FutureProvider<List<BackupInfo>>((ref) async {
  final backupService = ref.watch(backupServiceProvider);
  return await backupService.getAvailableBackups();
});

/// Provider to trigger manual backup
final manualBackupProvider = FutureProvider.autoDispose<BackupResult>((ref) async {
  final backupService = ref.watch(backupServiceProvider);
  return await backupService.createBackup();
});

/// Backup settings model
class BackupSettings {
  final bool autoBackupEnabled;
  final int backupIntervalHours;
  final int keepBackupCount;
  final DateTime? lastBackupTime;
  
  BackupSettings({
    required this.autoBackupEnabled,
    required this.backupIntervalHours,
    required this.keepBackupCount,
    this.lastBackupTime,
  });
  
  BackupSettings copyWith({
    bool? autoBackupEnabled,
    int? backupIntervalHours,
    int? keepBackupCount,
    DateTime? lastBackupTime,
  }) {
    return BackupSettings(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupIntervalHours: backupIntervalHours ?? this.backupIntervalHours,
      keepBackupCount: keepBackupCount ?? this.keepBackupCount,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'autoBackupEnabled': autoBackupEnabled,
      'backupIntervalHours': backupIntervalHours,
      'keepBackupCount': keepBackupCount,
      'lastBackupTime': lastBackupTime?.toIso8601String(),
    };
  }
  
  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    return BackupSettings(
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? true,
      backupIntervalHours: json['backupIntervalHours'] as int? ?? 24,
      keepBackupCount: json['keepBackupCount'] as int? ?? 10,
      lastBackupTime: json['lastBackupTime'] != null
          ? DateTime.parse(json['lastBackupTime'] as String)
          : null,
    );
  }
}

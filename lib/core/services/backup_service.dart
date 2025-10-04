import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// Service for managing automatic database backups
class BackupService {
  static const String _backupFolderName = 'backups';
  static const String _backupFilePrefix = 'backup_';
  static const String _backupFileExtension = '.json';
  
  Timer? _backupTimer;
  
  /// Get the backups directory path
  Future<Directory> getBackupsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/$_backupFolderName');
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir;
  }
  
  /// Start automatic backup timer
  Future<void> startAutomaticBackup(int intervalHours) async {
    // Cancel existing timer if any
    stopAutomaticBackup();
    
    if (intervalHours <= 0) {
      debugPrint('Automatic backup disabled (interval: $intervalHours hours)');
      return;
    }
    
    debugPrint('Starting automatic backup every $intervalHours hour(s)');
    
    // Create initial backup
    await createBackup();
    
    // Schedule periodic backups
    _backupTimer = Timer.periodic(
      Duration(hours: intervalHours),
      (_) async => await createBackup(),
    );
  }
  
  /// Stop automatic backup timer
  void stopAutomaticBackup() {
    _backupTimer?.cancel();
    _backupTimer = null;
    debugPrint('Automatic backup stopped');
  }
  
  /// Create a backup of all Hive boxes
  Future<BackupResult> createBackup() async {
    try {
      debugPrint('Creating backup...');
      
      final backupDir = await getBackupsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final backupFileName = '$_backupFilePrefix$timestamp$_backupFileExtension';
      final backupFile = File('${backupDir.path}/$backupFileName');
      
      // Collect data from all boxes
      final backupData = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
        'boxes': {},
      };
      
      // Get all registered box names
      final boxNames = [
        'clients',
        'articles',
        'receptions',
        'livraisons',
        'factures',
        'treatments',
        'notification_settings',
        'tasks',
      ];
      
      for (final boxName in boxNames) {
        try {
          if (!Hive.isBoxOpen(boxName)) {
            await Hive.openBox(boxName);
          }
          
          final box = Hive.box(boxName);
          final boxData = <String, dynamic>{};
          
          for (final key in box.keys) {
            final value = box.get(key);
            if (value != null) {
              // Convert HiveObject to JSON-serializable format
              if (value is Map) {
                boxData[key.toString()] = Map<String, dynamic>.from(value);
              } else if (value is List) {
                boxData[key.toString()] = List<dynamic>.from(value);
              } else {
                boxData[key.toString()] = value;
              }
            }
          }
          
          backupData['boxes'][boxName] = boxData;
          debugPrint('Backed up $boxName: ${boxData.length} items');
        } catch (e) {
          debugPrint('Error backing up box $boxName: $e');
          // Continue with other boxes
        }
      }
      
      // Write backup file
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      await backupFile.writeAsString(jsonString);
      
      final fileSize = await backupFile.length();
      debugPrint('Backup created successfully: $backupFileName (${_formatBytes(fileSize)})');
      
      // Clean old backups (keep only last 10)
      await _cleanOldBackups(backupDir);
      
      return BackupResult.success(
        filePath: backupFile.path,
        fileName: backupFileName,
        fileSize: fileSize,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error creating backup: $e');
      debugPrint('Stack trace: $stackTrace');
      return BackupResult.failure(error: e.toString());
    }
  }
  
  /// Get list of all available backups
  Future<List<BackupInfo>> getAvailableBackups() async {
    try {
      final backupDir = await getBackupsDirectory();
      final files = backupDir.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith(_backupFileExtension))
          .toList();
      
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      final backups = <BackupInfo>[];
      
      for (final file in files) {
        try {
          final fileSize = await file.length();
          final lastModified = file.lastModifiedSync();
          final fileName = file.path.split(Platform.pathSeparator).last;
          
          // Try to read backup metadata
          final content = await file.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;
          final timestamp = DateTime.parse(data['timestamp'] as String);
          final version = data['version'] as String?;
          
          int totalItems = 0;
          if (data['boxes'] is Map) {
            final boxes = data['boxes'] as Map<String, dynamic>;
            for (final box in boxes.values) {
              if (box is Map) {
                totalItems += (box as Map).length;
              }
            }
          }
          
          backups.add(BackupInfo(
            filePath: file.path,
            fileName: fileName,
            fileSize: fileSize,
            timestamp: timestamp,
            lastModified: lastModified,
            version: version ?? '1.0',
            totalItems: totalItems,
          ));
        } catch (e) {
          debugPrint('Error reading backup file ${file.path}: $e');
          // Add basic info even if we can't read the content
          backups.add(BackupInfo(
            filePath: file.path,
            fileName: file.path.split(Platform.pathSeparator).last,
            fileSize: await file.length(),
            timestamp: file.lastModifiedSync(),
            lastModified: file.lastModifiedSync(),
            version: 'unknown',
            totalItems: 0,
          ));
        }
      }
      
      return backups;
    } catch (e) {
      debugPrint('Error getting available backups: $e');
      return [];
    }
  }
  
  /// Restore database from a backup file
  Future<RestoreResult> restoreBackup(String backupFilePath) async {
    try {
      debugPrint('Restoring backup from: $backupFilePath');
      
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        return RestoreResult.failure(error: 'Backup file not found');
      }
      
      // Read backup file
      final content = await backupFile.readAsString();
      final backupData = jsonDecode(content) as Map<String, dynamic>;
      
      if (backupData['boxes'] == null) {
        return RestoreResult.failure(error: 'Invalid backup format');
      }
      
      final boxes = backupData['boxes'] as Map<String, dynamic>;
      int restoredItems = 0;
      final restoredBoxes = <String>[];
      
      // Restore each box
      for (final entry in boxes.entries) {
        try {
          final boxName = entry.key;
          final boxData = entry.value as Map<String, dynamic>;
          
          // Open or create box
          Box box;
          if (!Hive.isBoxOpen(boxName)) {
            box = await Hive.openBox(boxName);
          } else {
            box = Hive.box(boxName);
          }
          
          // Clear existing data
          await box.clear();
          
          // Restore data
          for (final dataEntry in boxData.entries) {
            await box.put(dataEntry.key, dataEntry.value);
            restoredItems++;
          }
          
          restoredBoxes.add(boxName);
          debugPrint('Restored $boxName: ${boxData.length} items');
        } catch (e) {
          debugPrint('Error restoring box ${entry.key}: $e');
          // Continue with other boxes
        }
      }
      
      debugPrint('Restore completed: $restoredItems items from ${restoredBoxes.length} boxes');
      
      return RestoreResult.success(
        restoredItems: restoredItems,
        restoredBoxes: restoredBoxes,
        backupTimestamp: DateTime.parse(backupData['timestamp'] as String),
      );
    } catch (e, stackTrace) {
      debugPrint('Error restoring backup: $e');
      debugPrint('Stack trace: $stackTrace');
      return RestoreResult.failure(error: e.toString());
    }
  }
  
  /// Delete a backup file
  Future<bool> deleteBackup(String backupFilePath) async {
    try {
      final file = File(backupFilePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted backup: $backupFilePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      return false;
    }
  }
  
  /// Clean old backups, keeping only the specified number
  Future<void> _cleanOldBackups(Directory backupDir, {int keepCount = 10}) async {
    try {
      final files = backupDir.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith(_backupFileExtension))
          .toList();
      
      if (files.length <= keepCount) {
        return;
      }
      
      // Sort by modification time (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      // Delete old backups
      for (int i = keepCount; i < files.length; i++) {
        try {
          await files[i].delete();
          debugPrint('Deleted old backup: ${files[i].path}');
        } catch (e) {
          debugPrint('Error deleting old backup: $e');
        }
      }
    } catch (e) {
      debugPrint('Error cleaning old backups: $e');
    }
  }
  
  /// Format bytes to human-readable size
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  /// Dispose resources
  void dispose() {
    stopAutomaticBackup();
  }
}

/// Result of a backup operation
class BackupResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final DateTime? timestamp;
  final String? error;
  
  BackupResult.success({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.timestamp,
  })  : success = true,
        error = null;
  
  BackupResult.failure({required this.error})
      : success = false,
        filePath = null,
        fileName = null,
        fileSize = null,
        timestamp = null;
}

/// Result of a restore operation
class RestoreResult {
  final bool success;
  final int? restoredItems;
  final List<String>? restoredBoxes;
  final DateTime? backupTimestamp;
  final String? error;
  
  RestoreResult.success({
    required this.restoredItems,
    required this.restoredBoxes,
    required this.backupTimestamp,
  })  : success = true,
        error = null;
  
  RestoreResult.failure({required this.error})
      : success = false,
        restoredItems = null,
        restoredBoxes = null,
        backupTimestamp = null;
}

/// Information about a backup file
class BackupInfo {
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime timestamp;
  final DateTime lastModified;
  final String version;
  final int totalItems;
  
  BackupInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.timestamp,
    required this.lastModified,
    required this.version,
    required this.totalItems,
  });
  
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  String get formattedTimestamp => DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);
  String get formattedLastModified => DateFormat('dd/MM/yyyy HH:mm:ss').format(lastModified);
}

import 'package:hive/hive.dart';

part 'notification_settings_model.g.dart';

@HiveType(typeId: 35)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  final bool enableTaskDeadlineNotifications;

  @HiveField(1)
  final bool enableTaskReminders;

  @HiveField(2)
  final bool enableOverdueTaskNotifications;

  @HiveField(3)
  final bool enableTaskCompletionNotifications;

  @HiveField(4)
  final bool enableSystemTrayNotifications;

  @HiveField(5)
  final List<int> reminderIntervals; // in minutes before deadline

  @HiveField(6)
  final bool enableSounds;

  @HiveField(7)
  final bool enableVibration;

  @HiveField(8)
  final NotificationPriority defaultPriority;

  @HiveField(9)
  final String quietHoursStart; // HH:mm format

  @HiveField(10)
  final String quietHoursEnd; // HH:mm format

  @HiveField(11)
  final bool enableQuietHours;

  @HiveField(12)
  final List<int> quietDays; // 0-6 (Sunday-Saturday)

  @HiveField(13)
  final bool enableWeekendNotifications;

  @HiveField(14)
  final int maxNotificationsPerDay;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  NotificationSettings({
    this.enableTaskDeadlineNotifications = true,
    this.enableTaskReminders = true,
    this.enableOverdueTaskNotifications = true,
    this.enableTaskCompletionNotifications = true,
    this.enableSystemTrayNotifications = true,
    List<int>? reminderIntervals,
    this.enableSounds = true,
    this.enableVibration = true,
    this.defaultPriority = NotificationPriority.normal,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.enableQuietHours = false,
    List<int>? quietDays,
    this.enableWeekendNotifications = true,
    this.maxNotificationsPerDay = 20,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : reminderIntervals = reminderIntervals ?? [1440, 360, 60, 15], // 24h, 6h, 1h, 15min
        quietDays = quietDays ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  NotificationSettings copyWith({
    bool? enableTaskDeadlineNotifications,
    bool? enableTaskReminders,
    bool? enableOverdueTaskNotifications,
    bool? enableTaskCompletionNotifications,
    bool? enableSystemTrayNotifications,
    List<int>? reminderIntervals,
    bool? enableSounds,
    bool? enableVibration,
    NotificationPriority? defaultPriority,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? enableQuietHours,
    List<int>? quietDays,
    bool? enableWeekendNotifications,
    int? maxNotificationsPerDay,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      enableTaskDeadlineNotifications: enableTaskDeadlineNotifications ?? this.enableTaskDeadlineNotifications,
      enableTaskReminders: enableTaskReminders ?? this.enableTaskReminders,
      enableOverdueTaskNotifications: enableOverdueTaskNotifications ?? this.enableOverdueTaskNotifications,
      enableTaskCompletionNotifications: enableTaskCompletionNotifications ?? this.enableTaskCompletionNotifications,
      enableSystemTrayNotifications: enableSystemTrayNotifications ?? this.enableSystemTrayNotifications,
      reminderIntervals: reminderIntervals ?? List.from(this.reminderIntervals),
      enableSounds: enableSounds ?? this.enableSounds,
      enableVibration: enableVibration ?? this.enableVibration,
      defaultPriority: defaultPriority ?? this.defaultPriority,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      enableQuietHours: enableQuietHours ?? this.enableQuietHours,
      quietDays: quietDays ?? List.from(this.quietDays),
      enableWeekendNotifications: enableWeekendNotifications ?? this.enableWeekendNotifications,
      maxNotificationsPerDay: maxNotificationsPerDay ?? this.maxNotificationsPerDay,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableTaskDeadlineNotifications': enableTaskDeadlineNotifications,
      'enableTaskReminders': enableTaskReminders,
      'enableOverdueTaskNotifications': enableOverdueTaskNotifications,
      'enableTaskCompletionNotifications': enableTaskCompletionNotifications,
      'enableSystemTrayNotifications': enableSystemTrayNotifications,
      'reminderIntervals': reminderIntervals,
      'enableSounds': enableSounds,
      'enableVibration': enableVibration,
      'defaultPriority': defaultPriority.toString(),
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'enableQuietHours': enableQuietHours,
      'quietDays': quietDays,
      'enableWeekendNotifications': enableWeekendNotifications,
      'maxNotificationsPerDay': maxNotificationsPerDay,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enableTaskDeadlineNotifications: json['enableTaskDeadlineNotifications'] ?? true,
      enableTaskReminders: json['enableTaskReminders'] ?? true,
      enableOverdueTaskNotifications: json['enableOverdueTaskNotifications'] ?? true,
      enableTaskCompletionNotifications: json['enableTaskCompletionNotifications'] ?? true,
      enableSystemTrayNotifications: json['enableSystemTrayNotifications'] ?? true,
      reminderIntervals: List<int>.from(json['reminderIntervals'] ?? [1440, 360, 60, 15]),
      enableSounds: json['enableSounds'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      defaultPriority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['defaultPriority'],
        orElse: () => NotificationPriority.normal,
      ),
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '08:00',
      enableQuietHours: json['enableQuietHours'] ?? false,
      quietDays: List<int>.from(json['quietDays'] ?? []),
      enableWeekendNotifications: json['enableWeekendNotifications'] ?? true,
      maxNotificationsPerDay: json['maxNotificationsPerDay'] ?? 20,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Check if notifications should be sent at the current time
  bool shouldSendNotificationNow() {
    final now = DateTime.now();
    
    // Check quiet hours
    if (enableQuietHours) {
      if (_isInQuietHours(now)) {
        return false;
      }
    }

    // Check quiet days
    if (quietDays.contains(now.weekday % 7)) {
      return false;
    }

    // Check weekend notifications
    if (!enableWeekendNotifications && (now.weekday == 6 || now.weekday == 7)) {
      return false;
    }

    return true;
  }

  /// Check if the current time is within quiet hours
  bool _isInQuietHours(DateTime time) {
    final currentTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    // Convert time strings to minutes for easier comparison
    final currentMinutes = _timeToMinutes(currentTime);
    final startMinutes = _timeToMinutes(quietHoursStart);
    final endMinutes = _timeToMinutes(quietHoursEnd);
    
    if (startMinutes <= endMinutes) {
      // Same day quiet hours (e.g., 22:00 to 23:59)
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight quiet hours (e.g., 22:00 to 08:00)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  /// Convert time string (HH:mm) to minutes since midnight
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  String toString() {
    return 'NotificationSettings(deadlines: $enableTaskDeadlineNotifications, reminders: $enableTaskReminders, sounds: $enableSounds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
           other.enableTaskDeadlineNotifications == enableTaskDeadlineNotifications &&
           other.enableTaskReminders == enableTaskReminders;
  }

  @override
  int get hashCode => Object.hash(enableTaskDeadlineNotifications, enableTaskReminders);
}

@HiveType(typeId: 36)
enum NotificationPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  normal,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
}
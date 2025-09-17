class NotificationSettings {
  final bool isEnabled;
  final bool showSystemTray;
  final bool playSound;
  final bool showBadge;
  final int defaultReminderMinutes;
  final List<int> reminderIntervals;
  final bool enableQuietHours;
  final String quietStartTime;
  final String quietEndTime;
  final bool enableWeekendMode;
  final Map<String, bool> priorityEnabled;
  final bool enableOverdueReminders;
  final int overdueReminderInterval;

  NotificationSettings({
    this.isEnabled = true,
    this.showSystemTray = true,
    this.playSound = true,
    this.showBadge = true,
    this.defaultReminderMinutes = 15,
    this.reminderIntervals = const [5, 15, 30, 60],
    this.enableQuietHours = false,
    this.quietStartTime = '22:00',
    this.quietEndTime = '08:00',
    this.enableWeekendMode = false,
    this.priorityEnabled = const {
      'urgent': true,
      'high': true,
      'medium': true,
      'low': false,
    },
    this.enableOverdueReminders = true,
    this.overdueReminderInterval = 60,
  });

  NotificationSettings copyWith({
    bool? isEnabled,
    bool? showSystemTray,
    bool? playSound,
    bool? showBadge,
    int? defaultReminderMinutes,
    List<int>? reminderIntervals,
    bool? enableQuietHours,
    String? quietStartTime,
    String? quietEndTime,
    bool? enableWeekendMode,
    Map<String, bool>? priorityEnabled,
    bool? enableOverdueReminders,
    int? overdueReminderInterval,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      showSystemTray: showSystemTray ?? this.showSystemTray,
      playSound: playSound ?? this.playSound,
      showBadge: showBadge ?? this.showBadge,
      defaultReminderMinutes: defaultReminderMinutes ?? this.defaultReminderMinutes,
      reminderIntervals: reminderIntervals ?? this.reminderIntervals,
      enableQuietHours: enableQuietHours ?? this.enableQuietHours,
      quietStartTime: quietStartTime ?? this.quietStartTime,
      quietEndTime: quietEndTime ?? this.quietEndTime,
      enableWeekendMode: enableWeekendMode ?? this.enableWeekendMode,
      priorityEnabled: priorityEnabled ?? this.priorityEnabled,
      enableOverdueReminders: enableOverdueReminders ?? this.enableOverdueReminders,
      overdueReminderInterval: overdueReminderInterval ?? this.overdueReminderInterval,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'showSystemTray': showSystemTray,
      'playSound': playSound,
      'showBadge': showBadge,
      'defaultReminderMinutes': defaultReminderMinutes,
      'reminderIntervals': reminderIntervals,
      'enableQuietHours': enableQuietHours,
      'quietStartTime': quietStartTime,
      'quietEndTime': quietEndTime,
      'enableWeekendMode': enableWeekendMode,
      'priorityEnabled': priorityEnabled,
      'enableOverdueReminders': enableOverdueReminders,
      'overdueReminderInterval': overdueReminderInterval,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      isEnabled: json['isEnabled'] ?? true,
      showSystemTray: json['showSystemTray'] ?? true,
      playSound: json['playSound'] ?? true,
      showBadge: json['showBadge'] ?? true,
      defaultReminderMinutes: json['defaultReminderMinutes'] ?? 15,
      reminderIntervals: List<int>.from(json['reminderIntervals'] ?? [5, 15, 30, 60]),
      enableQuietHours: json['enableQuietHours'] ?? false,
      quietStartTime: json['quietStartTime'] ?? '22:00',
      quietEndTime: json['quietEndTime'] ?? '08:00',
      enableWeekendMode: json['enableWeekendMode'] ?? false,
      priorityEnabled: Map<String, bool>.from(json['priorityEnabled'] ?? {
        'urgent': true,
        'high': true,
        'medium': true,
        'low': false,
      }),
      enableOverdueReminders: json['enableOverdueReminders'] ?? true,
      overdueReminderInterval: json['overdueReminderInterval'] ?? 60,
    );
  }
}
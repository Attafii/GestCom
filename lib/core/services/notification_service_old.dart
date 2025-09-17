import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../database/models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Tunis')); // Tunisia timezone

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // macOS initialization settings
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Linux initialization settings
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );

    // Windows initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      linux: initializationSettingsLinux,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for different platforms
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('NotificationService: Initialized successfully');
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final DarwinFlutterLocalNotificationsPlugin? darwinImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  DarwinFlutterLocalNotificationsPlugin>();

      await darwinImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    
    // Parse the payload to get task information
    if (response.payload != null) {
      final taskId = response.payload!;
      _handleTaskNotificationTap(taskId);
    }
  }

  /// Handle task notification tap (navigate to task details)
  void _handleTaskNotificationTap(String taskId) {
    // TODO: Implement navigation to task details
    // This could integrate with your navigation system
    debugPrint('Navigating to task: $taskId');
  }

  /// Schedule a notification for a task deadline
  Future<void> scheduleTaskDeadlineNotification(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (task.dueDate == null) return;

    final notificationId = _generateNotificationId(task.id);
    final scheduledDate = _calculateNotificationTime(task.dueDate!);

    // Don't schedule notifications for past dates
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('NotificationService: Skipping past date notification for task ${task.title}');
      return;
    }

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_deadlines',
        'Task Deadlines',
        channelDescription: 'Notifications for task deadlines and reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default.caf',
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default.caf',
      ),
      linux: LinuxNotificationDetails(
        actions: [
          LinuxNotificationAction(
            key: 'view_task',
            label: 'View Task',
          ),
          LinuxNotificationAction(
            key: 'mark_complete',
            label: 'Mark Complete',
          ),
        ],
      ),
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        _getNotificationTitle(task),
        _getNotificationBody(task),
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: task.id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('NotificationService: Scheduled notification for task "${task.title}" at $scheduledDate');
    } catch (e) {
      debugPrint('NotificationService: Error scheduling notification: $e');
    }
  }

  /// Schedule multiple reminder notifications for a task
  Future<void> scheduleTaskReminders(Task task) async {
    if (task.dueDate == null) return;

    final reminderTimes = _getReminderTimes(task.dueDate!);
    
    for (int i = 0; i < reminderTimes.length; i++) {
      final reminderTime = reminderTimes[i];
      if (reminderTime.isBefore(DateTime.now())) continue;

      final notificationId = _generateReminderNotificationId(task.id, i);
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Reminder notifications for upcoming tasks',
          importance: Importance.default_,
          priority: Priority.defaultPriority,
          showWhen: true,
          enableVibration: false,
          playSound: false,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
        linux: LinuxNotificationDetails(),
      );

      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          _getReminderTitle(task, reminderTime),
          _getReminderBody(task, reminderTime),
          tz.TZDateTime.from(reminderTime, tz.local),
          notificationDetails,
          payload: task.id,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        debugPrint('NotificationService: Scheduled reminder for task "${task.title}" at $reminderTime');
      } catch (e) {
        debugPrint('NotificationService: Error scheduling reminder: $e');
      }
    }
  }

  /// Show an immediate notification
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'immediate_notifications',
        'Immediate Notifications',
        channelDescription: 'Immediate notifications for important events',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('NotificationService: Showed immediate notification: $title');
    } catch (e) {
      debugPrint('NotificationService: Error showing immediate notification: $e');
    }
  }

  /// Cancel all notifications for a specific task
  Future<void> cancelTaskNotifications(String taskId) async {
    if (!_isInitialized) return;

    try {
      // Cancel main deadline notification
      final mainNotificationId = _generateNotificationId(taskId);
      await _flutterLocalNotificationsPlugin.cancel(mainNotificationId);

      // Cancel all reminder notifications (assuming max 5 reminders)
      for (int i = 0; i < 5; i++) {
        final reminderNotificationId = _generateReminderNotificationId(taskId, i);
        await _flutterLocalNotificationsPlugin.cancel(reminderNotificationId);
      }

      debugPrint('NotificationService: Cancelled notifications for task: $taskId');
    } catch (e) {
      debugPrint('NotificationService: Error cancelling notifications: $e');
    }
  }

  /// Reschedule notifications for a task (useful when task is updated)
  Future<void> rescheduleTaskNotifications(Task task) async {
    await cancelTaskNotifications(task.id);
    
    if (task.status != TaskStatus.completed && task.status != TaskStatus.cancelled) {
      await scheduleTaskDeadlineNotification(task);
      await scheduleTaskReminders(task);
    }
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('NotificationService: Cancelled all notifications');
    } catch (e) {
      debugPrint('NotificationService: Error cancelling all notifications: $e');
    }
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];

    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('NotificationService: Error getting pending notifications: $e');
      return [];
    }
  }

  /// Generate a unique notification ID for a task
  int _generateNotificationId(String taskId) {
    return taskId.hashCode.abs();
  }

  /// Generate a unique notification ID for task reminders
  int _generateReminderNotificationId(String taskId, int reminderIndex) {
    return (taskId + '_reminder_$reminderIndex').hashCode.abs();
  }

  /// Calculate when to show the notification (1 hour before deadline by default)
  DateTime _calculateNotificationTime(DateTime dueDate) {
    return dueDate.subtract(const Duration(hours: 1));
  }

  /// Get reminder times (24h, 6h, 1h, 15min before deadline)
  List<DateTime> _getReminderTimes(DateTime dueDate) {
    return [
      dueDate.subtract(const Duration(days: 1)), // 24 hours before
      dueDate.subtract(const Duration(hours: 6)), // 6 hours before
      dueDate.subtract(const Duration(hours: 1)), // 1 hour before
      dueDate.subtract(const Duration(minutes: 15)), // 15 minutes before
    ];
  }

  /// Get notification title based on task
  String _getNotificationTitle(Task task) {
    switch (task.priority) {
      case TaskPriority.urgent:
        return '🚨 Urgent Task Deadline';
      case TaskPriority.high:
        return '⚡ High Priority Task Deadline';
      case TaskPriority.medium:
        return '📋 Task Deadline';
      case TaskPriority.low:
        return '📌 Low Priority Task Deadline';
    }
  }

  /// Get notification body based on task
  String _getNotificationBody(Task task) {
    final timeLeft = _getTimeLeftString(task.dueDate!);
    return '"${task.title}" is due $timeLeft';
  }

  /// Get reminder notification title
  String _getReminderTitle(Task task, DateTime reminderTime) {
    final timeUntilDue = task.dueDate!.difference(reminderTime);
    
    if (timeUntilDue.inDays >= 1) {
      return '📅 Task Reminder - Due Tomorrow';
    } else if (timeUntilDue.inHours >= 6) {
      return '⏰ Task Reminder - Due Today';
    } else if (timeUntilDue.inHours >= 1) {
      return '⚠️ Task Reminder - Due Soon';
    } else {
      return '🚨 Task Reminder - Due Very Soon';
    }
  }

  /// Get reminder notification body
  String _getReminderBody(Task task, DateTime reminderTime) {
    final timeUntilDue = task.dueDate!.difference(reminderTime);
    String timeLeftString;
    
    if (timeUntilDue.inDays >= 1) {
      timeLeftString = 'tomorrow';
    } else if (timeUntilDue.inHours >= 1) {
      timeLeftString = 'in ${timeUntilDue.inHours} hour${timeUntilDue.inHours > 1 ? 's' : ''}';
    } else {
      timeLeftString = 'in ${timeUntilDue.inMinutes} minute${timeUntilDue.inMinutes > 1 ? 's' : ''}';
    }
    
    return 'Don\'t forget: "${task.title}" is due $timeLeftString';
  }

  /// Get human-readable time left string
  String _getTimeLeftString(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      return 'now (overdue)';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'now';
    }
  }
}
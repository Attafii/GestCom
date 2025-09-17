import 'package:flutter/foundation.dart';
import '../database/models/task_model.dart';
import '../database/services/hive_service.dart';
import '../services/notification_service.dart';

class TaskNotificationManager {
  static final TaskNotificationManager _instance = TaskNotificationManager._internal();
  factory TaskNotificationManager() => _instance;
  TaskNotificationManager._internal();

  final NotificationService _notificationService = NotificationService();
  bool _isInitialized = false;

  /// Initialize the task notification manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _notificationService.initialize();
    await _scheduleExistingTaskNotifications();
    
    _isInitialized = true;
    debugPrint('TaskNotificationManager: Initialized successfully');
  }

  /// Schedule notifications for all existing tasks
  Future<void> _scheduleExistingTaskNotifications() async {
    try {
      final tasks = HiveService.getAllTasks();
      
      for (final task in tasks) {
        if (_shouldScheduleNotification(task)) {
          await _notificationService.scheduleTaskDeadlineNotification(task);
          await _notificationService.scheduleTaskReminders(task);
        }
      }
      
      debugPrint('TaskNotificationManager: Scheduled notifications for ${tasks.length} tasks');
    } catch (e) {
      debugPrint('TaskNotificationManager: Error scheduling existing notifications: $e');
    }
  }

  /// Handle task creation - schedule notifications
  Future<void> onTaskCreated(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_shouldScheduleNotification(task)) {
      await _notificationService.scheduleTaskDeadlineNotification(task);
      await _notificationService.scheduleTaskReminders(task);
      
      debugPrint('TaskNotificationManager: Scheduled notifications for new task: ${task.title}');
    }
  }

  /// Handle task update - reschedule notifications
  Future<void> onTaskUpdated(Task oldTask, Task newTask) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel old notifications
    await _notificationService.cancelTaskNotifications(oldTask.id);

    // Schedule new notifications if needed
    if (_shouldScheduleNotification(newTask)) {
      await _notificationService.scheduleTaskDeadlineNotification(newTask);
      await _notificationService.scheduleTaskReminders(newTask);
      
      debugPrint('TaskNotificationManager: Rescheduled notifications for updated task: ${newTask.title}');
    } else {
      debugPrint('TaskNotificationManager: Cancelled notifications for task: ${newTask.title}');
    }
  }

  /// Handle task deletion - cancel notifications
  Future<void> onTaskDeleted(String taskId) async {
    if (!_isInitialized) return;

    await _notificationService.cancelTaskNotifications(taskId);
    debugPrint('TaskNotificationManager: Cancelled notifications for deleted task: $taskId');
  }

  /// Handle task completion - cancel notifications and show completion notification
  Future<void> onTaskCompleted(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel all pending notifications for this task
    await _notificationService.cancelTaskNotifications(task.id);

    // Show completion notification
    await _notificationService.showImmediateNotification(
      title: '✅ Task Completed',
      body: 'Great job! "${task.title}" has been completed.',
      payload: task.id,
    );

    debugPrint('TaskNotificationManager: Task completed: ${task.title}');
  }

  /// Handle task status change to overdue
  Future<void> onTaskOverdue(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _notificationService.showImmediateNotification(
      title: '⚠️ Task Overdue',
      body: '"${task.title}" is overdue. Please take action.',
      payload: task.id,
    );

    debugPrint('TaskNotificationManager: Task overdue: ${task.title}');
  }

  /// Schedule a custom reminder for a task
  Future<void> scheduleCustomReminder(Task task, DateTime reminderTime, String message) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint('TaskNotificationManager: Cannot schedule reminder for past time');
      return;
    }

    await _notificationService.showImmediateNotification(
      title: '📋 Custom Task Reminder',
      body: message,
      payload: task.id,
    );

    debugPrint('TaskNotificationManager: Scheduled custom reminder for task: ${task.title}');
  }

  /// Check for overdue tasks and send notifications
  Future<void> checkForOverdueTasks() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final tasks = HiveService.getAllTasks();
      final now = DateTime.now();
      
      for (final task in tasks) {
        if (task.dueDate != null && 
            task.dueDate!.isBefore(now) && 
            task.status != TaskStatus.completed &&
            task.status != TaskStatus.cancelled) {
          
          await onTaskOverdue(task);
        }
      }
    } catch (e) {
      debugPrint('TaskNotificationManager: Error checking overdue tasks: $e');
    }
  }

  /// Get all pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _notificationService.getPendingNotifications();
    return pending.length;
  }

  /// Cancel all task notifications
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    debugPrint('TaskNotificationManager: Cancelled all notifications');
  }

  /// Refresh all task notifications (useful after app restart or settings change)
  Future<void> refreshAllNotifications() async {
    await cancelAllNotifications();
    await _scheduleExistingTaskNotifications();
    debugPrint('TaskNotificationManager: Refreshed all notifications');
  }

  /// Check if we should schedule notifications for this task
  bool _shouldScheduleNotification(Task task) {
    // Don't schedule notifications for completed or cancelled tasks
    if (task.status == TaskStatus.completed || task.status == TaskStatus.cancelled) {
      return false;
    }

    // Don't schedule notifications for tasks without due dates
    if (task.dueDate == null) {
      return false;
    }

    // Don't schedule notifications for overdue tasks
    if (task.dueDate!.isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  /// Get task notification summary
  Future<Map<String, dynamic>> getNotificationSummary() async {
    final pending = await _notificationService.getPendingNotifications();
    final tasks = HiveService.getAllTasks();
    
    final activeTasks = tasks.where((task) => 
      task.status != TaskStatus.completed && 
      task.status != TaskStatus.cancelled &&
      task.dueDate != null
    ).toList();

    final overdueTasks = tasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(DateTime.now()) &&
      task.status != TaskStatus.completed &&
      task.status != TaskStatus.cancelled
    ).toList();

    final dueTodayTasks = tasks.where((task) {
      if (task.dueDate == null) return false;
      final today = DateTime.now();
      final dueDate = task.dueDate!;
      return dueDate.year == today.year &&
             dueDate.month == today.month &&
             dueDate.day == today.day &&
             task.status != TaskStatus.completed &&
             task.status != TaskStatus.cancelled;
    }).toList();

    return {
      'pendingNotifications': pending.length,
      'activeTasks': activeTasks.length,
      'overdueTasks': overdueTasks.length,
      'dueTodayTasks': dueTodayTasks.length,
      'upcomingDeadlines': activeTasks.where((task) {
        if (task.dueDate == null) return false;
        final daysUntilDue = task.dueDate!.difference(DateTime.now()).inDays;
        return daysUntilDue <= 7 && daysUntilDue >= 0;
      }).length,
    };
  }
}
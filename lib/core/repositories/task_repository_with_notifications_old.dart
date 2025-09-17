import '../models/task_model.dart';
import '../services/hive_service.dart';
import '../managers/task_notification_manager.dart';

/// Enhanced repository for Task entity operations with notification integration
class TaskRepositoryWithNotifications {
  final TaskNotificationManager _notificationManager = TaskNotificationManager();

  /// Create a new task with validation and notification scheduling
  Future<String> createTask({
    required String title,
    required String description,
    required String assignedUserId,
    String? createdByUserId,
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.general,
    DateTime? dueDate,
    DateTime? startDate,
    List<String>? tags,
    double? estimatedHours,
    String? parentTaskId,
  }) async {
    // Validate assigned user exists
    final assignedUser = HiveService.getUser(assignedUserId);
    if (assignedUser == null) {
      throw Exception('Assigned user not found');
    }

    // Validate created by user exists (if provided)
    if (createdByUserId != null) {
      final createdByUser = HiveService.getUser(createdByUserId);
      if (createdByUser == null) {
        throw Exception('Creating user not found');
      }
    }

    // Validate parent task exists and is not completed (if provided)
    if (parentTaskId != null) {
      final parentTask = HiveService.getTask(parentTaskId);
      if (parentTask == null) {
        throw Exception('Parent task not found');
      }
      if (parentTask.status == TaskStatus.completed) {
        throw Exception('Cannot add subtask to completed task');
      }
    }

    // Validate due date is not in the past
    if (dueDate != null && dueDate.isBefore(DateTime.now())) {
      throw Exception('Due date cannot be in the past');
    }

    // Validate start date is before due date
    if (startDate != null && dueDate != null && startDate.isAfter(dueDate)) {
      throw Exception('Start date cannot be after due date');
    }

    // Create the task
    final task = Task(
      title: title,
      description: description,
      assignedUserId: assignedUserId,
      createdByUserId: createdByUserId,
      priority: priority,
      category: category,
      dueDate: dueDate,
      startDate: startDate,
      tags: tags ?? [],
      estimatedHours: estimatedHours,
      parentTaskId: parentTaskId,
    );

    // Save task to Hive
    final taskId = await HiveService.createTask(task);

    // Schedule notifications for the new task
    await _notificationManager.onTaskCreated(task);

    // Send assignment notification
    if (assignedUserId != createdByUserId) {
      await _notificationManager.scheduleCustomReminder(
        task,
        DateTime.now(),
        'You have been assigned a new task: "$title"',
      );
    }

    return taskId;
  }

  /// Update an existing task with notification rescheduling
  Future<bool> updateTask(String id, {
    String? title,
    String? description,
    String? assignedUserId,
    TaskPriority? priority,
    TaskCategory? category,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? startDate,
    List<String>? tags,
    double? estimatedHours,
    double? actualHours,
    int? progressPercentage,
    Map<String, dynamic>? metadata,
  }) async {
    final existingTask = HiveService.getTask(id);
    if (existingTask == null) {
      throw Exception('Task not found');
    }

    // Validate new assigned user exists (if provided)
    if (assignedUserId != null && assignedUserId != existingTask.assignedUserId) {
      final assignedUser = HiveService.getUser(assignedUserId);
      if (assignedUser == null) {
        throw Exception('Assigned user not found');
      }
    }

    // Validate due date is not in the past (if provided and not completed)
    final newStatus = status ?? existingTask.status;
    if (dueDate != null && 
        dueDate.isBefore(DateTime.now()) && 
        newStatus != TaskStatus.completed) {
      throw Exception('Due date cannot be in the past for active tasks');
    }

    // Validate start date is before due date
    final newStartDate = startDate ?? existingTask.startDate;
    final newDueDate = dueDate ?? existingTask.dueDate;
    if (newStartDate != null && 
        newDueDate != null && 
        newStartDate.isAfter(newDueDate)) {
      throw Exception('Start date cannot be after due date');
    }

    // Validate progress percentage
    if (progressPercentage != null && 
        (progressPercentage < 0 || progressPercentage > 100)) {
      throw Exception('Progress percentage must be between 0 and 100');
    }

    // Update task
    final updatedTask = existingTask.copyWith(
      title: title,
      description: description,
      assignedUserId: assignedUserId,
      priority: priority,
      category: category,
      status: status,
      dueDate: dueDate,
      startDate: startDate,
      tags: tags,
      estimatedHours: estimatedHours,
      actualHours: actualHours,
      progressPercentage: progressPercentage,
      metadata: metadata,
      updatedAt: DateTime.now(),
    );

    // Update subtask progress if this is a parent task
    if (status == TaskStatus.completed) {
      await _updateSubtaskProgress(id);
    }

    // Save updated task
    final success = await HiveService.updateTask(updatedTask);
    
    if (success) {
      // Handle status changes
      if (status != null && status != existingTask.status) {
        await _handleStatusChange(existingTask, updatedTask);
      } else {
        // Reschedule notifications for updated task
        await _notificationManager.onTaskUpdated(existingTask, updatedTask);
      }

      // Send reassignment notification
      if (assignedUserId != null && assignedUserId != existingTask.assignedUserId) {
        await _notificationManager.scheduleCustomReminder(
          updatedTask,
          DateTime.now(),
          'Task "$title" has been reassigned to you',
        );
      }
    }

    return success;
  }

  /// Delete a task with notification cleanup
  Future<bool> deleteTask(String id, {bool deleteSubtasks = false}) async {
    final task = HiveService.getTask(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    // Handle subtasks
    final subtasks = getSubtasks(id);
    for (final subtask in subtasks) {
      if (deleteSubtasks) {
        // Recursively delete subtasks and their notifications
        await deleteTask(subtask.id, deleteSubtasks: true);
      } else {
        // Remove parent reference and cancel notifications
        await updateTask(subtask.id, metadata: {'parentTaskId': null});
      }
    }

    // Cancel all notifications for this task
    await _notificationManager.onTaskDeleted(id);

    // Delete the task
    return await HiveService.deleteTask(id);
  }

  /// Mark task as completed with notification
  Future<bool> completeTask(String id) async {
    final task = HiveService.getTask(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    if (task.status == TaskStatus.completed) {
      return true; // Already completed
    }

    // Update task status
    final updatedTask = task.copyWith(
      status: TaskStatus.completed,
      progressPercentage: 100,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await HiveService.updateTask(updatedTask);
    
    if (success) {
      // Send completion notification
      await _notificationManager.onTaskCompleted(updatedTask);
      
      // Update parent task progress
      if (task.parentTaskId != null) {
        await _updateParentTaskProgress(task.parentTaskId!);
      }
    }

    return success;
  }

  /// Cancel/Archive a task with notification cleanup
  Future<bool> cancelTask(String id, String reason) async {
    final task = HiveService.getTask(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    final updatedTask = task.copyWith(
      status: TaskStatus.cancelled,
      metadata: {
        ...task.metadata,
        'cancellationReason': reason,
        'cancelledAt': DateTime.now().toIso8601String(),
      },
      updatedAt: DateTime.now(),
    );

    final success = await HiveService.updateTask(updatedTask);
    
    if (success) {
      // Cancel all notifications for this task
      await _notificationManager.onTaskDeleted(id);
    }

    return success;
  }

  /// Get overdue tasks and trigger notifications
  Future<List<Task>> checkOverdueTasks() async {
    final now = DateTime.now();
    final tasks = HiveService.getAllTasks();
    
    final overdueTasks = tasks.where((task) =>
      task.dueDate != null &&
      task.dueDate!.isBefore(now) &&
      task.status != TaskStatus.completed &&
      task.status != TaskStatus.cancelled
    ).toList();

    // Send overdue notifications
    for (final task in overdueTasks) {
      await _notificationManager.onTaskOverdue(task);
    }

    return overdueTasks;
  }

  /// Schedule a custom reminder for a task
  Future<void> scheduleCustomReminder({
    required String taskId,
    required DateTime reminderTime,
    required String message,
  }) async {
    final task = HiveService.getTask(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    await _notificationManager.scheduleCustomReminder(task, reminderTime, message);
  }

  /// Get tasks due within specified days with notification scheduling
  List<Task> getTasksDueSoon({int days = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    final tasks = HiveService.getAllTasks();
    
    return tasks.where((task) =>
      task.dueDate != null &&
      task.dueDate!.isBefore(cutoffDate) &&
      task.dueDate!.isAfter(DateTime.now()) &&
      task.status != TaskStatus.completed &&
      task.status != TaskStatus.cancelled
    ).toList();
  }

  /// Initialize notification system for all existing tasks
  Future<void> initializeNotifications() async {
    await _notificationManager.initialize();
  }

  /// Refresh all task notifications
  Future<void> refreshNotifications() async {
    await _notificationManager.refreshAllNotifications();
  }

  /// Get notification summary for tasks
  Future<Map<String, dynamic>> getNotificationSummary() async {
    return await _notificationManager.getNotificationSummary();
  }

  // Helper method to handle status changes
  Future<void> _handleStatusChange(Task oldTask, Task newTask) async {
    switch (newTask.status) {
      case TaskStatus.completed:
        await _notificationManager.onTaskCompleted(newTask);
        break;
      case TaskStatus.cancelled:
        await _notificationManager.onTaskDeleted(newTask.id);
        break;
      default:
        // For other status changes, just reschedule notifications
        await _notificationManager.onTaskUpdated(oldTask, newTask);
        break;
    }
  }

  // Helper method to update subtask progress when parent is completed
  Future<void> _updateSubtaskProgress(String parentTaskId) async {
    final subtasks = getSubtasks(parentTaskId);
    for (final subtask in subtasks) {
      if (subtask.status != TaskStatus.completed) {
        await updateTask(subtask.id, status: TaskStatus.completed);
      }
    }
  }

  // Helper method to update parent task progress based on subtasks
  Future<void> _updateParentTaskProgress(String parentTaskId) async {
    final subtasks = getSubtasks(parentTaskId);
    if (subtasks.isEmpty) return;

    final completedSubtasks = subtasks.where((t) => t.status == TaskStatus.completed).length;
    final progressPercentage = (completedSubtasks / subtasks.length * 100).round();

    await updateTask(parentTaskId, progressPercentage: progressPercentage);

    // If all subtasks are completed, complete the parent task
    if (completedSubtasks == subtasks.length) {
      await updateTask(parentTaskId, status: TaskStatus.completed);
    }
  }

  // Delegate other methods to the original repository
  List<Task> getAllTasks() => HiveService.getAllTasks();
  
  Task? getTaskById(String id) => HiveService.getTask(id);
  
  List<Task> getTasksByUser(String userId) {
    return HiveService.getAllTasks()
        .where((task) => task.assignedUserId == userId)
        .toList();
  }
  
  List<Task> getSubtasks(String parentTaskId) {
    return HiveService.getAllTasks()
        .where((task) => task.parentTaskId == parentTaskId)
        .toList();
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return HiveService.getAllTasks()
        .where((task) => task.status == status)
        .toList();
  }

  List<Task> getTasksByPriority(TaskPriority priority) {
    return HiveService.getAllTasks()
        .where((task) => task.priority == priority)
        .toList();
  }

  List<Task> getTasksByDateRange(DateTime startDate, DateTime endDate) {
    return HiveService.getAllTasks()
        .where((task) =>
            task.dueDate != null &&
            task.dueDate!.isAfter(startDate.subtract(const Duration(days: 1))) &&
            task.dueDate!.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }
}
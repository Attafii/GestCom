import '../models/task_model.dart';
import '../services/hive_service.dart';

/// Repository for Task entity operations with business logic
class TaskRepository {
  /// Create a new task with validation
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

    // Validate parent task exists (if provided)
    if (parentTaskId != null) {
      final parentTask = HiveService.getTask(parentTaskId);
      if (parentTask == null) {
        throw Exception('Parent task not found');
      }
    }

    final task = Task(
      title: title,
      description: description,
      assignedUserId: assignedUserId,
      createdByUserId: createdByUserId,
      priority: priority,
      category: category,
      dueDate: dueDate,
      startDate: startDate,
      tags: tags,
      estimatedHours: estimatedHours,
      parentTaskId: parentTaskId,
    );

    final taskId = await HiveService.createTask(task);

    // Update parent task's subtask list if this is a subtask
    if (parentTaskId != null) {
      await _addSubtaskToParent(parentTaskId, taskId);
    }

    return taskId;
  }

  /// Get task by ID
  Task? getTaskById(String id) {
    return HiveService.getTask(id);
  }

  /// Get all tasks with optional filtering
  List<Task> getAllTasks({
    String? assignedUserId,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDateBefore,
    DateTime? dueDateAfter,
    List<String>? tags,
  }) {
    var tasks = HiveService.getAllTasks();

    if (assignedUserId != null) {
      tasks = tasks.where((task) => task.assignedUserId == assignedUserId).toList();
    }

    if (status != null) {
      tasks = tasks.where((task) => task.status == status).toList();
    }

    if (priority != null) {
      tasks = tasks.where((task) => task.priority == priority).toList();
    }

    if (category != null) {
      tasks = tasks.where((task) => task.category == category).toList();
    }

    if (dueDateBefore != null) {
      tasks = tasks.where((task) => 
          task.dueDate != null && task.dueDate!.isBefore(dueDateBefore)).toList();
    }

    if (dueDateAfter != null) {
      tasks = tasks.where((task) => 
          task.dueDate != null && task.dueDate!.isAfter(dueDateAfter)).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      tasks = tasks.where((task) => 
          tags.any((tag) => task.tags.contains(tag))).toList();
    }

    return tasks;
  }

  /// Update task
  Future<bool> updateTask(String id, {
    String? title,
    String? description,
    String? assignedUserId,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedAt,
    List<String>? tags,
    double? estimatedHours,
    double? actualHours,
    int? progressPercentage,
    Map<String, dynamic>? metadata,
  }) async {
    final task = HiveService.getTask(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    // Validate assigned user exists (if changing)
    if (assignedUserId != null && assignedUserId != task.assignedUserId) {
      final assignedUser = HiveService.getUser(assignedUserId);
      if (assignedUser == null) {
        throw Exception('Assigned user not found');
      }
    }

    // Auto-set completedAt when status changes to completed
    DateTime? finalCompletedAt = completedAt;
    if (status == TaskStatus.completed && task.status != TaskStatus.completed) {
      finalCompletedAt = DateTime.now();
    } else if (status != TaskStatus.completed) {
      finalCompletedAt = null;
    }

    // Auto-set startDate when status changes to inProgress
    DateTime? finalStartDate = startDate ?? task.startDate;
    if (status == TaskStatus.inProgress && task.status != TaskStatus.inProgress && finalStartDate == null) {
      finalStartDate = DateTime.now();
    }

    final updatedTask = task.copyWith(
      title: title,
      description: description,
      assignedUserId: assignedUserId,
      status: status,
      priority: priority,
      category: category,
      dueDate: dueDate,
      startDate: finalStartDate,
      completedAt: finalCompletedAt,
      tags: tags,
      estimatedHours: estimatedHours,
      actualHours: actualHours,
      progressPercentage: progressPercentage,
      metadata: metadata,
    );

    return await HiveService.updateTask(updatedTask);
  }

  /// Delete task and handle subtasks
  Future<bool> deleteTask(String id, {bool deleteSubtasks = false}) async {
    final task = HiveService.getTask(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    // Handle subtasks
    if (task.hasSubtasks) {
      if (deleteSubtasks) {
        // Delete all subtasks
        for (final subtaskId in task.subtaskIds) {
          await deleteTask(subtaskId, deleteSubtasks: true);
        }
      } else {
        // Remove parent reference from subtasks
        for (final subtaskId in task.subtaskIds) {
          await updateTask(subtaskId, metadata: {'parentTaskId': null});
        }
      }
    }

    // Remove from parent task's subtask list if this is a subtask
    if (task.isSubtask) {
      await _removeSubtaskFromParent(task.parentTaskId!, id);
    }

    return await HiveService.deleteTask(id);
  }

  /// Get tasks assigned to user
  List<Task> getTasksForUser(String userId) {
    return HiveService.getTasksByUser(userId);
  }

  /// Get tasks by status
  List<Task> getTasksByStatus(TaskStatus status) {
    return HiveService.getTasksByStatus(status);
  }

  /// Get overdue tasks
  List<Task> getOverdueTasks() {
    return HiveService.getOverdueTasks();
  }

  /// Get tasks due soon (within specified days)
  List<Task> getTasksDueSoon({int days = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    final tasks = HiveService.getAllTasks();
    
    return tasks.where((task) =>
        task.dueDate != null &&
        task.dueDate!.isBefore(cutoffDate) &&
        task.dueDate!.isAfter(DateTime.now()) &&
        !task.isCompleted
    ).toList();
  }

  /// Search tasks
  List<Task> searchTasks(String query) {
    return HiveService.searchTasks(query);
  }

  /// Add comment to task
  Future<bool> addComment(String taskId, String content, String authorUserId) async {
    final task = HiveService.getTask(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    final comment = TaskComment(
      content: content,
      authorUserId: authorUserId,
    );

    final updatedComments = List<TaskComment>.from(task.comments)..add(comment);
    
    final updatedTask = task.copyWith(comments: updatedComments);
    return await HiveService.updateTask(updatedTask);
  }

  /// Add attachment to task
  Future<bool> addAttachment(String taskId, {
    required String fileName,
    required String filePath,
    required String mimeType,
    required int fileSize,
    required String uploadedByUserId,
  }) async {
    final task = HiveService.getTask(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    final attachment = TaskAttachment(
      fileName: fileName,
      filePath: filePath,
      mimeType: mimeType,
      fileSize: fileSize,
      uploadedByUserId: uploadedByUserId,
    );

    final updatedAttachments = List<TaskAttachment>.from(task.attachments)..add(attachment);
    
    final updatedTask = task.copyWith(attachments: updatedAttachments);
    return await HiveService.updateTask(updatedTask);
  }

  /// Get task statistics
  Map<String, dynamic> getTaskStatistics({String? userId}) {
    List<Task> tasks = HiveService.getAllTasks();
    
    if (userId != null) {
      tasks = tasks.where((task) => task.assignedUserId == userId).toList();
    }

    final stats = <String, dynamic>{
      'total': tasks.length,
      'completed': tasks.where((t) => t.status == TaskStatus.completed).length,
      'inProgress': tasks.where((t) => t.status == TaskStatus.inProgress).length,
      'todo': tasks.where((t) => t.status == TaskStatus.todo).length,
      'overdue': tasks.where((t) => t.isOverdue).length,
      'byPriority': <String, int>{},
      'byCategory': <String, int>{},
    };

    // Count by priority
    for (final priority in TaskPriority.values) {
      stats['byPriority'][priority.toString()] = tasks.where((t) => t.priority == priority).length;
    }

    // Count by category
    for (final category in TaskCategory.values) {
      stats['byCategory'][category.toString()] = tasks.where((t) => t.category == category).length;
    }

    // Calculate completion rate
    if (tasks.isNotEmpty) {
      stats['completionRate'] = (stats['completed'] / tasks.length * 100).round();
    } else {
      stats['completionRate'] = 0;
    }

    return stats;
  }

  /// Get subtasks for a parent task
  List<Task> getSubtasks(String parentTaskId) {
    final parentTask = HiveService.getTask(parentTaskId);
    if (parentTask == null) return [];

    return parentTask.subtaskIds
        .map((id) => HiveService.getTask(id))
        .where((task) => task != null)
        .cast<Task>()
        .toList();
  }

  /// Helper method to add subtask to parent
  Future<void> _addSubtaskToParent(String parentTaskId, String subtaskId) async {
    final parentTask = HiveService.getTask(parentTaskId);
    if (parentTask != null) {
      final updatedSubtaskIds = List<String>.from(parentTask.subtaskIds)..add(subtaskId);
      final updatedParentTask = parentTask.copyWith(subtaskIds: updatedSubtaskIds);
      await HiveService.updateTask(updatedParentTask);
    }
  }

  /// Helper method to remove subtask from parent
  Future<void> _removeSubtaskFromParent(String parentTaskId, String subtaskId) async {
    final parentTask = HiveService.getTask(parentTaskId);
    if (parentTask != null) {
      final updatedSubtaskIds = List<String>.from(parentTask.subtaskIds)..remove(subtaskId);
      final updatedParentTask = parentTask.copyWith(subtaskIds: updatedSubtaskIds);
      await HiveService.updateTask(updatedParentTask);
    }
  }

  /// Mark task as completed
  Future<bool> completeTask(String id, {double? actualHours}) async {
    return await updateTask(
      id,
      status: TaskStatus.completed,
      progressPercentage: 100,
      actualHours: actualHours,
      completedAt: DateTime.now(),
    );
  }

  /// Start task (mark as in progress)
  Future<bool> startTask(String id) async {
    return await updateTask(
      id,
      status: TaskStatus.inProgress,
      startDate: DateTime.now(),
    );
  }
}
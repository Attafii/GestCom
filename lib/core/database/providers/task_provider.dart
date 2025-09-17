import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

/// Provider for TaskRepository instance
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

/// Provider for all tasks
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getAllTasks();
});

/// Provider for a specific task by ID
final taskProvider = FutureProvider.family<Task?, String>((ref, taskId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTaskById(taskId);
});

/// Provider for tasks assigned to a specific user
final userTasksProvider = FutureProvider.family<List<Task>, String>((ref, userId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksForUser(userId);
});

/// Provider for tasks by status
final tasksByStatusProvider = FutureProvider.family<List<Task>, TaskStatus>((ref, status) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksByStatus(status);
});

/// Provider for overdue tasks
final overdueTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getOverdueTasks();
});

/// Provider for tasks due soon
final tasksDueSoonProvider = FutureProvider.family<List<Task>, int>((ref, days) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksDueSoon(days: days);
});

/// Provider for task search results
final taskSearchProvider = StateNotifierProvider<TaskSearchNotifier, AsyncValue<List<Task>>>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return TaskSearchNotifier(repository);
});

/// Provider for task statistics
final taskStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, userId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTaskStatistics(userId: userId);
});

/// Provider for subtasks of a parent task
final subtasksProvider = FutureProvider.family<List<Task>, String>((ref, parentTaskId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getSubtasks(parentTaskId);
});

/// State notifier for task search functionality
class TaskSearchNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;
  String _lastQuery = '';

  TaskSearchNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> searchTasks(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      _lastQuery = '';
      return;
    }

    if (query == _lastQuery) return;

    state = const AsyncValue.loading();
    _lastQuery = query;

    try {
      final results = _repository.searchTasks(query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
    _lastQuery = '';
  }
}

/// Provider for task operations (create, update, delete)
final taskOperationsProvider = StateNotifierProvider<TaskOperationsNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return TaskOperationsNotifier(repository, ref);
});

/// State notifier for task operations
class TaskOperationsNotifier extends StateNotifier<AsyncValue<String?>> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<String?> createTask({
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
    state = const AsyncValue.loading();

    try {
      final taskId = await _repository.createTask(
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

      state = AsyncValue.data(taskId);
      
      // Refresh related providers
      _refreshTaskProviders(assignedUserId, parentTaskId);

      return taskId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

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
    state = const AsyncValue.loading();

    try {
      final task = _repository.getTaskById(id);
      final oldAssignedUserId = task?.assignedUserId;

      final success = await _repository.updateTask(
        id,
        title: title,
        description: description,
        assignedUserId: assignedUserId,
        status: status,
        priority: priority,
        category: category,
        dueDate: dueDate,
        startDate: startDate,
        completedAt: completedAt,
        tags: tags,
        estimatedHours: estimatedHours,
        actualHours: actualHours,
        progressPercentage: progressPercentage,
        metadata: metadata,
      );

      state = AsyncValue.data(success ? id : null);

      if (success) {
        // Refresh related providers
        _refreshTaskProviders(oldAssignedUserId, task?.parentTaskId);
        if (assignedUserId != null && assignedUserId != oldAssignedUserId) {
          _refreshTaskProviders(assignedUserId, null);
        }
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteTask(String id, {bool deleteSubtasks = false}) async {
    state = const AsyncValue.loading();

    try {
      final task = _repository.getTaskById(id);
      final assignedUserId = task?.assignedUserId;
      final parentTaskId = task?.parentTaskId;

      final success = await _repository.deleteTask(id, deleteSubtasks: deleteSubtasks);
      state = AsyncValue.data(success ? id : null);

      if (success) {
        // Refresh related providers
        _refreshTaskProviders(assignedUserId, parentTaskId);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> completeTask(String id, {double? actualHours}) async {
    return await updateTask(
      id,
      status: TaskStatus.completed,
      progressPercentage: 100,
      actualHours: actualHours,
      completedAt: DateTime.now(),
    );
  }

  Future<bool> startTask(String id) async {
    return await updateTask(
      id,
      status: TaskStatus.inProgress,
      startDate: DateTime.now(),
    );
  }

  Future<bool> addComment(String taskId, String content, String authorUserId) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.addComment(taskId, content, authorUserId);
      state = AsyncValue.data(success ? taskId : null);

      if (success) {
        _ref.invalidate(taskProvider(taskId));
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> addAttachment(String taskId, {
    required String fileName,
    required String filePath,
    required String mimeType,
    required int fileSize,
    required String uploadedByUserId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.addAttachment(
        taskId,
        fileName: fileName,
        filePath: filePath,
        mimeType: mimeType,
        fileSize: fileSize,
        uploadedByUserId: uploadedByUserId,
      );

      state = AsyncValue.data(success ? taskId : null);

      if (success) {
        _ref.invalidate(taskProvider(taskId));
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  void _refreshTaskProviders(String? userId, String? parentTaskId) {
    _ref.invalidate(tasksProvider);
    _ref.invalidate(overdueTasksProvider);
    _ref.invalidate(taskStatisticsProvider(userId));
    _ref.invalidate(taskStatisticsProvider(null));

    if (userId != null) {
      _ref.invalidate(userTasksProvider(userId));
    }

    if (parentTaskId != null) {
      _ref.invalidate(subtasksProvider(parentTaskId));
      _ref.invalidate(taskProvider(parentTaskId));
    }

    // Refresh status-based providers
    for (final status in TaskStatus.values) {
      _ref.invalidate(tasksByStatusProvider(status));
    }
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for filtered tasks
final filteredTasksProvider = StateNotifierProvider<TaskFilterNotifier, TaskFilter>((ref) {
  return TaskFilterNotifier();
});

/// Task filter state
class TaskFilter {
  final String? assignedUserId;
  final TaskStatus? status;
  final TaskPriority? priority;
  final TaskCategory? category;
  final DateTime? dueDateBefore;
  final DateTime? dueDateAfter;
  final List<String>? tags;

  const TaskFilter({
    this.assignedUserId,
    this.status,
    this.priority,
    this.category,
    this.dueDateBefore,
    this.dueDateAfter,
    this.tags,
  });

  TaskFilter copyWith({
    String? assignedUserId,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDateBefore,
    DateTime? dueDateAfter,
    List<String>? tags,
  }) {
    return TaskFilter(
      assignedUserId: assignedUserId ?? this.assignedUserId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDateBefore: dueDateBefore ?? this.dueDateBefore,
      dueDateAfter: dueDateAfter ?? this.dueDateAfter,
      tags: tags ?? this.tags,
    );
  }
}

/// State notifier for task filtering
class TaskFilterNotifier extends StateNotifier<TaskFilter> {
  TaskFilterNotifier() : super(const TaskFilter());

  void updateFilter({
    String? assignedUserId,
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDateBefore,
    DateTime? dueDateAfter,
    List<String>? tags,
  }) {
    state = state.copyWith(
      assignedUserId: assignedUserId,
      status: status,
      priority: priority,
      category: category,
      dueDateBefore: dueDateBefore,
      dueDateAfter: dueDateAfter,
      tags: tags,
    );
  }

  void clearFilter() {
    state = const TaskFilter();
  }
}

/// Provider for filtered tasks results
final filteredTasksResultsProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  final filter = ref.watch(filteredTasksProvider);

  return repository.getAllTasks(
    assignedUserId: filter.assignedUserId,
    status: filter.status,
    priority: filter.priority,
    category: filter.category,
    dueDateBefore: filter.dueDateBefore,
    dueDateAfter: filter.dueDateAfter,
    tags: filter.tags,
  );
});
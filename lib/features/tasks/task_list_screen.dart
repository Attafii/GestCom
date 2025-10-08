import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/models/task_model.dart';
import '../../core/database/providers/task_provider.dart';
import 'widgets/task_list_card.dart';
import 'widgets/task_form_dialog.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _searchController = TextEditingController();
  bool _showFilters = false;
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final taskOperations = ref.read(taskOperationsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Tâches'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filtrer',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTaskDialog(context),
            tooltip: 'Ajouter une tâche',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une tâche...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchController.clear());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Filters panel
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<TaskStatus?>(
                          value: _filterStatus,
                          decoration: const InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Tous')),
                            ...TaskStatus.values.map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(_getStatusLabel(status)),
                            )),
                          ],
                          onChanged: (value) => setState(() => _filterStatus = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<TaskPriority?>(
                          value: _filterPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priorité',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Toutes')),
                            ...TaskPriority.values.map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(_getPriorityLabel(priority)),
                            )),
                          ],
                          onChanged: (value) => setState(() => _filterPriority = value),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear_all),
                        onPressed: () {
                          setState(() {
                            _filterStatus = null;
                            _filterPriority = null;
                          });
                        },
                        tooltip: 'Effacer les filtres',
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Task list
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                // Apply search filter
                var filteredTasks = tasks;
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  filteredTasks = tasks.where((task) =>
                    task.title.toLowerCase().contains(query) ||
                    task.description.toLowerCase().contains(query)
                  ).toList();
                }

                // Apply status filter
                if (_filterStatus != null) {
                  filteredTasks = filteredTasks.where((task) => task.status == _filterStatus).toList();
                }

                // Apply priority filter
                if (_filterPriority != null) {
                  filteredTasks = filteredTasks.where((task) => task.priority == _filterPriority).toList();
                }

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tasks.isEmpty ? 'Aucune tâche' : 'Aucun résultat',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tasks.isEmpty
                              ? 'Cliquez sur + pour ajouter votre première tâche'
                              : 'Essayez de modifier vos critères de recherche',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Stats summary
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total',
                            filteredTasks.length.toString(),
                            AppColors.primary,
                          ),
                          _buildStatItem(
                            'Complétées',
                            filteredTasks.where((t) => t.isCompleted).length.toString(),
                            Colors.green,
                          ),
                          _buildStatItem(
                            'En cours',
                            filteredTasks.where((t) => t.status == TaskStatus.inProgress).length.toString(),
                            Colors.orange,
                          ),
                          _buildStatItem(
                            'En retard',
                            filteredTasks.where((t) => t.isOverdue).length.toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return TaskListCard(
                            task: task,
                            onTap: () => _showTaskDetails(context, task),
                            onEdit: () => _showTaskDialog(context, task),
                            onDelete: () => _deleteTask(context, taskOperations, task),
                            onToggleComplete: () => _toggleTaskComplete(taskOperations, task),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _showTaskDialog(BuildContext context, [Task? task]) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => TaskFormDialog(task: task),
    );

    if (result != null) {
      final taskOperations = ref.read(taskOperationsProvider.notifier);
      
      if (task == null) {
        // Create new task
        await taskOperations.createTask(
          title: result.title,
          description: result.description,
          assignedUserId: result.assignedUserId,
          priority: result.priority,
          category: result.category,
          dueDate: result.dueDate,
          tags: result.tags,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tâche créée avec succès')),
          );
        }
      } else {
        // Update existing task
        await taskOperations.updateTask(
          task.id,
          title: result.title,
          description: result.description,
          assignedUserId: result.assignedUserId,
          priority: result.priority,
          category: result.category,
          dueDate: result.dueDate,
          tags: result.tags,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tâche mise à jour')),
          );
        }
      }

      // Refresh the tasks list
      ref.invalidate(tasksProvider);
    }
  }

  Future<void> _toggleTaskComplete(TaskOperationsNotifier taskOperations, Task task) async {
    if (task.isCompleted) {
      // Reopen task
      await taskOperations.updateTask(
        task.id,
        status: TaskStatus.todo,
        progressPercentage: 0,
        completedAt: null,
      );
    } else {
      // Complete task
      await taskOperations.completeTask(task.id);
    }

    // Refresh the tasks list
    ref.invalidate(tasksProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(task.isCompleted ? 'Tâche rouverte' : 'Tâche complétée'),
        ),
      );
    }
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => _TaskDetailsDialog(task: task),
    );
  }

  void _deleteTask(BuildContext context, TaskOperationsNotifier taskOperations, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${task.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await taskOperations.deleteTask(task.id);
              ref.invalidate(tasksProvider);
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tâche supprimée')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.completed:
        return 'Complétée';
      case TaskStatus.cancelled:
        return 'Annulée';
      case TaskStatus.onHold:
        return 'En attente';
      case TaskStatus.review:
        return 'En révision';
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Basse';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.high:
        return 'Haute';
      case TaskPriority.urgent:
        return 'Urgente';
      case TaskPriority.critical:
        return 'Critique';
    }
  }
}

class _TaskDetailsDialog extends StatelessWidget {
  const _TaskDetailsDialog({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (task.description.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(task.description),
              const SizedBox(height: 16),
            ],
            
            if (task.dueDate != null) ...[
              const Text(
                'Date d\'échéance:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: _getDueDateColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(task.dueDate!),
                    style: TextStyle(color: _getDueDateColor()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            Row(
              children: [
                const Text(
                  'Statut:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isCompleted ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.isCompleted ? 'Complétée' : 'En cours',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Text(
                  'Notifications:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.notifications_active, // Always show notifications as enabled for now
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDueDateColor() {
    if (task.dueDate == null) return AppColors.textSecondary;
    
    final now = DateTime.now();
    final dueDate = task.dueDate!;
    
    if (dueDate.isBefore(now)) {
      return Colors.red;
    } else if (dueDate.difference(now).inDays <= 1) {
      return Colors.orange;
    }
    
    return AppColors.textSecondary;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/models/task_model.dart';
import 'widgets/task_list_card.dart';
import 'widgets/task_form_dialog.dart';

// Task providers
final taskListProvider = StateProvider<List<Task>>((ref) => []);

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Tâches'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTaskDialog(context, ref),
            tooltip: 'Ajouter une tâche',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats summary
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
                  tasks.length.toString(),
                  AppColors.primary,
                ),
                _buildStatItem(
                  'Complétées',
                  tasks.where((t) => t.isCompleted).length.toString(),
                  Colors.green,
                ),
                _buildStatItem(
                  'En cours',
                  tasks.where((t) => !t.isCompleted).length.toString(),
                  Colors.orange,
                ),
                _buildStatItem(
                  'En retard',
                  tasks.where((t) => !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(DateTime.now())).length.toString(),
                  Colors.red,
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? Center(
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
                          'Aucune tâche',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cliquez sur + pour ajouter votre première tâche',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskListCard(
                        task: task,
                        onTap: () => _showTaskDetails(context, task),
                        onEdit: () => _showTaskDialog(context, ref, task),
                        onDelete: () => _deleteTask(context, ref, task),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, ref),
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

  Future<void> _showTaskDialog(BuildContext context, WidgetRef ref, [Task? task]) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => TaskFormDialog(task: task),
    );

    if (result != null) {
      final tasks = ref.read(taskListProvider);
      final taskIndex = tasks.indexWhere((t) => t.id == result.id);
      
      if (taskIndex >= 0) {
        // Update existing task
        final updatedTasks = [...tasks];
        updatedTasks[taskIndex] = result;
        ref.read(taskListProvider.notifier).state = updatedTasks;
      } else {
        // Add new task
        ref.read(taskListProvider.notifier).state = [...tasks, result];
      }
    }
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => _TaskDetailsDialog(task: task),
    );
  }

  void _deleteTask(BuildContext context, WidgetRef ref, Task task) {
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
            onPressed: () {
              final tasks = ref.read(taskListProvider);
              ref.read(taskListProvider.notifier).state = 
                  tasks.where((t) => t.id != task.id).toList();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tâche supprimée'),
                ),
              );
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

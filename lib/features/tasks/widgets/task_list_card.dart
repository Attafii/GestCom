import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/database/models/task_model.dart';

class TaskListCard extends ConsumerWidget {
  const TaskListCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (task.dueDate != null) ...[
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
                    _formatDueDate(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDueDateColor(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            onToggleComplete?.call();
          },
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
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

  String _formatDueDate() {
    if (task.dueDate == null) return '';
    
    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final difference = dueDate.difference(now);
    
    if (difference.inDays < 0) {
      return 'En retard de ${(-difference.inDays)} jour(s)';
    } else if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Demain';
    } else {
      return 'Dans ${difference.inDays} jour(s)';
    }
  }
}
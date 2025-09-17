import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/notification_initialization_service.dart';
import 'core/repositories/task_repository_with_notifications.dart';
import 'core/providers/notification_providers.dart';
import 'features/settings/notification_settings_screen.dart';

class NotificationIntegrationExample extends ConsumerStatefulWidget {
  const NotificationIntegrationExample({super.key});

  @override
  ConsumerState<NotificationIntegrationExample> createState() => _NotificationIntegrationExampleState();
}

class _NotificationIntegrationExampleState extends ConsumerState<NotificationIntegrationExample> {
  final TaskRepositoryWithNotifications _taskRepository = TaskRepositoryWithNotifications();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      final initService = NotificationInitializationService();
      await initService.initialize();
      
      setState(() {
        _isInitialized = true;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification system initialized successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationSummary = ref.watch(notificationSummaryProvider);
    final pendingCount = ref.watch(pendingNotificationsCountProvider);
    final settingsSummary = ref.watch(settingsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification System Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: _isInitialized ? _buildInitializedView(
        context, 
        notificationSummary, 
        pendingCount, 
        settingsSummary
      ) : _buildLoadingView(),
      floatingActionButton: _isInitialized ? FloatingActionButton.extended(
        onPressed: _createSampleTask,
        icon: const Icon(Icons.add_task),
        label: const Text('Create Sample Task'),
      ) : null,
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing notification system...'),
        ],
      ),
    );
  }

  Widget _buildInitializedView(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> notificationSummary,
    AsyncValue<int> pendingCount,
    Map<String, dynamic> settingsSummary,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Cards
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Notification System',
                  _isInitialized ? 'Active' : 'Inactive',
                  _isInitialized ? Colors.green : Colors.red,
                  Icons.notifications_active,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: pendingCount.when(
                  data: (count) => _buildStatusCard(
                    'Pending Notifications',
                    count.toString(),
                    Colors.blue,
                    Icons.schedule,
                  ),
                  loading: () => _buildStatusCard(
                    'Pending Notifications',
                    'Loading...',
                    Colors.grey,
                    Icons.schedule,
                  ),
                  error: (error, _) => _buildStatusCard(
                    'Pending Notifications',
                    'Error',
                    Colors.red,
                    Icons.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Settings Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSettingChip('Deadlines', settingsSummary['deadlineNotifications']),
                      _buildSettingChip('Reminders', settingsSummary['reminders']),
                      _buildSettingChip('Sounds', settingsSummary['sounds']),
                      _buildSettingChip('Quiet Hours', settingsSummary['quietHours']),
                      _buildSettingChip('Weekend', settingsSummary['weekendNotifications']),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Task Summary
          notificationSummary.when(
            data: (summary) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildTaskSummaryRow('Active Tasks', summary['activeTasks']),
                    _buildTaskSummaryRow('Overdue Tasks', summary['overdueTasks']),
                    _buildTaskSummaryRow('Due Today', summary['dueTodayTasks']),
                    _buildTaskSummaryRow('Upcoming Deadlines', summary['upcomingDeadlines']),
                  ],
                ),
              ),
            ),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading task summary: $error'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingChip(String label, bool enabled) {
    return Chip(
      label: Text(label),
      backgroundColor: enabled ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
      avatar: Icon(
        enabled ? Icons.check_circle : Icons.cancel,
        color: enabled ? Colors.green : Colors.grey,
        size: 18,
      ),
    );
  }

  Widget _buildTaskSummaryRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _testNotification,
                icon: const Icon(Icons.notifications),
                label: const Text('Test Notification'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _refreshNotifications,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Notifications'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _checkOverdueTasks,
                icon: const Icon(Icons.warning),
                label: const Text('Check Overdue'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showDiagnostics,
                icon: const Icon(Icons.info),
                label: const Text('Diagnostics'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _createSampleTask() async {
    try {
      final taskId = await _taskRepository.createTask(
        title: 'Sample Task with Notifications',
        description: 'This is a sample task to demonstrate the notification system',
        assignedUserId: 'user123', // You would use a real user ID
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        priority: TaskPriority.high,
        category: TaskCategory.general,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sample task created with ID: $taskId'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    try {
      final initService = NotificationInitializationService();
      await initService.testNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshNotifications() async {
    try {
      await _taskRepository.refreshNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications refreshed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkOverdueTasks() async {
    try {
      final overdueTasks = await _taskRepository.checkOverdueTasks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${overdueTasks.length} overdue tasks'),
            backgroundColor: overdueTasks.isEmpty ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check overdue tasks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDiagnostics() async {
    try {
      final initService = NotificationInitializationService();
      final diagnostics = await initService.getDiagnostics();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification System Diagnostics'),
            content: SingleChildScrollView(
              child: Text(diagnostics.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get diagnostics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
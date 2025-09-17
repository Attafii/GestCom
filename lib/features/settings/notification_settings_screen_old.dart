import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/notification_providers.dart';
import '../../core/models/notification_settings_model.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final _quietHoursStartController = TextEditingController();
  final _quietHoursEndController = TextEditingController();
  final _maxNotificationsController = TextEditingController();
  final _customReminderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(notificationSettingsProvider);
      _quietHoursStartController.text = settings.quietHoursStart;
      _quietHoursEndController.text = settings.quietHoursEnd;
      _maxNotificationsController.text = settings.maxNotificationsPerDay.toString();
    });
  }

  @override
  void dispose() {
    _quietHoursStartController.dispose();
    _quietHoursEndController.dispose();
    _maxNotificationsController.dispose();
    _customReminderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.watch(notificationSettingsProvider.notifier);
    final summary = ref.watch(settingsSummaryProvider);
    final reminderStrings = ref.watch(reminderIntervalsStringProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(context, notifier),
            tooltip: 'Reset to defaults',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showNotificationInfo(context, summary),
            tooltip: 'Notification info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            _buildSummaryCard(summary),
            const SizedBox(height: 20),

            // Basic Notification Settings
            _buildSectionCard(
              title: 'Notification Types',
              icon: Icons.notifications,
              children: [
                _buildSwitchTile(
                  title: 'Task Deadline Notifications',
                  subtitle: 'Get notified when tasks are due',
                  value: settings.enableTaskDeadlineNotifications,
                  onChanged: notifier.updateTaskDeadlineNotifications,
                ),
                _buildSwitchTile(
                  title: 'Task Reminders',
                  subtitle: 'Advance reminders before deadlines',
                  value: settings.enableTaskReminders,
                  onChanged: notifier.updateTaskReminders,
                ),
                _buildSwitchTile(
                  title: 'Overdue Task Notifications',
                  subtitle: 'Get notified about overdue tasks',
                  value: settings.enableOverdueTaskNotifications,
                  onChanged: notifier.updateOverdueTaskNotifications,
                ),
                _buildSwitchTile(
                  title: 'Task Completion Notifications',
                  subtitle: 'Celebrate when tasks are completed',
                  value: settings.enableTaskCompletionNotifications,
                  onChanged: notifier.updateTaskCompletionNotifications,
                ),
                _buildSwitchTile(
                  title: 'System Tray Notifications',
                  subtitle: 'Show notifications in system tray',
                  value: settings.enableSystemTrayNotifications,
                  onChanged: notifier.updateSystemTrayNotifications,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Audio & Visual Settings
            _buildSectionCard(
              title: 'Audio & Visual',
              icon: Icons.volume_up,
              children: [
                _buildSwitchTile(
                  title: 'Enable Sounds',
                  subtitle: 'Play sounds for notifications',
                  value: settings.enableSounds,
                  onChanged: (value) => notifier.updateSoundSettings(value, settings.enableVibration),
                ),
                _buildSwitchTile(
                  title: 'Enable Vibration',
                  subtitle: 'Vibrate for notifications (if supported)',
                  value: settings.enableVibration,
                  onChanged: (value) => notifier.updateSoundSettings(settings.enableSounds, value),
                ),
                _buildPrioritySelector(settings.defaultPriority, notifier),
              ],
            ),
            const SizedBox(height: 20),

            // Reminder Intervals
            _buildSectionCard(
              title: 'Reminder Intervals',
              icon: Icons.schedule,
              children: [
                ...reminderStrings.asMap().entries.map((entry) {
                  return _buildReminderIntervalTile(
                    entry.value,
                    settings.reminderIntervals[entry.key],
                    () => notifier.removeReminderInterval(settings.reminderIntervals[entry.key]),
                  );
                }),
                _buildAddReminderTile(notifier),
              ],
            ),
            const SizedBox(height: 20),

            // Quiet Hours
            _buildSectionCard(
              title: 'Quiet Hours',
              icon: Icons.bedtime,
              children: [
                _buildSwitchTile(
                  title: 'Enable Quiet Hours',
                  subtitle: 'Disable notifications during specified hours',
                  value: settings.enableQuietHours,
                  onChanged: (value) => _updateQuietHours(notifier, value),
                ),
                if (settings.enableQuietHours) ...[
                  _buildTimeSelector(
                    'Start Time',
                    _quietHoursStartController,
                    () => _updateQuietHours(notifier, settings.enableQuietHours),
                  ),
                  _buildTimeSelector(
                    'End Time',
                    _quietHoursEndController,
                    () => _updateQuietHours(notifier, settings.enableQuietHours),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Schedule Settings
            _buildSectionCard(
              title: 'Schedule Settings',
              icon: Icons.calendar_today,
              children: [
                _buildSwitchTile(
                  title: 'Weekend Notifications',
                  subtitle: 'Show notifications on weekends',
                  value: settings.enableWeekendNotifications,
                  onChanged: notifier.updateWeekendNotifications,
                ),
                _buildMaxNotificationsSelector(notifier),
              ],
            ),
            const SizedBox(height: 20),

            // Actions
            _buildActionButtons(context, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Notification Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildSummaryChip('Deadlines', summary['deadlineNotifications'] ? 'On' : 'Off'),
                _buildSummaryChip('Reminders', summary['reminders'] ? 'On' : 'Off'),
                _buildSummaryChip('Sounds', summary['sounds'] ? 'On' : 'Off'),
                _buildSummaryChip('Quiet Hours', summary['quietHours'] ? 'On' : 'Off'),
                _buildSummaryChip('Max/Day', '${summary['maxPerDay']}'),
                _buildSummaryChip(
                  'Status',
                  summary['isCurrentlyAllowed'] ? 'Active' : 'Quiet',
                  color: summary['isCurrentlyAllowed'] ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value, {Color? color}) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color?.withOpacity(0.1) ?? Theme.of(context).colorScheme.surfaceVariant,
      labelStyle: TextStyle(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPrioritySelector(NotificationPriority currentPriority, notifier) {
    return ListTile(
      title: const Text('Default Priority'),
      subtitle: Text('Current: ${currentPriority.name}'),
      trailing: DropdownButton<NotificationPriority>(
        value: currentPriority,
        onChanged: (priority) {
          if (priority != null) {
            notifier.updateDefaultPriority(priority);
          }
        },
        items: NotificationPriority.values.map((priority) {
          return DropdownMenuItem(
            value: priority,
            child: Text(priority.name),
          );
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildReminderIntervalTile(String intervalString, int minutes, VoidCallback onRemove) {
    return ListTile(
      title: Text(intervalString),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: onRemove,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAddReminderTile(notifier) {
    return ListTile(
      title: const Text('Add Custom Reminder'),
      subtitle: TextField(
        controller: _customReminderController,
        decoration: const InputDecoration(
          hintText: 'Minutes before deadline',
          suffixText: 'minutes',
        ),
        keyboardType: TextInputType.number,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => _addCustomReminder(notifier),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTimeSelector(String label, TextEditingController controller, VoidCallback onChanged) {
    return ListTile(
      title: Text(label),
      subtitle: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'HH:mm',
        ),
        onChanged: (_) => onChanged(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMaxNotificationsSelector(notifier) {
    return ListTile(
      title: const Text('Max Notifications Per Day'),
      subtitle: TextField(
        controller: _maxNotificationsController,
        decoration: const InputDecoration(
          hintText: 'Maximum number',
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final intValue = int.tryParse(value);
          if (intValue != null && intValue > 0 && intValue <= 100) {
            notifier.updateMaxNotificationsPerDay(intValue);
          }
        },
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons(BuildContext context, notifier) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _testNotification(),
            icon: const Icon(Icons.notifications_active),
            label: const Text('Test Notification'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _exportSettings(context, notifier),
            icon: const Icon(Icons.download),
            label: const Text('Export Settings'),
          ),
        ),
      ],
    );
  }

  void _addCustomReminder(notifier) {
    final minutes = int.tryParse(_customReminderController.text);
    if (minutes != null && minutes > 0) {
      notifier.addReminderInterval(minutes);
      _customReminderController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom reminder added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of minutes')),
      );
    }
  }

  void _updateQuietHours(notifier, bool enabled) {
    try {
      notifier.updateQuietHours(
        enabled: enabled,
        startTime: _quietHoursStartController.text,
        endTime: _quietHoursEndController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _testNotification() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.showImmediateNotification(
      title: 'Test Notification',
      body: 'This is a test notification from GestCom',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent')),
      );
    }
  }

  void _exportSettings(BuildContext context, notifier) {
    final settings = notifier.exportSettings();
    // TODO: Implement file export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings exported (implementation needed)')),
    );
  }

  void _showResetDialog(BuildContext context, notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all notification settings to defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showNotificationInfo(BuildContext context, Map<String, dynamic> summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Status: ${summary['isCurrentlyAllowed'] ? 'Active' : 'Quiet Mode'}'),
              const SizedBox(height: 8),
              Text('Reminder Types: ${summary['reminderCount']}'),
              const SizedBox(height: 8),
              Text('Max per Day: ${summary['maxPerDay']}'),
              const SizedBox(height: 16),
              const Text('Enabled Notifications:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...summary.entries.where((e) => e.value == true).map((e) => Text('• ${e.key}')),
            ],
          ),
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
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/notification_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your notification preferences',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            // Basic Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Settings',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive notifications for tasks and deadlines'),
                      value: settings.isEnabled,
                      onChanged: (value) {
                        ref.read(notificationSettingsProvider.notifier).state = 
                            settings.copyWith(isEnabled: value);
                      },
                    ),
                    
                    SwitchListTile(
                      title: const Text('Show in System Tray'),
                      subtitle: const Text('Display notifications in system tray'),
                      value: settings.showSystemTray,
                      onChanged: settings.isEnabled ? (value) {
                        ref.read(notificationSettingsProvider.notifier).state = 
                            settings.copyWith(showSystemTray: value);
                      } : null,
                    ),
                    
                    SwitchListTile(
                      title: const Text('Play Sound'),
                      subtitle: const Text('Play notification sounds'),
                      value: settings.playSound,
                      onChanged: settings.isEnabled ? (value) {
                        ref.read(notificationSettingsProvider.notifier).state = 
                            settings.copyWith(playSound: value);
                      } : null,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Timing Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timing Settings',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      title: const Text('Default Reminder'),
                      subtitle: Text('${settings.defaultReminderMinutes} minutes before due'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: settings.isEnabled ? () {
                        // TODO: Show time picker
                      } : null,
                    ),
                    
                    SwitchListTile(
                      title: const Text('Quiet Hours'),
                      subtitle: Text('${settings.quietStartTime} - ${settings.quietEndTime}'),
                      value: settings.enableQuietHours,
                      onChanged: settings.isEnabled ? (value) {
                        ref.read(notificationSettingsProvider.notifier).state = 
                            settings.copyWith(enableQuietHours: value);
                      } : null,
                    ),
                    
                    SwitchListTile(
                      title: const Text('Weekend Mode'),
                      subtitle: const Text('Reduce notifications on weekends'),
                      value: settings.enableWeekendMode,
                      onChanged: settings.isEnabled ? (value) {
                        ref.read(notificationSettingsProvider.notifier).state = 
                            settings.copyWith(enableWeekendMode: value);
                      } : null,
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Test notification button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: settings.isEnabled ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification sent!'),
                    ),
                  );
                } : null,
                icon: const Icon(Icons.notifications),
                label: const Text('Test Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
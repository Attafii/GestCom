# Hive Database Architecture Guide

## Overview
This Hive database architecture provides a comprehensive local database solution for the Flutter desktop app with the following entities:
- **User**: User management with roles, status, and authentication
- **Task**: Task management with status, priority, categories, and relationships
- **Notification**: Notification system with types, channels, and scheduling
- **Settings**: User preferences and app configuration

## Features
- ✅ Type-safe Hive models with proper adapters
- ✅ Comprehensive CRUD operations
- ✅ Repository pattern with business logic
- ✅ Riverpod providers for reactive state management
- ✅ Error handling and validation
- ✅ Asynchronous operations
- ✅ Search and filtering capabilities
- ✅ Statistics and analytics

## Quick Start

### 1. Initialize Hive Database
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/core/database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.initialize();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Using Providers in Widgets
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/core/database/database.dart';

class UserListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    
    return usersAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (users) => ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.fullName),
            subtitle: Text(user.email),
          );
        },
      ),
    );
  }
}
```

### 3. Creating Entities
```dart
// Create a new user
final userOps = ref.read(userOperationsProvider.notifier);
final userId = await userOps.createUser(
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  password: 'secure_password',
);

// Create a new task
final taskOps = ref.read(taskOperationsProvider.notifier);
final taskId = await taskOps.createTask(
  title: 'Complete project',
  description: 'Finish the Flutter app',
  assignedUserId: userId!,
  priority: TaskPriority.high,
  dueDate: DateTime.now().add(Duration(days: 7)),
);

// Create a notification
final notifOps = ref.read(notificationOperationsProvider.notifier);
await notifOps.createNotification(
  title: 'Task Assigned',
  message: 'You have been assigned a new task',
  userId: userId,
  type: NotificationType.taskAssignment,
);
```

## Type IDs Used
- **User Model**: 10 (User), 11 (UserRole), 12 (UserStatus)
- **Task Model**: 13 (Task), 14 (TaskStatus), 15 (TaskPriority), 16 (TaskCategory), 17 (TaskComment), 18 (TaskAttachment)
- **Notification Model**: 19 (Notification), 20 (NotificationType), 21 (NotificationStatus), 22 (NotificationChannel), 23 (NotificationAction)
- **Settings Model**: 24 (Settings), 25 (ThemeSettings), 26 (ThemeMode), 27 (NotificationSettings), 28 (LanguageSettings), 29 (PrivacySettings), 30 (GeneralSettings)

## Architecture Components

### Models
- **User Model**: Complete user management with roles, status, metadata
- **Task Model**: Comprehensive task system with subtasks, comments, attachments
- **Notification Model**: Full notification system with scheduling and expiry
- **Settings Model**: Nested settings structure for all app preferences

### Services
- **HiveService**: Central service for database initialization and CRUD operations

### Repositories
- **UserRepository**: Business logic for user operations with validation
- **TaskRepository**: Task management with relationship handling
- **NotificationRepository**: Notification system with filtering and scheduling
- **SettingsRepository**: Settings management with preferences and permissions

### Providers
- **Reactive State Management**: Riverpod providers for all entities
- **Search Functionality**: Built-in search providers
- **Filtering**: Comprehensive filtering for all entities
- **Operations**: State-managed CRUD operations

## Next Steps
1. Run `flutter pub get` to install dependencies
2. Run `flutter packages pub run build_runner build` to generate adapters
3. Initialize the database in your main.dart
4. Start using the providers in your widgets

## Error Handling
All operations include proper error handling with try-catch blocks and validation. Providers return AsyncValue for proper loading/error states in the UI.

## Performance
- Lazy loading with FutureProvider
- Efficient filtering and search
- Proper memory management with Hive
- Reactive updates only when data changes
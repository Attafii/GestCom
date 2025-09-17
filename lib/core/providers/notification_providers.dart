import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/notification_settings_model.dart';

// Simple notification settings provider
final notificationSettingsProvider = StateProvider<NotificationSettings>((ref) {
  return NotificationSettings();
});

// Simple notification status provider
final notificationStatusProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.isEnabled;
});
import '../models/settings_model.dart';
import '../services/hive_service.dart';

/// Simplified repository for currency settings only
class CurrencySettingsRepository {
  /// Get currency for default user
  String getCurrency() {
    return getCurrencyForUser('default_user');
  }

  /// Get currency for specific user
  String getCurrencyForUser(String userId) {
    final settings = _getOrCreateSettings(userId);
    return settings?.general.currency ?? 'EUR';
  }

  /// Get EUR to TND conversion rate for default user
  double getEurToTndRate() {
    return getEurToTndRateForUser('default_user');
  }

  /// Get EUR to TND conversion rate for specific user
  double getEurToTndRateForUser(String userId) {
    final settings = _getOrCreateSettings(userId);
    return settings?.general.eurToTndRate ?? 3.3;
  }

  /// Update currency settings for default user
  Future<bool> updateCurrency(String currency, double eurToTndRate) async {
    return updateCurrencyForUser('default_user', currency, eurToTndRate);
  }

  /// Update currency settings for specific user
  Future<bool> updateCurrencyForUser(String userId, String currency, double eurToTndRate) async {
    final settings = _getOrCreateSettings(userId);
    
    if (settings == null) {
      // Create new settings with currency
      final newSettings = Settings(
        userId: userId,
        general: GeneralSettings(
          currency: currency,
          eurToTndRate: eurToTndRate,
        ),
      );
      await HiveService.createSettings(newSettings);
      return true;
    }

    // Update existing settings
    final updatedGeneral = settings.general.copyWith(
      currency: currency,
      eurToTndRate: eurToTndRate,
    );

    final updatedSettings = settings.copyWith(
      general: updatedGeneral,
    );

    return await HiveService.updateSettings(updatedSettings);
  }

  /// Get or create settings for user
  Settings? _getOrCreateSettings(String userId) {
    // Try to find existing settings
    final allSettings = HiveService.getAllSettings();
    final existing = allSettings.where((s) => s.userId == userId).firstOrNull;
    
    if (existing != null) {
      return existing;
    }

    // No settings exist yet, return null
    // Will be created when updateCurrency is called
    return null;
  }
}

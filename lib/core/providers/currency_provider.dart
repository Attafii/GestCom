import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/repositories/currency_settings_repository.dart';
import '../services/currency_service.dart';

/// Provider for CurrencySettingsRepository
final currencySettingsRepositoryProvider = Provider<CurrencySettingsRepository>((ref) {
  return CurrencySettingsRepository();
});

/// Provider for CurrencyService
final currencyServiceProvider = Provider<CurrencyService>((ref) {
  final settingsRepo = ref.watch(currencySettingsRepositoryProvider);
  return CurrencyService(settingsRepo);
});

/// Provider for current currency
final currentCurrencyProvider = Provider<String>((ref) {
  final currencyService = ref.watch(currencyServiceProvider);
  return currencyService.getCurrentCurrency();
});

/// Provider for conversion rate
final conversionRateProvider = Provider<double>((ref) {
  final currencyService = ref.watch(currencyServiceProvider);
  return currencyService.getConversionRate();
});

/// Provider for currency symbol
final currencySymbolProvider = Provider<String>((ref) {
  final currencyService = ref.watch(currencyServiceProvider);
  return currencyService.getCurrencySymbol();
});

/// Provider for currency info
final currencyInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final currencyService = ref.watch(currencyServiceProvider);
  return currencyService.getCurrencyInfo();
});

import '../database/repositories/currency_settings_repository.dart';

/// Service for handling currency conversions and formatting
class CurrencyService {
  final CurrencySettingsRepository _settingsRepository;
  
  // Default user ID for single-user application
  static const String defaultUserId = 'default_user';
  
  CurrencyService(this._settingsRepository);

  /// Get the current currency setting (EUR or TND)
  String getCurrentCurrency([String? userId]) {
    if (userId == null) {
      return _settingsRepository.getCurrency();
    }
    return _settingsRepository.getCurrencyForUser(userId);
  }

  /// Get the EUR to TND conversion rate
  double getConversionRate([String? userId]) {
    if (userId == null) {
      return _settingsRepository.getEurToTndRate();
    }
    return _settingsRepository.getEurToTndRateForUser(userId);
  }

  /// Convert price from EUR to TND
  double convertEurToTnd(double eurPrice, [String? userId]) {
    final rate = getConversionRate(userId);
    return eurPrice * rate;
  }

  /// Convert price from TND to EUR
  double convertTndToEur(double tndPrice, [String? userId]) {
    final rate = getConversionRate(userId);
    return tndPrice / rate;
  }

  /// Convert price to the display currency (based on user settings)
  /// Assumes input price is in EUR (default storage format)
  double convertToDisplayCurrency(double eurPrice, [String? userId]) {
    final currency = getCurrentCurrency(userId);
    if (currency == 'TND') {
      return convertEurToTnd(eurPrice, userId);
    }
    return eurPrice;
  }

  /// Convert price from display currency back to EUR (for storage)
  double convertFromDisplayCurrency(double displayPrice, [String? userId]) {
    final currency = getCurrentCurrency(userId);
    if (currency == 'TND') {
      return convertTndToEur(displayPrice, userId);
    }
    return displayPrice;
  }

  /// Format price with currency symbol
  String formatPrice(double price, [String? userId]) {
    final currency = getCurrentCurrency(userId);
    final displayPrice = convertToDisplayCurrency(price, userId);
    
    if (currency == 'TND') {
      return '${displayPrice.toStringAsFixed(3)} DT';
    } else {
      return '${displayPrice.toStringAsFixed(2)} €';
    }
  }

  /// Format price without conversion (raw value with currency)
  String formatPriceRaw(double price, String currency) {
    if (currency == 'TND') {
      return '${price.toStringAsFixed(3)} DT';
    } else {
      return '${price.toStringAsFixed(2)} €';
    }
  }

  /// Get currency symbol
  String getCurrencySymbol([String? userId]) {
    final currency = getCurrentCurrency(userId);
    return currency == 'TND' ? 'DT' : '€';
  }

  /// Get decimal places for currency
  int getDecimalPlaces([String? userId]) {
    final currency = getCurrentCurrency(userId);
    return currency == 'TND' ? 3 : 2;
  }

  /// Update currency settings
  Future<bool> updateCurrency(String currency, double? conversionRate, [String? userId]) async {
    final rate = conversionRate ?? 3.3;
    if (userId == null) {
      return await _settingsRepository.updateCurrency(currency, rate);
    }
    return await _settingsRepository.updateCurrencyForUser(userId, currency, rate);
  }

  /// Validate currency code
  bool isValidCurrency(String currency) {
    return currency == 'EUR' || currency == 'TND';
  }

  /// Get currency info for display
  Map<String, dynamic> getCurrencyInfo([String? userId]) {
    final currency = getCurrentCurrency(userId);
    final rate = getConversionRate(userId);
    
    return {
      'currency': currency,
      'symbol': getCurrencySymbol(userId),
      'decimalPlaces': getDecimalPlaces(userId),
      'conversionRate': rate,
      'conversionInfo': currency == 'EUR' 
          ? 'Prix en euros (devise par défaut)'
          : 'Prix en dinars tunisiens (1 € = $rate DT)',
    };
  }
}

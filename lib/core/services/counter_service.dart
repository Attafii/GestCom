import 'package:hive/hive.dart';

/// Service for managing sequential counters for different document types
class CounterService {
  static const String _boxName = 'counters';
  static const String _brCounterKey = 'br_counter';
  static const String _blCounterKey = 'bl_counter';
  static const String _factureCounterKey = 'facture_counter';
  
  static Box<int>? _counterBox;
  
  /// Initialize the counter service
  static Future<void> initialize() async {
    if (_counterBox == null || !_counterBox!.isOpen) {
      _counterBox = await Hive.openBox<int>(_boxName);
    }
  }
  
  /// Get the next BR number (BR001, BR002, etc.)
  static Future<String> getNextBRNumber() async {
    await initialize();
    
    final currentCounter = _counterBox!.get(_brCounterKey, defaultValue: 0)!;
    final nextCounter = currentCounter + 1;
    
    // Save the new counter value
    await _counterBox!.put(_brCounterKey, nextCounter);
    
    // Format as BR001, BR002, etc.
    return 'BR${nextCounter.toString().padLeft(3, '0')}';
  }
  
  /// Get the next BL number (BL001, BL002, etc.)
  static Future<String> getNextBLNumber() async {
    await initialize();
    
    final currentCounter = _counterBox!.get(_blCounterKey, defaultValue: 0)!;
    final nextCounter = currentCounter + 1;
    
    // Save the new counter value
    await _counterBox!.put(_blCounterKey, nextCounter);
    
    // Format as BL001, BL002, etc.
    return 'BL${nextCounter.toString().padLeft(3, '0')}';
  }
  
  /// Get the next Facture number (FAC001, FAC002, etc.)
  static Future<String> getNextFactureNumber() async {
    await initialize();
    
    final currentCounter = _counterBox!.get(_factureCounterKey, defaultValue: 0)!;
    final nextCounter = currentCounter + 1;
    
    // Save the new counter value
    await _counterBox!.put(_factureCounterKey, nextCounter);
    
    // Format as FAC001, FAC002, etc.
    return 'FAC${nextCounter.toString().padLeft(3, '0')}';
  }
  
  /// Get current BR counter value
  static Future<int> getCurrentBRCounter() async {
    await initialize();
    return _counterBox!.get(_brCounterKey, defaultValue: 0)!;
  }
  
  /// Get current BL counter value
  static Future<int> getCurrentBLCounter() async {
    await initialize();
    return _counterBox!.get(_blCounterKey, defaultValue: 0)!;
  }
  
  /// Get current Facture counter value
  static Future<int> getCurrentFactureCounter() async {
    await initialize();
    return _counterBox!.get(_factureCounterKey, defaultValue: 0)!;
  }
  
  /// Reset a specific counter (for admin purposes)
  static Future<void> resetCounter(String counterType, int value) async {
    await initialize();
    
    switch (counterType.toLowerCase()) {
      case 'br':
        await _counterBox!.put(_brCounterKey, value);
        break;
      case 'bl':
        await _counterBox!.put(_blCounterKey, value);
        break;
      case 'facture':
        await _counterBox!.put(_factureCounterKey, value);
        break;
      default:
        throw ArgumentError('Invalid counter type: $counterType');
    }
  }
  
  /// Get all counter values for admin display
  static Future<Map<String, int>> getAllCounters() async {
    await initialize();
    
    return {
      'BR': _counterBox!.get(_brCounterKey, defaultValue: 0)!,
      'BL': _counterBox!.get(_blCounterKey, defaultValue: 0)!,
      'Facture': _counterBox!.get(_factureCounterKey, defaultValue: 0)!,
    };
  }
  
  /// Close the counter box
  static Future<void> close() async {
    if (_counterBox != null && _counterBox!.isOpen) {
      await _counterBox!.close();
      _counterBox = null;
    }
  }
}
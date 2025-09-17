import 'package:hive/hive.dart';
import '../models/treatment_model.dart';

class TreatmentRepository {
  static const String _boxName = 'treatments';
  
  Box<Treatment> get _box => Hive.box<Treatment>(_boxName);

  // Get all treatments
  List<Treatment> getAllTreatments() {
    return _box.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get active treatments only
  List<Treatment> getActiveTreatments() {
    return _box.values.where((treatment) => treatment.isActive).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get treatment by ID
  Treatment? getTreatmentById(String id) {
    return _box.values.firstWhere(
      (treatment) => treatment.id == id,
      orElse: () => throw Exception('Treatment not found'),
    );
  }

  // Search treatments by name
  List<Treatment> searchTreatments(String query, {bool? activeOnly}) {
    if (query.isEmpty) {
      return activeOnly == true ? getActiveTreatments() : getAllTreatments();
    }
    
    final lowercaseQuery = query.toLowerCase();
    var treatments = _box.values.where((treatment) {
      if (activeOnly == true && !treatment.isActive) return false;
      return treatment.name.toLowerCase().contains(lowercaseQuery) ||
             treatment.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
    
    return treatments..sort((a, b) => a.name.compareTo(b.name));
  }

  // Add new treatment
  Future<void> addTreatment(Treatment treatment) async {
    // Check if name already exists
    Treatment? existingTreatment;
    try {
      existingTreatment = _box.values.firstWhere(
        (t) => t.name.toLowerCase() == treatment.name.toLowerCase(),
      );
    } catch (e) {
      existingTreatment = null;
    }
    
    if (existingTreatment != null) {
      throw Exception('Un traitement avec ce nom existe déjà');
    }

    await _box.put(treatment.id, treatment);
  }

  // Update existing treatment
  Future<void> updateTreatment(Treatment treatment) async {
    if (!_box.containsKey(treatment.id)) {
      throw Exception('Treatment not found');
    }

    // Check if name already exists for another treatment
    Treatment? existingTreatment;
    try {
      existingTreatment = _box.values.firstWhere(
        (t) => t.name.toLowerCase() == treatment.name.toLowerCase() && t.id != treatment.id,
      );
    } catch (e) {
      existingTreatment = null;
    }
    
    if (existingTreatment != null) {
      throw Exception('Un traitement avec ce nom existe déjà');
    }

    await _box.put(treatment.id, treatment);
  }

  // Delete treatment
  Future<void> deleteTreatment(String id) async {
    if (!_box.containsKey(id)) {
      throw Exception('Treatment not found');
    }

    await _box.delete(id);
  }

  // Get treatments count
  int getTreatmentsCount() {
    return _box.length;
  }

  // Check if treatment name exists
  bool treatmentNameExists(String name, {String? excludeId}) {
    return _box.values.any((treatment) => 
      treatment.name.toLowerCase() == name.toLowerCase() && 
      (excludeId == null || treatment.id != excludeId)
    );
  }

  // Export treatments to JSON
  List<Map<String, dynamic>> exportToJson() {
    return _box.values.map((treatment) => treatment.toJson()).toList();
  }

  // Initialize with default treatments
  Future<void> initializeDefaultTreatments() async {
    if (_box.isEmpty) {
      final defaultTreatments = [
        Treatment(
          name: 'Lavage',
          description: 'Lavage standard',
          defaultPrice: 5.0,
        ),
        Treatment(
          name: 'Séchage',
          description: 'Séchage standard',
          defaultPrice: 3.0,
        ),
        Treatment(
          name: 'Repassage',
          description: 'Repassage standard',
          defaultPrice: 2.0,
        ),
        Treatment(
          name: 'Nettoyage à sec',
          description: 'Nettoyage à sec professionnel',
          defaultPrice: 8.0,
        ),
      ];

      for (final treatment in defaultTreatments) {
        await _box.put(treatment.id, treatment);
      }
    }
  }

  // Clear all treatments (for testing or reset)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
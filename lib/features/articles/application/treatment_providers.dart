import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/treatment_model.dart';
import '../../../data/repositories/treatment_repository.dart';

part 'treatment_providers.g.dart';

// Repository provider
@riverpod
TreatmentRepository treatmentRepository(TreatmentRepositoryRef ref) {
  return TreatmentRepository();
}

// Treatment list provider
@riverpod
class TreatmentList extends _$TreatmentList {
  @override
  List<Treatment> build() {
    final repository = ref.read(treatmentRepositoryProvider);
    return repository.getAllTreatments();
  }

  // Add treatment
  Future<void> addTreatment(Treatment treatment) async {
    final repository = ref.read(treatmentRepositoryProvider);
    try {
      await repository.addTreatment(treatment);
      state = repository.getAllTreatments();
    } catch (e) {
      rethrow;
    }
  }

  // Update treatment
  Future<void> updateTreatment(Treatment treatment) async {
    final repository = ref.read(treatmentRepositoryProvider);
    try {
      await repository.updateTreatment(treatment);
      state = repository.getAllTreatments();
    } catch (e) {
      rethrow;
    }
  }

  // Delete treatment
  Future<void> deleteTreatment(String id) async {
    final repository = ref.read(treatmentRepositoryProvider);
    try {
      await repository.deleteTreatment(id);
      state = repository.getAllTreatments();
    } catch (e) {
      rethrow;
    }
  }

  // Search treatments
  void searchTreatments(String query, {bool? activeOnly}) {
    final repository = ref.read(treatmentRepositoryProvider);
    state = repository.searchTreatments(query, activeOnly: activeOnly);
  }

  // Refresh treatments list
  void refresh() {
    final repository = ref.read(treatmentRepositoryProvider);
    state = repository.getAllTreatments();
  }

  // Initialize default treatments
  Future<void> initializeDefaults() async {
    final repository = ref.read(treatmentRepositoryProvider);
    await repository.initializeDefaultTreatments();
    state = repository.getAllTreatments();
  }
}

// Active treatments only provider
@riverpod
List<Treatment> activeTreatments(ActiveTreatmentsRef ref) {
  final repository = ref.read(treatmentRepositoryProvider);
  return repository.getActiveTreatments();
}
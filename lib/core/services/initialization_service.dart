import '../../data/repositories/treatment_repository.dart';

class InitializationService {
  static const InitializationService _instance = InitializationService._internal();
  
  factory InitializationService() => _instance;
  const InitializationService._internal();

  /// Initialize default data for the application
  Future<void> initializeDefaultData() async {
    await _initializeDefaultTreatments();
  }

  /// Initialize default treatments if the treatments box is empty
  Future<void> _initializeDefaultTreatments() async {
    final treatmentRepository = TreatmentRepository();
    
    // Only initialize if there are no treatments
    if (treatmentRepository.getAllTreatments().isEmpty) {
      await treatmentRepository.initializeDefaultTreatments();
    }
  }
}
import '../../data/repositories/treatment_repository.dart';
import 'counter_service.dart';

class InitializationService {
  static const InitializationService _instance = InitializationService._internal();
  
  factory InitializationService() => _instance;
  const InitializationService._internal();

  /// Initialize default data for the application
  Future<void> initializeDefaultData() async {
    await _initializeDefaultTreatments();
    await _initializeCounterService();
  }

  /// Initialize default treatments if the treatments box is empty
  Future<void> _initializeDefaultTreatments() async {
    final treatmentRepository = TreatmentRepository();
    
    // Only initialize if there are no treatments
    if (treatmentRepository.getAllTreatments().isEmpty) {
      await treatmentRepository.initializeDefaultTreatments();
    }
  }

  /// Initialize the counter service
  Future<void> _initializeCounterService() async {
    await CounterService.initialize();
  }
}
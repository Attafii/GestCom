import '../config/categories_config.dart';

/// Service for providing treatment suggestions based on article categories
class TreatmentSuggestionService {
  /// Get suggested treatments based on article designation/category
  static List<String> getSuggestedTreatmentsByCategory(String designation) {
    return CategoriesConfig.getSuggestionsForCategory(designation);
  }

  /// Get all available categories
  static List<String> getAllCategories() {
    return CategoriesConfig.getAllCategories();
  }

  /// Get categories grouped by type
  static Map<String, List<String>> getCategoriesByGroup() {
    return CategoriesConfig.getCategoriesByGroup();
  }

  /// Search categories by keyword
  static List<String> searchCategories(String keyword) {
    return CategoriesConfig.searchCategories(keyword);
  }

  /// Get additional treatment suggestions based on keywords in designation
  static List<String> getAdditionalSuggestions(String designation) {
    final text = designation.toLowerCase();
    List<String> additional = [];
    
    // Check for specific keywords that might indicate special treatments
    if (text.contains('tache') || text.contains('tâche')) {
      additional.add('Détachage spécialisé');
    }
    if (text.contains('blanc') || text.contains('blanche')) {
      additional.add('Blanchiment professionnel');
    }
    if (text.contains('couleur')) {
      additional.add('Fixation couleur');
    }
    if (text.contains('odeur')) {
      additional.add('Désodorisation');
    }
    if (text.contains('plissé')) {
      additional.add('Repassage plissé');
    }
    if (text.contains('imperméable')) {
      additional.add('Imperméabilisation');
    }
    if (text.contains('brillant') || text.contains('brillante')) {
      additional.add('Lustrage');
    }
    if (text.contains('froissé')) {
      additional.add('Défroissage vapeur');
    }
    
    return additional;
  }
  
  /// Get complete list of suggested treatments (main + additional)
  static List<String> getAllSuggestions(String designation) {
    final main = getSuggestedTreatmentsByCategory(designation);
    final additional = getAdditionalSuggestions(designation);
    
    // Combine and remove duplicates
    final allSuggestions = <String>{...main, ...additional}.toList();
    return allSuggestions;
  }
}
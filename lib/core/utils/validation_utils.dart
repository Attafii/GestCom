/// Validation utilities for the GestCom application
class ValidationUtils {
  /// Validates Tunisian fiscal number (Matricule Fiscal) according to Tunisian rules
  /// 
  /// Rules:
  /// - Must be exactly 8 digits
  /// - Optional suffix with letters is allowed in some cases
  /// 
  /// Returns error message if invalid, null if valid
  static String? validateMatriculeFiscal(String value) {
    if (value.isEmpty) {
      return 'Le matricule fiscal est obligatoire';
    }

    final trimmedValue = value.trim();
    
    // Check basic format: should start with 8 digits
    final RegExp fiscalRegex = RegExp(r'^\d{8}([A-Za-z]*)?$');
    
    if (!fiscalRegex.hasMatch(trimmedValue)) {
      return 'Le matricule fiscal doit contenir exactement 8 chiffres suivis optionnellement de lettres';
    }

    // Additional validation: check if it's exactly 8 digits or 8 digits + letters
    if (trimmedValue.length < 8) {
      return 'Le matricule fiscal doit contenir au moins 8 chiffres';
    }

    // Extract the numeric part
    final numericPart = trimmedValue.substring(0, 8);
    if (!RegExp(r'^\d{8}$').hasMatch(numericPart)) {
      return 'Les 8 premiers caractères doivent être des chiffres';
    }

    // Check if there are any invalid characters
    final suffixPart = trimmedValue.substring(8);
    if (suffixPart.isNotEmpty && !RegExp(r'^[A-Za-z]+$').hasMatch(suffixPart)) {
      return 'Le suffixe ne peut contenir que des lettres';
    }

    return null; // Valid
  }

  /// Validates email format
  static String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'L\'email est obligatoire';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }

    return null;
  }

  /// Validates phone number format
  static String? validatePhone(String value) {
    if (value.isEmpty) {
      return 'Le numéro de téléphone est obligatoire';
    }

    // Basic phone validation for Tunisian numbers
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Format de téléphone invalide';
    }

    return null;
  }

  /// Validates required field
  static String? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName est obligatoire';
    }
    return null;
  }
}
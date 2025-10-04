/// Categories configuration with treatment suggestions
/// This file contains comprehensive category mappings for various item types
/// and their corresponding treatment suggestions for the GestCom application.

class CategoriesConfig {
  /// Main categories map with their corresponding treatment suggestions
  static const Map<String, List<String>> categorySuggestions = {
    // Textile & Clothing
    'vêtements': [
      'Lavage délicat',
      'Repassage professionnel',
      'Détachage',
      'Nettoyage à sec',
      'Pressing vapeur',
      'Traitement antimite',
    ],
    'chemises': [
      'Lavage et repassage',
      'Pressing col et poignets',
      'Amidonner',
      'Détachage cols',
      'Pliage professionnel',
    ],
    'costumes': [
      'Nettoyage à sec',
      'Pressing complet',
      'Détachage spécialisé',
      'Retouches mineures',
      'Protection antimite',
      'Défroissage vapeur',
    ],
    'robes': [
      'Nettoyage délicat',
      'Repassage soigné',
      'Détachage précis',
      'Traitement anti-plis',
      'Pressing forme',
    ],
    'pantalons': [
      'Lavage classique',
      'Pressing pli',
      'Détachage',
      'Ourlet',
      'Nettoyage à sec',
    ],
    'manteaux': [
      'Nettoyage à sec',
      'Pressing forme',
      'Imperméabilisation',
      'Détachage spécialisé',
      'Traitement doublure',
      'Nettoyage col fourrure',
    ],
    'vestes': [
      'Nettoyage à sec',
      'Pressing professionnel',
      'Détachage',
      'Défroissage',
      'Traitement forme',
    ],

    // Textiles de maison
    'rideaux': [
      'Lavage délicat',
      'Détachage',
      'Repassage grands formats',
      'Traitement anti-acariens',
      'Nettoyage vapeur',
    ],
    'tapis': [
      'Nettoyage profond',
      'Détachage spécialisé',
      'Désinfection',
      'Séchage contrôlé',
      'Traitement anti-acariens',
      'Shampoing',
    ],
    'moquettes': [
      'Nettoyage injection-extraction',
      'Détachage',
      'Désodorisation',
      'Séchage rapide',
      'Traitement antibactérien',
    ],

    // Literie
    'couettes': [
      'Lavage hypoallergénique',
      'Séchage tambour',
      'Désinfection',
      'Traitement anti-acariens',
      'Regonflage',
    ],
    'oreillers': [
      'Lavage spécialisé',
      'Désinfection',
      'Séchage adapté',
      'Traitement anti-acariens',
      'Regonflage duvet',
    ],
    'draps': [
      'Lavage haute température',
      'Repassage professionnel',
      'Détachage',
      'Traitement antibactérien',
      'Pliage soigné',
    ],

    // Cuir
    'cuir': [
      'Nettoyage cuir',
      'Nourrissage',
      'Imperméabilisation',
      'Réparation griffures',
      'Lustrage',
      'Assouplissement',
    ],
    'sacs': [
      'Nettoyage cuir/textile',
      'Détachage spécialisé',
      'Imperméabilisation',
      'Réparation',
      'Lustrage',
    ],
    'chaussures': [
      'Nettoyage complet',
      'Cirage professionnel',
      'Imperméabilisation',
      'Désodorisation',
      'Réparation mineure',
    ],

    // Articles spéciaux
    'robes de mariée': [
      'Nettoyage délicat',
      'Détachage précis',
      'Pressing forme',
      'Protection longue durée',
      'Emballage conservation',
      'Traitement perles/broderies',
    ],
    'smoking': [
      'Nettoyage à sec premium',
      'Pressing impeccable',
      'Détachage fin',
      'Lustrage satin',
      'Traitement nœud papillon',
    ],
    'uniformes': [
      'Lavage professionnel',
      'Repassage réglementaire',
      'Détachage',
      'Pressing galons',
      'Traitement insignes',
    ],

    // Électronique (si applicable pour nettoyage externe)
    'ordinateurs': [
      'Nettoyage externe',
      'Dépoussiérage',
      'Désinfection',
      'Nettoyage écran',
      'Nettoyage clavier',
    ],
    'téléphones': [
      'Désinfection',
      'Nettoyage écran',
      'Nettoyage coque',
      'Traitement antibactérien',
    ],

    // Accessoires
    'cravates': [
      'Nettoyage à sec',
      'Pressing délicat',
      'Détachage précis',
      'Traitement soie',
    ],
    'écharpes': [
      'Lavage délicat',
      'Séchage à plat',
      'Repassage adapté',
      'Détachage',
    ],
    'gants': [
      'Lavage spécialisé',
      'Séchage forme',
      'Assouplissement',
      'Détachage',
    ],

    // Textiles techniques
    'vêtements de sport': [
      'Lavage technique',
      'Élimination odeurs',
      'Traitement antibactérien',
      'Séchage rapide',
      'Conservation élasticité',
    ],
    'maillots de bain': [
      'Lavage chlore',
      'Rinçage spécialisé',
      'Séchage à plat',
      'Conservation élasticité',
    ],

    // Tissus délicats
    'soie': [
      'Lavage à la main',
      'Séchage à plat',
      'Repassage vapeur',
      'Détachage délicat',
      'Traitement brillance',
    ],
    'cachemire': [
      'Lavage spécialisé',
      'Séchage à plat',
      'Brossage',
      'Traitement douceur',
      'Anti-boulochage',
    ],
    'laine': [
      'Lavage laine',
      'Séchage à plat',
      'Traitement antimite',
      'Défeutrage',
      'Brossage',
    ],

    // Articles professionnels
    'blouses médicales': [
      'Lavage haute température',
      'Désinfection',
      'Repassage professionnel',
      'Traitement antibactérien',
      'Stérilisation',
    ],
    'vêtements de travail': [
      'Dégraissage industriel',
      'Lavage renforcé',
      'Détachage spécialisé',
      'Imperméabilisation',
      'Traitement saleté tenace',
    ],

    // Articles de luxe
    'fourrure': [
      'Nettoyage à sec spécialisé',
      'Conditionnement',
      'Protection antimite',
      'Lustrage',
      'Conservation professionnelle',
    ],
    'bijoux textiles': [
      'Nettoyage ultra-délicat',
      'Détachage précis',
      'Séchage contrôlé',
      'Protection éléments décoratifs',
    ],
  };

  /// Get treatment suggestions for a given category/designation
  static List<String> getSuggestionsForCategory(String designation) {
    if (designation.isEmpty) return [];
    
    final lowerDesignation = designation.toLowerCase().trim();
    
    // Direct match
    if (categorySuggestions.containsKey(lowerDesignation)) {
      return categorySuggestions[lowerDesignation]!;
    }
    
    // Partial match - find categories that contain the designation or vice versa
    final suggestions = <String>[];
    
    for (final entry in categorySuggestions.entries) {
      final category = entry.key;
      final categoryWords = category.split(' ');
      final designationWords = lowerDesignation.split(' ');
      
      // Check if any word in designation matches any word in category
      bool hasMatch = false;
      for (final designationWord in designationWords) {
        if (designationWord.length > 2) { // Ignore very short words
          for (final categoryWord in categoryWords) {
            if (categoryWord.contains(designationWord) || 
                designationWord.contains(categoryWord)) {
              hasMatch = true;
              break;
            }
          }
        }
        if (hasMatch) break;
      }
      
      // Also check if designation contains category name
      if (!hasMatch && lowerDesignation.contains(category)) {
        hasMatch = true;
      }
      
      if (hasMatch) {
        suggestions.addAll(entry.value);
      }
    }
    
    // Remove duplicates and return
    return suggestions.toSet().toList();
  }

  /// Get all available categories
  static List<String> getAllCategories() {
    return categorySuggestions.keys.toList()..sort();
  }

  /// Get categories by type/group
  static Map<String, List<String>> getCategoriesByGroup() {
    return {
      'Vêtements': [
        'vêtements', 'chemises', 'costumes', 'robes', 'pantalons', 
        'manteaux', 'vestes', 'cravates', 'écharpes', 'gants'
      ],
      'Textiles de maison': [
        'rideaux', 'tapis', 'moquettes', 'draps'
      ],
      'Literie': [
        'couettes', 'oreillers', 'draps'
      ],
      'Cuir': [
        'cuir', 'sacs', 'chaussures'
      ],
      'Articles spéciaux': [
        'robes de mariée', 'smoking', 'uniformes', 'fourrure', 'bijoux textiles'
      ],
      'Électronique': [
        'ordinateurs', 'téléphones'
      ],
      'Textiles techniques': [
        'vêtements de sport', 'maillots de bain'
      ],
      'Tissus délicats': [
        'soie', 'cachemire', 'laine'
      ],
      'Articles professionnels': [
        'blouses médicales', 'vêtements de travail'
      ],
    };
  }

  /// Search categories by keyword
  static List<String> searchCategories(String keyword) {
    if (keyword.isEmpty) return [];
    
    final lowerKeyword = keyword.toLowerCase();
    final results = <String>[];
    
    for (final category in categorySuggestions.keys) {
      if (category.toLowerCase().contains(lowerKeyword)) {
        results.add(category);
      }
    }
    
    return results;
  }
}
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/client_model.dart';
import '../../data/models/article_model.dart';
import '../../data/models/treatment_model.dart';
import '../../data/models/bon_reception_model.dart';
import '../../data/models/article_reception_model.dart';
import '../../data/models/bon_livraison_model.dart';
import '../../data/models/article_livraison_model.dart';
import '../../data/models/facturation_model.dart';

class TestDataService {
  static Future<void> populateTestData() async {
    print('🔄 Starting test data population...');
    
    // Clear existing data
    await _clearAllData();
    
    // Populate in order: Clients -> Articles -> Treatments -> Receptions -> Deliveries -> Invoices
    await _createClients();
    await _createArticles();
    await _createTreatments();
    await _createBonReceptions();
    await _createBonLivraisons();
    await _createFacturations();
    
    print('✅ Test data population completed!');
  }
  
  static Future<void> _clearAllData() async {
    print('🗑️ Clearing existing data...');
    final clientBox = Hive.box<Client>('clients');
    final articleBox = Hive.box<Article>('articles');
    final treatmentBox = Hive.box<Treatment>('treatments');
    final receptionBox = Hive.box<BonReception>('bon_receptions');
    final livraisonBox = Hive.box<BonLivraison>('bon_livraison');
    final facturationBox = Hive.box<Facturation>('facturations');
    
    await clientBox.clear();
    await articleBox.clear();
    await treatmentBox.clear();
    await receptionBox.clear();
    await livraisonBox.clear();
    await facturationBox.clear();
  }
  
  static Future<void> _createClients() async {
    print('👥 Creating clients...');
    final clientBox = Hive.box<Client>('clients');
    
    final clients = [
      Client(
        id: 'client_001',
        name: 'Société Tunisienne de Distribution',
        address: '15 Avenue Habib Bourguiba, Tunis 1000',
        phone: '+216 71 123 456',
        email: 'contact@std-tunisie.com',
        matriculeFiscal: '1234567L',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      Client(
        id: 'client_002',
        name: 'Entreprise Méditerranéenne',
        address: '42 Rue de la Liberté, Sfax 3000',
        phone: '+216 74 234 567',
        email: 'info@entreprise-med.tn',
        matriculeFiscal: '2345678M',
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      Client(
        id: 'client_003',
        name: 'Commerce International Tunisie',
        address: '88 Avenue de la République, Sousse 4000',
        phone: '+216 73 345 678',
        email: 'commercial@cit-tn.com',
        matriculeFiscal: '3456789N',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Client(
        id: 'client_004',
        name: 'Négoce et Services SARL',
        address: '23 Boulevard 7 Novembre, Bizerte 7000',
        phone: '+216 72 456 789',
        email: 'contact@negoce-services.tn',
        matriculeFiscal: '4567890P',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Client(
        id: 'client_005',
        name: 'Distribution Nord Africaine',
        address: '67 Route de Gabès, Médenine 4100',
        phone: '+216 75 567 890',
        email: 'info@dna-distribution.com',
        matriculeFiscal: '5678901Q',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
    
    for (var client in clients) {
      await clientBox.put(client.id, client);
    }
    print('✅ Created ${clients.length} clients');
  }
  
  static Future<void> _createArticles() async {
    print('📦 Creating articles...');
    final articleBox = Hive.box<Article>('articles');
    
    final articles = [
      Article(
        id: 'art_001',
        reference: 'TEX-001',
        designation: 'Tissu Coton Premium',
        traitementPrix: {},
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      Article(
        id: 'art_002',
        reference: 'TEX-002',
        designation: 'Tissu Polyester Standard',
        traitementPrix: {},
        createdAt: DateTime.now().subtract(const Duration(days: 195)),
      ),
      Article(
        id: 'art_003',
        reference: 'TEX-003',
        designation: 'Tissu Lin Naturel',
        traitementPrix: {},
        createdAt: DateTime.now().subtract(const Duration(days: 190)),
      ),
      Article(
        id: 'art_004',
        reference: 'ACC-001',
        designation: 'Boutons Plastique 15mm',
        traitementPrix: {},
        createdAt: DateTime.now().subtract(const Duration(days: 185)),
      ),
      Article(
        id: 'art_005',
        reference: 'ACC-002',
        designation: 'Fermeture Éclair Métal 20cm',
        traitementPrix: {},
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      Article(
        id: 'art_006',
        reference: 'FIL-001',
        designation: 'Fil à Coudre Polyester',
        traitementPrix: {},
        createdAt: DateTime.now().subtract(const Duration(days: 175)),
      ),
      Article(
        id: 'art_007',
        reference: 'CUI-001',
        designation: 'Cuir Véritable Marron',
        traitementPrix: {},
        createdAt: DateTime.now().subtract(const Duration(days: 170)),
      ),
      Article(
        id: 'art_008',
        reference: 'CUI-002',
        designation: 'Cuir Synthétique Noir',
        traitementPrix: {},
        createdAt: DateTime.now().subtract(const Duration(days: 165)),
      ),
    ];
    
    for (var article in articles) {
      await articleBox.put(article.id, article);
    }
    print('✅ Created ${articles.length} articles');
  }
  
  static Future<void> _createTreatments() async {
    print('🔧 Creating treatments...');
    final treatmentBox = Hive.box<Treatment>('treatments');
    
    final treatments = [
      Treatment(
        id: 'treat_001',
        name: 'Teinture Rouge',
        description: 'Teinture couleur rouge cardinal',
        defaultPrice: 15.50,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      Treatment(
        id: 'treat_002',
        name: 'Teinture Bleue',
        description: 'Teinture couleur bleu marine',
        defaultPrice: 15.50,
        createdAt: DateTime.now().subtract(const Duration(days: 195)),
      ),
      Treatment(
        id: 'treat_003',
        name: 'Teinture Verte',
        description: 'Teinture couleur vert émeraude',
        defaultPrice: 15.50,
        createdAt: DateTime.now().subtract(const Duration(days: 190)),
      ),
      Treatment(
        id: 'treat_004',
        name: 'Impression Floral',
        description: 'Motif floral multicolore',
        defaultPrice: 22.75,
        createdAt: DateTime.now().subtract(const Duration(days: 185)),
      ),
      Treatment(
        id: 'treat_005',
        name: 'Impression Géométrique',
        description: 'Motif géométrique moderne',
        defaultPrice: 22.75,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      Treatment(
        id: 'treat_006',
        name: 'Broderie Main',
        description: 'Broderie artisanale à la main',
        defaultPrice: 35.00,
        createdAt: DateTime.now().subtract(const Duration(days: 175)),
      ),
      Treatment(
        id: 'treat_007',
        name: 'Broderie Machine',
        description: 'Broderie automatisée machine',
        defaultPrice: 18.50,
        createdAt: DateTime.now().subtract(const Duration(days: 170)),
      ),
      Treatment(
        id: 'treat_008',
        name: 'Finition Standard',
        description: 'Finition basique sans traitement',
        defaultPrice: 5.00,
        createdAt: DateTime.now().subtract(const Duration(days: 165)),
      ),
    ];
    
    for (var treatment in treatments) {
      await treatmentBox.put(treatment.id, treatment);
    }
    print('✅ Created ${treatments.length} treatments');
  }
  
  static Future<void> _createBonReceptions() async {
    print('📥 Creating bons de réception...');
    final receptionBox = Hive.box<BonReception>('bon_receptions');
    
    // BR for Client 1
    final br001 = BonReception(
      id: 'br_001',
      numeroBR: 'BR2025001',
      clientId: 'client_001',
      dateReception: DateTime.now().subtract(const Duration(days: 45)),
      commandeNumber: 'CMD001',
      articles: [
        ArticleReception(
          articleReference: 'TEX-001',
          articleDesignation: 'Tissu Coton Premium',
          quantity: 500,
          unitPrice: 12.50,
        ),
        ArticleReception(
          articleReference: 'TEX-002',
          articleDesignation: 'Tissu Polyester Standard',
          quantity: 800,
          unitPrice: 10.00,
        ),
        ArticleReception(
          articleReference: 'ACC-001',
          articleDesignation: 'Boutons Plastique 15mm',
          quantity: 2000,
          unitPrice: 0.50,
        ),
      ],
    );
    
    final br002 = BonReception(
      id: 'br_002',
      numeroBR: 'BR2025002',
      clientId: 'client_002',
      dateReception: DateTime.now().subtract(const Duration(days: 40)),
      commandeNumber: 'CMD002',
      articles: [
        ArticleReception(
          articleReference: 'TEX-003',
          articleDesignation: 'Tissu Lin Naturel',
          quantity: 300,
          unitPrice: 18.00,
        ),
        ArticleReception(
          articleReference: 'FIL-001',
          articleDesignation: 'Fil à Coudre Polyester',
          quantity: 150,
          unitPrice: 5.00,
        ),
      ],
    );
    
    final br003 = BonReception(
      id: 'br_003',
      numeroBR: 'BR2025003',
      clientId: 'client_003',
      dateReception: DateTime.now().subtract(const Duration(days: 35)),
      commandeNumber: 'CMD003',
      articles: [
        ArticleReception(
          articleReference: 'CUI-001',
          articleDesignation: 'Cuir Véritable Marron',
          quantity: 80,
          unitPrice: 45.00,
        ),
        ArticleReception(
          articleReference: 'CUI-002',
          articleDesignation: 'Cuir Synthétique Noir',
          quantity: 120,
          unitPrice: 25.00,
        ),
        ArticleReception(
          articleReference: 'ACC-002',
          articleDesignation: 'Fermeture Éclair Métal 20cm',
          quantity: 500,
          unitPrice: 1.50,
        ),
      ],
    );
    
    final br004 = BonReception(
      id: 'br_004',
      numeroBR: 'BR2025004',
      clientId: 'client_001',
      dateReception: DateTime.now().subtract(const Duration(days: 30)),
      commandeNumber: 'CMD004',
      articles: [
        ArticleReception(
          articleReference: 'TEX-001',
          articleDesignation: 'Tissu Coton Premium',
          quantity: 600,
          unitPrice: 12.50,
        ),
        ArticleReception(
          articleReference: 'ACC-001',
          articleDesignation: 'Boutons Plastique 15mm',
          quantity: 1500,
          unitPrice: 0.50,
        ),
      ],
    );
    
    final br005 = BonReception(
      id: 'br_005',
      numeroBR: 'BR2025005',
      clientId: 'client_004',
      dateReception: DateTime.now().subtract(const Duration(days: 25)),
      commandeNumber: 'CMD005',
      articles: [
        ArticleReception(
          articleReference: 'TEX-002',
          articleDesignation: 'Tissu Polyester Standard',
          quantity: 1000,
          unitPrice: 10.00,
        ),
        ArticleReception(
          articleReference: 'FIL-001',
          articleDesignation: 'Fil à Coudre Polyester',
          quantity: 200,
          unitPrice: 5.00,
        ),
      ],
    );
    
    final br006 = BonReception(
      id: 'br_006',
      numeroBR: 'BR2025006',
      clientId: 'client_005',
      dateReception: DateTime.now().subtract(const Duration(days: 20)),
      commandeNumber: 'CMD006',
      articles: [
        ArticleReception(
          articleReference: 'TEX-003',
          articleDesignation: 'Tissu Lin Naturel',
          quantity: 400,
          unitPrice: 18.00,
        ),
      ],
    );
    
    final receptions = [br001, br002, br003, br004, br005, br006];
    for (var br in receptions) {
      await receptionBox.put(br.id, br);
    }
    print('✅ Created ${receptions.length} bons de réception');
  }
  
  static Future<void> _createBonLivraisons() async {
    print('🚚 Creating bons de livraison...');
    final livraisonBox = Hive.box<BonLivraison>('bon_livraison');
    
    // BL for Client 1
    final bl001 = BonLivraison(
      id: 'bl_001',
      blNumber: 'BL2025001',
      clientId: 'client_001',
      clientName: 'Société Tunisienne de Distribution',
      dateLivraison: DateTime.now().subtract(const Duration(days: 15)),
      articles: [
        ArticleLivraison(
          articleReference: 'TEX-001',
          articleDesignation: 'Tissu Coton Premium',
          quantityLivree: 200,
          treatmentId: 'treat_001',
          treatmentName: 'Teinture Rouge',
          prixUnitaire: 35.0,
          receptionId: 'br_001',
          commentaire: 'Qualité excellente',
        ),
        ArticleLivraison(
          articleReference: 'TEX-002',
          articleDesignation: 'Tissu Polyester Standard',
          quantityLivree: 300,
          treatmentId: 'treat_002',
          treatmentName: 'Teinture Bleue',
          prixUnitaire: 28.0,
          receptionId: 'br_001',
        ),
      ],
      status: 'livre',
      signature: 'Ahmed Ben Ali',
      notes: 'Livraison conforme',
    );
    
    final bl002 = BonLivraison(
      id: 'bl_002',
      blNumber: 'BL2025002',
      clientId: 'client_001',
      clientName: 'Société Tunisienne de Distribution',
      dateLivraison: DateTime.now().subtract(const Duration(days: 10)),
      articles: [
        ArticleLivraison(
          articleReference: 'ACC-001',
          articleDesignation: 'Boutons Plastique 15mm',
          quantityLivree: 1000,
          treatmentId: 'treat_008',
          treatmentName: 'Finition Standard',
          prixUnitaire: 0.5,
          receptionId: 'br_001',
        ),
      ],
      status: 'livre',
      signature: 'Mohamed Trabelsi',
    );
    
    final bl003 = BonLivraison(
      id: 'bl_003',
      blNumber: 'BL2025003',
      clientId: 'client_002',
      clientName: 'Entreprise Méditerranéenne',
      dateLivraison: DateTime.now().subtract(const Duration(days: 12)),
      articles: [
        ArticleLivraison(
          articleReference: 'TEX-003',
          articleDesignation: 'Tissu Lin Naturel',
          quantityLivree: 150,
          treatmentId: 'treat_004',
          treatmentName: 'Impression Floral',
          prixUnitaire: 45.0,
          receptionId: 'br_002',
          commentaire: 'Impression très réussie',
        ),
        ArticleLivraison(
          articleReference: 'FIL-001',
          articleDesignation: 'Fil à Coudre Polyester',
          quantityLivree: 80,
          treatmentId: 'treat_008',
          treatmentName: 'Finition Standard',
          prixUnitaire: 12.0,
          receptionId: 'br_002',
        ),
      ],
      status: 'livre',
      signature: 'Fatma Sassi',
      notes: 'Client satisfait',
    );
    
    final bl004 = BonLivraison(
      id: 'bl_004',
      blNumber: 'BL2025004',
      clientId: 'client_003',
      clientName: 'Commerce International Tunisie',
      dateLivraison: DateTime.now().subtract(const Duration(days: 8)),
      articles: [
        ArticleLivraison(
          articleReference: 'CUI-001',
          articleDesignation: 'Cuir Véritable Marron',
          quantityLivree: 40,
          treatmentId: 'treat_006',
          treatmentName: 'Broderie Main',
          prixUnitaire: 95.0,
          receptionId: 'br_003',
          commentaire: 'Broderie délicate',
        ),
        ArticleLivraison(
          articleReference: 'ACC-002',
          articleDesignation: 'Fermeture Éclair Métal 20cm',
          quantityLivree: 250,
          treatmentId: 'treat_008',
          treatmentName: 'Finition Standard',
          prixUnitaire: 3.5,
          receptionId: 'br_003',
        ),
      ],
      status: 'livre',
      signature: 'Karim Jemli',
    );
    
    final bl005 = BonLivraison(
      id: 'bl_005',
      blNumber: 'BL2025005',
      clientId: 'client_004',
      clientName: 'Négoce et Services SARL',
      dateLivraison: DateTime.now().subtract(const Duration(days: 5)),
      articles: [
        ArticleLivraison(
          articleReference: 'TEX-002',
          articleDesignation: 'Tissu Polyester Standard',
          quantityLivree: 400,
          treatmentId: 'treat_003',
          treatmentName: 'Teinture Verte',
          prixUnitaire: 28.0,
          receptionId: 'br_005',
        ),
      ],
      status: 'en_attente',
      notes: 'En cours de préparation',
    );
    
    final bl006 = BonLivraison(
      id: 'bl_006',
      blNumber: 'BL2025006',
      clientId: 'client_003',
      clientName: 'Commerce International Tunisie',
      dateLivraison: DateTime.now().subtract(const Duration(days: 3)),
      articles: [
        ArticleLivraison(
          articleReference: 'CUI-002',
          articleDesignation: 'Cuir Synthétique Noir',
          quantityLivree: 60,
          treatmentId: 'treat_007',
          treatmentName: 'Broderie Machine',
          prixUnitaire: 52.0,
          receptionId: 'br_003',
        ),
      ],
      status: 'livre',
      signature: 'Salah Mansour',
    );
    
    final bl007 = BonLivraison(
      id: 'bl_007',
      blNumber: 'BL2025007',
      clientId: 'client_001',
      clientName: 'Société Tunisienne de Distribution',
      dateLivraison: DateTime.now().subtract(const Duration(days: 2)),
      articles: [
        ArticleLivraison(
          articleReference: 'TEX-001',
          articleDesignation: 'Tissu Coton Premium',
          quantityLivree: 250,
          treatmentId: 'treat_005',
          treatmentName: 'Impression Géométrique',
          prixUnitaire: 35.0,
          receptionId: 'br_004',
          commentaire: 'Motif moderne très apprécié',
        ),
      ],
      status: 'en_attente',
    );
    
    final livraisons = [bl001, bl002, bl003, bl004, bl005, bl006, bl007];
    for (var bl in livraisons) {
      await livraisonBox.put(bl.id, bl);
    }
    print('✅ Created ${livraisons.length} bons de livraison');
  }
  
  static Future<void> _createFacturations() async {
    print('💰 Creating facturations...');
    final facturationBox = Hive.box<Facturation>('facturations');
    
    final fact001 = Facturation(
      id: 'fact_001',
      factureNumber: 'FAC2025001',
      clientFactureId: 'client_001',
      clientSourceId: 'client_001',
      dateFacture: DateTime.now().subtract(const Duration(days: 14)),
      blReferences: ['bl_001', 'bl_002'],
      totalAmount: 15250.50,
      status: 'valide',
      commentaires: 'Paiement par virement bancaire',
      dateCreation: DateTime.now().subtract(const Duration(days: 14)),
      dateModification: DateTime.now().subtract(const Duration(days: 14)),
    );
    
    final fact002 = Facturation(
      id: 'fact_002',
      factureNumber: 'FAC2025002',
      clientFactureId: 'client_002',
      clientSourceId: 'client_002',
      dateFacture: DateTime.now().subtract(const Duration(days: 11)),
      blReferences: ['bl_003'],
      totalAmount: 8750.00,
      status: 'envoye',
      commentaires: 'Facture envoyée par email',
      dateCreation: DateTime.now().subtract(const Duration(days: 11)),
      dateModification: DateTime.now().subtract(const Duration(days: 11)),
    );
    
    final fact003 = Facturation(
      id: 'fact_003',
      factureNumber: 'FAC2025003',
      clientFactureId: 'client_003',
      clientSourceId: 'client_003',
      dateFacture: DateTime.now().subtract(const Duration(days: 7)),
      blReferences: ['bl_004', 'bl_006'],
      totalAmount: 12300.75,
      status: 'paye',
      datePaiement: DateTime.now().subtract(const Duration(days: 2)),
      commentaires: 'Paiement reçu',
      dateCreation: DateTime.now().subtract(const Duration(days: 7)),
      dateModification: DateTime.now().subtract(const Duration(days: 2)),
    );
    
    final facturations = [fact001, fact002, fact003];
    for (var fact in facturations) {
      await facturationBox.put(fact.id, fact);
    }
    print('✅ Created ${facturations.length} facturations');
  }
}

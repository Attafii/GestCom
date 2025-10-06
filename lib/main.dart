import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'app/app.dart';
import 'data/models/client_model.dart';
import 'data/models/article_model.dart';
import 'data/models/treatment_model.dart';
import 'data/models/bon_reception_model.dart';
import 'data/models/article_reception_model.dart';
import 'data/models/bon_livraison_model.dart';
import 'data/models/article_livraison_model.dart';
import 'data/models/facturation_model.dart';
import 'core/services/initialization_service.dart';
import 'core/services/test_data_service.dart';
import 'core/database/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await _initializeHive();
  
  // Initialize HiveService for Settings and other advanced features
  try {
    await HiveService.initialize();
    debugPrint('HiveService initialized successfully');
  } catch (e) {
    debugPrint('Warning: HiveService initialization failed: $e');
    // Continue anyway - Settings will use defaults
  }
  
  // Initialize default data
  await InitializationService().initializeDefaultData();
  
  // Populate test data - COMMENT THIS LINE IN PRODUCTION
  await TestDataService.populateTestData();
  
  runApp(
    const ProviderScope(
      child: GestComApp(),
    ),
  );
}

Future<void> _initializeHive() async {
  // Get application documents directory for Windows
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final hiveDir = Directory('${appDocumentDir.path}/GestCom/data');
  
  // Create directory if it doesn't exist
  if (!await hiveDir.exists()) {
    await hiveDir.create(recursive: true);
  }
  
  // Initialize Hive with the custom directory
  await Hive.initFlutter(hiveDir.path);
  
  // Register TypeAdapters
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(ArticleAdapter());
  Hive.registerAdapter(TreatmentAdapter());
  Hive.registerAdapter(BonReceptionAdapter());
  Hive.registerAdapter(ArticleReceptionAdapter());
  Hive.registerAdapter(BonLivraisonAdapter());
  Hive.registerAdapter(ArticleLivraisonAdapter());
  Hive.registerAdapter(FacturationAdapter());
  
  // Open boxes
  await Hive.openBox<Client>('clients');
  await Hive.openBox<Article>('articles');
  await Hive.openBox<Treatment>('treatments');
  await Hive.openBox<BonReception>('bon_receptions');
  await Hive.openBox<BonLivraison>('bon_livraison');
  await Hive.openBox<Facturation>('facturations');
  await Hive.openBox('app_settings'); // For theme preferences
  
  debugPrint('Hive initialized successfully at: ${hiveDir.path}');
}
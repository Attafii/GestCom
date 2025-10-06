import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../client/application/client_providers.dart';
import '../../reception/application/bon_reception_providers.dart';
import '../../livraison/application/bon_livraison_providers.dart';
import '../../facturation/application/facturation_providers.dart';

part 'dashboard_providers.g.dart';

// Dashboard statistics provider
@riverpod
Map<String, dynamic> dashboardStatistics(DashboardStatisticsRef ref) {
  final clientRepo = ref.read(clientRepositoryProvider);
  final receptionRepo = ref.read(bonReceptionRepositoryProvider);
  final livraisonRepo = ref.read(bonLivraisonRepositoryProvider);
  final facturationRepo = ref.read(facturationRepositoryProvider);
  
  // Get all data
  final clients = clientRepo.getAllClients();
  final receptions = receptionRepo.getAllReceptions();
  final livraisons = livraisonRepo.getAllDeliveries();
  final factures = facturationRepo.getAllInvoices();
  
  // Calculate reception stats
  final currentMonth = DateTime.now();
  final startOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
  final currentMonthReceptions = receptions.where((r) => 
      r.dateReception.isAfter(startOfMonth)).toList();
  
  final totalReceptionAmount = currentMonthReceptions.fold<double>(
    0.0, (sum, r) => sum + r.totalAmount);
  
  final totalReceptionQuantity = currentMonthReceptions.fold<int>(
    0, (sum, r) => sum + r.totalQuantity);
  
  // Calculate livraison stats
  final currentMonthLivraisons = livraisons.where((l) => 
      l.dateLivraison.isAfter(startOfMonth)).toList();
  
  final totalLivraisonPieces = currentMonthLivraisons.fold<int>(
    0, (sum, l) => sum + l.totalPieces);
  
  // Calculate facturation stats
  final currentMonthFactures = factures.where((f) => 
      f.dateFacture.isAfter(startOfMonth)).toList();
  
  final totalCA = currentMonthFactures.fold<double>(
    0.0, (sum, f) => sum + f.totalAmount);
  
  final totalPaid = factures.where((f) => f.status == 'paye')
      .fold<double>(0.0, (sum, f) => sum + f.totalAmount);
  
  final totalUnpaid = factures.where((f) => 
      ['brouillon', 'valide', 'envoye'].contains(f.status))
      .fold<double>(0.0, (sum, f) => sum + f.totalAmount);
  
  return {
    // Client stats
    'totalClients': clients.length,
    'activeClients': clients.length, // All clients are considered active
    
    // Reception stats
    'totalReceptions': receptions.length,
    'currentMonthReceptions': currentMonthReceptions.length,
    'totalReceptionAmount': totalReceptionAmount,
    'totalReceptionQuantity': totalReceptionQuantity,
    
    // Livraison stats
    'totalLivraisons': livraisons.length,
    'currentMonthLivraisons': currentMonthLivraisons.length,
    'pendingLivraisons': livraisons.where((l) => l.status == 'en_attente').length,
    'deliveredLivraisons': livraisons.where((l) => l.status == 'livre').length,
    'totalLivraisonPieces': totalLivraisonPieces,
    
    // Facturation stats
    'totalFactures': factures.length,
    'currentMonthFactures': currentMonthFactures.length,
    'totalCA': totalCA,
    'totalPaid': totalPaid,
    'totalUnpaid': totalUnpaid,
    'paidFactures': factures.where((f) => f.status == 'paye').length,
    'unpaidFactures': factures.where((f) => f.status != 'paye' && f.status != 'annule').length,
  };
}

// Recent activities provider
@riverpod
List<Map<String, dynamic>> recentActivities(RecentActivitiesRef ref) {
  final receptionRepo = ref.read(bonReceptionRepositoryProvider);
  final livraisonRepo = ref.read(bonLivraisonRepositoryProvider);
  final facturationRepo = ref.read(facturationRepositoryProvider);
  
  final activities = <Map<String, dynamic>>[];
  
  // Get recent receptions (last 10)
  final receptions = receptionRepo.getAllReceptions()
      .where((r) => r.dateReception.isAfter(DateTime.now().subtract(const Duration(days: 30))))
      .toList()
    ..sort((a, b) => b.dateReception.compareTo(a.dateReception));
  
  for (var r in receptions.take(5)) {
    activities.add({
      'type': 'reception',
      'title': 'Bon de Réception ${r.numeroBR}',
      'subtitle': '${r.articles.length} articles - ${r.totalQuantity} pcs',
      'date': r.dateReception,
      'amount': r.totalAmount,
    });
  }
  
  // Get recent livraisons (last 10)
  final livraisons = livraisonRepo.getAllDeliveries()
      .where((l) => l.dateLivraison.isAfter(DateTime.now().subtract(const Duration(days: 30))))
      .toList()
    ..sort((a, b) => b.dateLivraison.compareTo(a.dateLivraison));
  
  for (var l in livraisons.take(5)) {
    activities.add({
      'type': 'livraison',
      'title': 'Bon de Livraison ${l.blNumber}',
      'subtitle': '${l.clientName} - ${l.totalPieces} pcs',
      'date': l.dateLivraison,
      'status': l.status,
    });
  }
  
  // Get recent factures (last 5)
  final factures = facturationRepo.getAllInvoices()
      .where((f) => f.dateFacture.isAfter(DateTime.now().subtract(const Duration(days: 30))))
      .toList()
    ..sort((a, b) => b.dateFacture.compareTo(a.dateFacture));
  
  for (var f in factures.take(5)) {
    activities.add({
      'type': 'facture',
      'title': 'Facture ${f.factureNumber}',
      'subtitle': '${f.blReferences.length} BL',
      'date': f.dateFacture,
      'amount': f.totalAmount,
      'status': f.status,
    });
  }
  
  // Sort all activities by date
  activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  
  return activities.take(10).toList();
}

// Top clients provider (by reception amount)
@riverpod
List<Map<String, dynamic>> topClients(TopClientsRef ref) {
  final clientRepo = ref.read(clientRepositoryProvider);
  final receptionRepo = ref.read(bonReceptionRepositoryProvider);
  
  final clients = clientRepo.getAllClients();
  final receptions = receptionRepo.getAllReceptions();
  
  final clientStats = <String, Map<String, dynamic>>{};
  
  for (var client in clients) {
    final clientReceptions = receptions.where((r) => r.clientId == client.id).toList();
    final totalAmount = clientReceptions.fold<double>(0.0, (sum, r) => sum + r.totalAmount);
    final totalQuantity = clientReceptions.fold<int>(0, (sum, r) => sum + r.totalQuantity);
    
    clientStats[client.id] = {
      'clientId': client.id,
      'clientName': client.name,
      'receptionCount': clientReceptions.length,
      'totalAmount': totalAmount,
      'totalQuantity': totalQuantity,
    };
  }
  
  final sortedClients = clientStats.values.toList()
    ..sort((a, b) => (b['totalAmount'] as double).compareTo(a['totalAmount'] as double));
  
  return sortedClients.take(10).toList();
}

// Monthly trend provider
@riverpod
Map<String, List<Map<String, dynamic>>> monthlyTrends(MonthlyTrendsRef ref) {
  final receptionRepo = ref.read(bonReceptionRepositoryProvider);
  final livraisonRepo = ref.read(bonLivraisonRepositoryProvider);
  final facturationRepo = ref.read(facturationRepositoryProvider);
  
  final now = DateTime.now();
  final last6Months = List.generate(6, (i) => DateTime(now.year, now.month - i, 1));
  
  final receptionTrend = <Map<String, dynamic>>[];
  final livraisonTrend = <Map<String, dynamic>>[];
  final facturationTrend = <Map<String, dynamic>>[];
  
  for (var month in last6Months.reversed) {
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    
    // Reception trend
    final monthReceptions = receptionRepo.getAllReceptions()
        .where((r) => r.dateReception.isAfter(month) && r.dateReception.isBefore(nextMonth))
        .toList();
    
    receptionTrend.add({
      'month': month,
      'count': monthReceptions.length,
      'totalAmount': monthReceptions.fold<double>(0.0, (sum, r) => sum + r.totalAmount),
    });
    
    // Livraison trend
    final monthLivraisons = livraisonRepo.getAllDeliveries()
        .where((l) => l.dateLivraison.isAfter(month) && l.dateLivraison.isBefore(nextMonth))
        .toList();
    
    livraisonTrend.add({
      'month': month,
      'count': monthLivraisons.length,
      'totalPieces': monthLivraisons.fold<int>(0, (sum, l) => sum + l.totalPieces),
    });
    
    // Facturation trend
    final monthFactures = facturationRepo.getAllInvoices()
        .where((f) => f.dateFacture.isAfter(month) && f.dateFacture.isBefore(nextMonth))
        .toList();
    
    facturationTrend.add({
      'month': month,
      'count': monthFactures.length,
      'totalAmount': monthFactures.fold<double>(0.0, (sum, f) => sum + f.totalAmount),
    });
  }
  
  return {
    'receptions': receptionTrend,
    'livraisons': livraisonTrend,
    'facturations': facturationTrend,
  };
}

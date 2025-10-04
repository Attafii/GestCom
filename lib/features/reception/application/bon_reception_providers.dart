import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/bon_reception_repository.dart';
import '../../../data/models/bon_reception_model.dart';

part 'bon_reception_providers.g.dart';

// Repository provider
@riverpod
BonReceptionRepository bonReceptionRepository(BonReceptionRepositoryRef ref) {
  return BonReceptionRepository();
}

// Search query provider
@riverpod
class BonReceptionSearchQuery extends _$BonReceptionSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// Client filter provider
@riverpod
class BonReceptionClientFilter extends _$BonReceptionClientFilter {
  @override
  String? build() => null;

  void selectClient(String? clientId) {
    state = clientId;
  }

  void clearFilter() {
    state = null;
  }
}

// Date range filter provider
@riverpod
class BonReceptionDateFilter extends _$BonReceptionDateFilter {
  @override
  DateRange? build() => null;

  void selectDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      state = DateRange(startDate: startDate, endDate: endDate);
    } else {
      state = null;
    }
  }

  void clearFilter() {
    state = null;
  }
}

// Helper class for date range
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});
}

// Main receptions list provider with filters
@riverpod
class BonReceptionList extends _$BonReceptionList {
  @override
  List<BonReception> build() {
    final repository = ref.watch(bonReceptionRepositoryProvider);
    final searchQuery = ref.watch(bonReceptionSearchQueryProvider);
    final clientFilter = ref.watch(bonReceptionClientFilterProvider);
    final dateFilter = ref.watch(bonReceptionDateFilterProvider);

    List<BonReception> receptions;

    // Apply date filter first
    if (dateFilter != null) {
      receptions = repository.getReceptionsByDateRange(
        dateFilter.startDate,
        dateFilter.endDate,
      );
    } else {
      receptions = repository.getAllReceptions();
    }

    // Apply search and client filters
    if (searchQuery.isNotEmpty || clientFilter != null) {
      receptions = repository.searchReceptions(
        searchQuery,
        clientId: clientFilter,
      );
    }

    return receptions;
  }

  // Add new reception
  Future<void> addReception(BonReception reception) async {
    final repository = ref.read(bonReceptionRepositoryProvider);
    await repository.addReception(reception);
    ref.invalidateSelf();
  }

  // Update reception
  Future<void> updateReception(BonReception reception) async {
    final repository = ref.read(bonReceptionRepositoryProvider);
    await repository.updateReception(reception);
    ref.invalidateSelf();
  }

  // Delete reception
  Future<void> deleteReception(String id) async {
    final repository = ref.read(bonReceptionRepositoryProvider);
    await repository.deleteReception(id);
    ref.invalidateSelf();
  }

  // Refresh data
  void refresh() {
    ref.invalidateSelf();
  }
}

// Receptions by client provider
@riverpod
List<BonReception> receptionsByClient(ReceptionsByClientRef ref, String clientId) {
  final repository = ref.watch(bonReceptionRepositoryProvider);
  return repository.getReceptionsByClient(clientId);
}

// Recent receptions provider
@riverpod
List<BonReception> recentReceptions(RecentReceptionsRef ref, {int days = 30}) {
  final repository = ref.watch(bonReceptionRepositoryProvider);
  return repository.getRecentReceptions(days: days);
}

// Reception statistics provider
@riverpod
Map<String, dynamic> receptionStatistics(ReceptionStatisticsRef ref) {
  final repository = ref.watch(bonReceptionRepositoryProvider);
  final now = DateTime.now();
  
  // Current month statistics
  final currentMonth = DateTime(now.year, now.month, 1);
  final nextMonth = DateTime(now.year, now.month + 1, 1);
  final monthStats = repository.getStatisticsByDateRange(currentMonth, nextMonth);
  
  // Current year statistics
  final currentYear = DateTime(now.year, 1, 1);
  final nextYear = DateTime(now.year + 1, 1, 1);
  final yearStats = repository.getStatisticsByDateRange(currentYear, nextYear);
  
  return {
    'total': {
      'count': repository.getReceptionsCount(),
      'amount': repository.getTotalAmount(),
    },
    'currentMonth': monthStats,
    'currentYear': yearStats,
  };
}

// Individual reception provider
@riverpod
BonReception? receptionById(ReceptionByIdRef ref, String id) {
  final repository = ref.watch(bonReceptionRepositoryProvider);
  return repository.getReceptionById(id);
}
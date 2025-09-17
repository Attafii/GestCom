import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/facturation_repository.dart';
import '../../../data/models/facturation_model.dart';
import '../../../data/models/bon_livraison_model.dart';
import '../../../data/models/client_model.dart';

part 'facturation_providers.g.dart';

// Repository provider
@Riverpod(keepAlive: true)
FacturationRepository facturationRepository(FacturationRepositoryRef ref) {
  return FacturationRepository();
}

// Get all invoices
@riverpod
List<Facturation> allInvoices(AllInvoicesRef ref) {
  final repository = ref.watch(facturationRepositoryProvider);
  return repository.getAllInvoices();
}

// Get invoices by client
@riverpod
List<Facturation> invoicesByClient(InvoicesByClientRef ref, String clientId) {
  final repository = ref.watch(facturationRepositoryProvider);
  return repository.getInvoicesByClient(clientId);
}

// Get invoices by status
@riverpod
List<Facturation> invoicesByStatus(InvoicesByStatusRef ref, String status) {
  final repository = ref.watch(facturationRepositoryProvider);
  return repository.getInvoicesByStatus(status);
}

// Get pending invoices
@riverpod
List<Facturation> pendingInvoices(PendingInvoicesRef ref) {
  final repository = ref.watch(facturationRepositoryProvider);
  return repository.getPendingInvoices();
}

// Get paid invoices
@riverpod
List<Facturation> paidInvoices(PaidInvoicesRef ref) {
  final repository = ref.watch(facturationRepositoryProvider);
  return repository.getPaidInvoices();
}

// Get pending BLs for invoicing
@riverpod
List<BonLivraison> pendingBLsForInvoicing(PendingBLsForInvoicingRef ref) {
  final repository = ref.watch(facturationRepositoryProvider);
  return repository.getPendingBLsForInvoicing();
}

// Get pending BLs for specific client
@riverpod
List<BonLivraison> pendingBLsForClient(PendingBLsForClientRef ref, String clientId) {
  final repository = ref.watch(facturationRepositoryProvider);
  return repository.getPendingBLsForClient(clientId);
}

// Get invoice statistics
@riverpod
Map<String, dynamic> facturationStatistics(FacturationStatisticsRef ref) {
  final repository = ref.watch(facturationRepositoryProvider);
  return repository.getStatistics();
}

// Selected client for filtering (can be facture or source client)
@riverpod
class SelectedFacturationClient extends _$SelectedFacturationClient {
  @override
  String? build() => null;

  void selectClient(String? clientId) {
    state = clientId;
  }

  void clearSelection() {
    state = null;
  }
}

// Selected status filter
@riverpod
class SelectedFacturationStatus extends _$SelectedFacturationStatus {
  @override
  String? build() => null;

  void selectStatus(String? status) {
    state = status;
  }

  void clearSelection() {
    state = null;
  }
}

// Search query for invoices
@riverpod
class FacturationSearchQuery extends _$FacturationSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// Filtered invoices based on search and filters
@riverpod
List<Facturation> filteredInvoices(FilteredInvoicesRef ref) {
  final allInvoices = ref.watch(allInvoicesProvider);
  final selectedClient = ref.watch(selectedFacturationClientProvider);
  final selectedStatus = ref.watch(selectedFacturationStatusProvider);
  final searchQuery = ref.watch(facturationSearchQueryProvider);

  var filtered = allInvoices;

  // Filter by client
  if (selectedClient != null) {
    filtered = filtered.where((invoice) => 
        invoice.clientFactureId == selectedClient || 
        invoice.clientSourceId == selectedClient).toList();
  }

  // Filter by status
  if (selectedStatus != null) {
    filtered = filtered.where((invoice) => 
        invoice.status == selectedStatus).toList();
  }

  // Filter by search query
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filtered = filtered.where((invoice) => 
        invoice.factureNumber.toLowerCase().contains(query) ||
        invoice.blReferences.any((bl) => bl.toLowerCase().contains(query)) ||
        invoice.commentaires?.toLowerCase().contains(query) == true).toList();
  }

  return filtered;
}

// Form state management for creating/editing invoices
@riverpod
class FacturationFormState extends _$FacturationFormState {
  @override
  FacturationFormData build() => FacturationFormData();

  void updateClientFacture(String clientId) {
    state = state.copyWith(clientFactureId: clientId);
  }

  void updateClientSource(String clientId) {
    state = state.copyWith(clientSourceId: clientId);
  }

  void updateDateFacture(DateTime date) {
    state = state.copyWith(dateFacture: date);
  }

  void updateSelectedBLs(List<String> blIds) {
    state = state.copyWith(selectedBLs: blIds);
  }

  void addBL(String blId) {
    final updated = List<String>.from(state.selectedBLs)..add(blId);
    state = state.copyWith(selectedBLs: updated);
  }

  void removeBL(String blId) {
    final updated = List<String>.from(state.selectedBLs)..remove(blId);
    state = state.copyWith(selectedBLs: updated);
  }

  void updateCommentaires(String? commentaires) {
    state = state.copyWith(commentaires: commentaires);
  }

  void reset() {
    state = FacturationFormData();
  }

  void loadFromFacturation(Facturation facturation) {
    state = FacturationFormData(
      clientFactureId: facturation.clientFactureId,
      clientSourceId: facturation.clientSourceId,
      dateFacture: facturation.dateFacture,
      selectedBLs: facturation.blReferences,
      commentaires: facturation.commentaires,
    );
  }
}

// Form data class
class FacturationFormData {
  final String? clientFactureId;
  final String? clientSourceId;
  final DateTime? dateFacture;
  final List<String> selectedBLs;
  final String? commentaires;

  FacturationFormData({
    this.clientFactureId,
    this.clientSourceId,
    this.dateFacture,
    this.selectedBLs = const [],
    this.commentaires,
  });

  FacturationFormData copyWith({
    String? clientFactureId,
    String? clientSourceId,
    DateTime? dateFacture,
    List<String>? selectedBLs,
    String? commentaires,
  }) {
    return FacturationFormData(
      clientFactureId: clientFactureId ?? this.clientFactureId,
      clientSourceId: clientSourceId ?? this.clientSourceId,
      dateFacture: dateFacture ?? this.dateFacture,
      selectedBLs: selectedBLs ?? this.selectedBLs,
      commentaires: commentaires ?? this.commentaires,
    );
  }

  bool get isValid {
    return clientFactureId != null &&
           clientSourceId != null &&
           dateFacture != null &&
           selectedBLs.isNotEmpty;
  }
}

// CRUD operations
@riverpod
class FacturationCrud extends _$FacturationCrud {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> createInvoice(FacturationFormData formData) async {
    if (!formData.isValid) {
      throw Exception('Données du formulaire invalides');
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(facturationRepositoryProvider);
      
      final factureNumber = repository.generateNextFactureNumber();
      final totalAmount = repository.calculateTotalFromBLs(formData.selectedBLs);

      final invoice = Facturation(
        factureNumber: factureNumber,
        clientFactureId: formData.clientFactureId!,
        clientSourceId: formData.clientSourceId!,
        dateFacture: formData.dateFacture!,
        blReferences: formData.selectedBLs,
        totalAmount: totalAmount,
        commentaires: formData.commentaires,
      );

      await repository.createInvoice(invoice);
      
      // Reset form and refresh providers
      ref.read(facturationFormStateProvider.notifier).reset();
      ref.invalidate(allInvoicesProvider);
      ref.invalidate(pendingBLsForInvoicingProvider);
      ref.invalidate(facturationStatisticsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateInvoice(String invoiceId, FacturationFormData formData) async {
    if (!formData.isValid) {
      throw Exception('Données du formulaire invalides');
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(facturationRepositoryProvider);
      final existingInvoice = repository.getInvoiceById(invoiceId);
      
      if (existingInvoice == null) {
        throw Exception('Facture non trouvée');
      }

      final totalAmount = repository.calculateTotalFromBLs(formData.selectedBLs);

      final updatedInvoice = existingInvoice.copyWith(
        clientFactureId: formData.clientFactureId,
        clientSourceId: formData.clientSourceId,
        dateFacture: formData.dateFacture,
        blReferences: formData.selectedBLs,
        totalAmount: totalAmount,
        commentaires: formData.commentaires,
      );

      await repository.updateInvoice(updatedInvoice);
      
      // Refresh providers
      ref.invalidate(allInvoicesProvider);
      ref.invalidate(pendingBLsForInvoicingProvider);
      ref.invalidate(facturationStatisticsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(facturationRepositoryProvider);
      await repository.deleteInvoice(invoiceId);
      
      // Refresh providers
      ref.invalidate(allInvoicesProvider);
      ref.invalidate(pendingBLsForInvoicingProvider);
      ref.invalidate(facturationStatisticsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> markAsPaid(String invoiceId, DateTime paymentDate) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(facturationRepositoryProvider);
      await repository.markAsPaid(invoiceId, paymentDate);
      
      // Refresh providers
      ref.invalidate(allInvoicesProvider);
      ref.invalidate(facturationStatisticsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> cancelInvoice(String invoiceId, String reason) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(facturationRepositoryProvider);
      await repository.cancelInvoice(invoiceId, reason);
      
      // Refresh providers
      ref.invalidate(allInvoicesProvider);
      ref.invalidate(pendingBLsForInvoicingProvider);
      ref.invalidate(facturationStatisticsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
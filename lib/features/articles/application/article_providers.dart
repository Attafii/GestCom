import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/article_model.dart';
import '../../../data/repositories/article_repository.dart';

part 'article_providers.g.dart';

// Repository provider
@riverpod
ArticleRepository articleRepository(ArticleRepositoryRef ref) {
  return ArticleRepository();
}

// Article list provider
@riverpod
class ArticleList extends _$ArticleList {
  @override
  List<Article> build() {
    final repository = ref.read(articleRepositoryProvider);
    return repository.getAllArticles();
  }

  // Add article
  Future<void> addArticle(Article article) async {
    final repository = ref.read(articleRepositoryProvider);
    try {
      await repository.addArticle(article);
      state = repository.getAllArticles();
    } catch (e) {
      rethrow;
    }
  }

  // Update article
  Future<void> updateArticle(Article article) async {
    final repository = ref.read(articleRepositoryProvider);
    try {
      await repository.updateArticle(article);
      state = repository.getAllArticles();
    } catch (e) {
      rethrow;
    }
  }

  // Delete article
  Future<void> deleteArticle(String id) async {
    final repository = ref.read(articleRepositoryProvider);
    try {
      await repository.deleteArticle(id);
      state = repository.getAllArticles();
    } catch (e) {
      rethrow;
    }
  }

  // Toggle article status
  Future<void> toggleArticleStatus(String id) async {
    final repository = ref.read(articleRepositoryProvider);
    try {
      await repository.toggleArticleStatus(id);
      state = repository.getAllArticles();
    } catch (e) {
      rethrow;
    }
  }

  // Search articles
  void searchArticles(String query, {bool? activeOnly, String? clientId}) {
    final repository = ref.read(articleRepositoryProvider);
    state = repository.searchArticles(query, activeOnly: activeOnly, clientId: clientId);
  }

  // Filter by status
  void filterByStatus(bool? isActive, {String? clientId}) {
    final repository = ref.read(articleRepositoryProvider);
    if (clientId != null) {
      state = repository.getArticlesByClient(clientId, activeOnly: isActive);
    } else if (isActive == null) {
      state = repository.getAllArticles();
    } else {
      state = repository.getArticlesByStatus(isActive);
    }
  }

  // Filter by client
  void filterByClient(String? clientId, {bool? activeOnly}) {
    final repository = ref.read(articleRepositoryProvider);
    if (clientId == null) {
      state = activeOnly == true ? repository.getActiveArticles() : repository.getAllArticles();
    } else {
      state = repository.getArticlesByClient(clientId, activeOnly: activeOnly);
    }
  }

  // Refresh articles list
  void refresh() {
    final repository = ref.read(articleRepositoryProvider);
    state = repository.getAllArticles();
  }
}

// Search query provider
@riverpod
class ArticleSearchQuery extends _$ArticleSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
    final activeFilter = ref.read(articleActiveFilterProvider);
    final clientFilter = ref.read(articleClientFilterProvider);
    ref.read(articleListProvider.notifier).searchArticles(
      query, 
      activeOnly: activeFilter,
      clientId: clientFilter,
    );
  }

  void clear() {
    state = '';
    ref.read(articleListProvider.notifier).refresh();
  }
}

// Active filter provider
@riverpod
class ArticleActiveFilter extends _$ArticleActiveFilter {
  @override
  bool? build() => null; // null = all, true = active only, false = inactive only

  void setFilter(bool? isActive) {
    state = isActive;
    final query = ref.read(articleSearchQueryProvider);
    final clientFilter = ref.read(articleClientFilterProvider);
    if (query.isNotEmpty) {
      ref.read(articleListProvider.notifier).searchArticles(
        query, 
        activeOnly: isActive,
        clientId: clientFilter,
      );
    } else {
      ref.read(articleListProvider.notifier).filterByStatus(isActive, clientId: clientFilter);
    }
  }

  void clearFilter() {
    state = null;
    ref.read(articleListProvider.notifier).refresh();
  }
}

// Client filter provider
@riverpod
class ArticleClientFilter extends _$ArticleClientFilter {
  @override
  String? build() => null; // null = all clients

  void setFilter(String? clientId) {
    state = clientId;
    final query = ref.read(articleSearchQueryProvider);
    final activeFilter = ref.read(articleActiveFilterProvider);
    
    // Handle special "general" value for general articles (clientId = null)
    final actualClientId = clientId == 'general' ? null : clientId;
    
    if (query.isNotEmpty) {
      ref.read(articleListProvider.notifier).searchArticles(
        query,
        activeOnly: activeFilter,
        clientId: actualClientId,
      );
    } else {
      ref.read(articleListProvider.notifier).filterByClient(actualClientId, activeOnly: activeFilter);
    }
  }

  void clearFilter() {
    state = null;
    final activeFilter = ref.read(articleActiveFilterProvider);
    ref.read(articleListProvider.notifier).filterByStatus(activeFilter);
  }
}

// Selected article provider (for editing)
@riverpod
class SelectedArticle extends _$SelectedArticle {
  @override
  Article? build() => null;

  void selectArticle(Article? article) {
    state = article;
  }

  void clearSelection() {
    state = null;
  }
}

// Article form state provider
@riverpod
class ArticleFormState extends _$ArticleFormState {
  @override
  Map<String, dynamic> build() {
    return {
      'reference': '',
      'designation': '',
      'traitementPrix': <String, double>{},
      'isActive': true,
    };
  }

  void updateField(String field, dynamic value) {
    state = {...state, field: value};
  }

  void updateTreatmentPrice(String treatmentId, double price) {
    final currentPrices = Map<String, double>.from(state['traitementPrix'] as Map<String, double>);
    currentPrices[treatmentId] = price;
    state = {...state, 'traitementPrix': currentPrices};
  }

  void removeTreatmentPrice(String treatmentId) {
    final currentPrices = Map<String, double>.from(state['traitementPrix'] as Map<String, double>);
    currentPrices.remove(treatmentId);
    state = {...state, 'traitementPrix': currentPrices};
  }

  void loadArticle(Article article) {
    state = {
      'reference': article.reference,
      'designation': article.designation,
      'traitementPrix': Map<String, double>.from(article.traitementPrix),
      'isActive': article.isActive,
    };
  }

  void clear() {
    state = {
      'reference': '',
      'designation': '',
      'traitementPrix': <String, double>{},
      'isActive': true,
    };
  }

  bool get isValid {
    final reference = state['reference'] as String;
    final designation = state['designation'] as String;
    final traitementPrix = state['traitementPrix'] as Map<String, double>;
    
    return reference.isNotEmpty &&
           designation.isNotEmpty &&
           traitementPrix.isNotEmpty;
  }
}

// Active articles count provider
@riverpod
int activeArticlesCount(ActiveArticlesCountRef ref) {
  final repository = ref.read(articleRepositoryProvider);
  return repository.getActiveArticlesCount();
}

// Active articles provider
@riverpod
List<Article> activeArticles(ActiveArticlesRef ref) {
  final repository = ref.read(articleRepositoryProvider);
  return repository.getActiveArticles();
}

// Articles statistics provider
@riverpod
Map<String, int> articleStatsByTreatment(ArticleStatsByTreatmentRef ref) {
  final repository = ref.read(articleRepositoryProvider);
  return repository.getArticleStatsByTreatment();
}
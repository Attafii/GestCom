import 'package:hive/hive.dart';
import '../models/article_model.dart';

class ArticleRepository {
  static const String _boxName = 'articles';
  
  Box<Article> get _box => Hive.box<Article>(_boxName);

  // Get all articles
  List<Article> getAllArticles() {
    return _box.values.toList()
      ..sort((a, b) => a.reference.compareTo(b.reference));
  }

  // Get active articles only
  List<Article> getActiveArticles() {
    return _box.values.where((article) => article.isActive).toList()
      ..sort((a, b) => a.reference.compareTo(b.reference));
  }

  // Get articles by active status
  List<Article> getArticlesByStatus(bool isActive) {
    return _box.values.where((article) => article.isActive == isActive).toList()
      ..sort((a, b) => a.reference.compareTo(b.reference));
  }

  // Get articles by client ID
  List<Article> getArticlesByClient(String clientId, {bool? activeOnly}) {
    return _box.values.where((article) {
      if (activeOnly == true && !article.isActive) return false;
      return article.clientId == clientId;
    }).toList()
      ..sort((a, b) => a.reference.compareTo(b.reference));
  }

  // Get articles without client (general articles)
  List<Article> getGeneralArticles({bool? activeOnly}) {
    return _box.values.where((article) {
      if (activeOnly == true && !article.isActive) return false;
      return article.clientId == null;
    }).toList()
      ..sort((a, b) => a.reference.compareTo(b.reference));
  }

  // Get article by ID
  Article? getArticleById(String id) {
    return _box.values.firstWhere(
      (article) => article.id == id,
      orElse: () => throw Exception('Article not found'),
    );
  }

  // Get article by reference
  Article? getArticleByReference(String reference) {
    try {
      return _box.values.firstWhere(
        (article) => article.reference == reference,
      );
    } catch (e) {
      return null;
    }
  }

  // Search articles
  List<Article> searchArticles(String query, {bool? activeOnly, String? clientId}) {
    if (query.isEmpty && clientId == null) {
      return activeOnly == true ? getActiveArticles() : getAllArticles();
    }
    
    final lowercaseQuery = query.toLowerCase();
    var articles = _box.values.where((article) {
      if (activeOnly == true && !article.isActive) return false;
      if (clientId != null && article.clientId != clientId) return false;
      
      if (query.isEmpty) return true;
      
      return article.reference.toLowerCase().contains(lowercaseQuery) ||
             article.designation.toLowerCase().contains(lowercaseQuery);
    }).toList();
    
    return articles..sort((a, b) => a.reference.compareTo(b.reference));
  }

  // Get articles with specific treatment
  List<Article> getArticlesWithTreatment(String treatmentId, {bool? activeOnly}) {
    return _box.values.where((article) {
      if (activeOnly == true && !article.isActive) return false;
      return article.hasTreatment(treatmentId);
    }).toList()
      ..sort((a, b) => a.reference.compareTo(b.reference));
  }

  // Add new article
  Future<void> addArticle(Article article) async {
    // Check if reference already exists
    final existingArticle = getArticleByReference(article.reference);
    
    if (existingArticle != null) {
      throw Exception('Un article avec cette référence existe déjà');
    }

    await _box.put(article.id, article);
  }

  // Update existing article
  Future<void> updateArticle(Article article) async {
    if (!_box.containsKey(article.id)) {
      throw Exception('Article not found');
    }

    // Check if reference already exists for another article
    Article? existingArticle;
    try {
      existingArticle = _box.values.firstWhere(
        (a) => a.reference == article.reference && a.id != article.id,
      );
    } catch (e) {
      existingArticle = null;
    }
    
    if (existingArticle != null) {
      throw Exception('Un article avec cette référence existe déjà');
    }

    await _box.put(article.id, article);
  }

  // Delete article
  Future<void> deleteArticle(String id) async {
    if (!_box.containsKey(id)) {
      throw Exception('Article not found');
    }

    await _box.delete(id);
  }

  // Toggle article active status
  Future<void> toggleArticleStatus(String id) async {
    final article = _box.get(id);
    if (article == null) {
      throw Exception('Article not found');
    }

    final updatedArticle = article.copyWith(isActive: !article.isActive);
    await _box.put(id, updatedArticle);
  }

  // Get articles count
  int getArticlesCount() {
    return _box.length;
  }

  // Get active articles count
  int getActiveArticlesCount() {
    return _box.values.where((article) => article.isActive).length;
  }

  // Check if reference exists
  bool referenceExists(String reference, {String? excludeId}) {
    return _box.values.any((article) => 
      article.reference == reference && 
      (excludeId == null || article.id != excludeId)
    );
  }

  // Get articles statistics by treatment
  Map<String, int> getArticleStatsByTreatment() {
    final stats = <String, int>{};
    
    for (final article in _box.values) {
      if (article.isActive) {
        for (final treatmentId in article.treatmentIds) {
          stats[treatmentId] = (stats[treatmentId] ?? 0) + 1;
        }
      }
    }
    
    return stats;
  }

  // Export articles to JSON
  List<Map<String, dynamic>> exportToJson() {
    return _box.values.map((article) => article.toJson()).toList();
  }

  // Clear all articles (for testing or reset)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
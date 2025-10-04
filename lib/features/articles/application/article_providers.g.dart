// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$articleRepositoryHash() => r'e672e6daf581e34c213f70ca9755c87d377ca88e';

/// See also [articleRepository].
@ProviderFor(articleRepository)
final articleRepositoryProvider =
    AutoDisposeProvider<ArticleRepository>.internal(
  articleRepository,
  name: r'articleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$articleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ArticleRepositoryRef = AutoDisposeProviderRef<ArticleRepository>;
String _$activeArticlesCountHash() =>
    r'd71338223c841586095467a34aae5a1c2b011001';

/// See also [activeArticlesCount].
@ProviderFor(activeArticlesCount)
final activeArticlesCountProvider = AutoDisposeProvider<int>.internal(
  activeArticlesCount,
  name: r'activeArticlesCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeArticlesCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveArticlesCountRef = AutoDisposeProviderRef<int>;
String _$activeArticlesHash() => r'be5aba56dca8d2170a35471392b33e0c6db09f35';

/// See also [activeArticles].
@ProviderFor(activeArticles)
final activeArticlesProvider = AutoDisposeProvider<List<Article>>.internal(
  activeArticles,
  name: r'activeArticlesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeArticlesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveArticlesRef = AutoDisposeProviderRef<List<Article>>;
String _$articleStatsByTreatmentHash() =>
    r'952e8641a9bfc8884b29a7cc75eca56edc39dec5';

/// See also [articleStatsByTreatment].
@ProviderFor(articleStatsByTreatment)
final articleStatsByTreatmentProvider =
    AutoDisposeProvider<Map<String, int>>.internal(
  articleStatsByTreatment,
  name: r'articleStatsByTreatmentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$articleStatsByTreatmentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ArticleStatsByTreatmentRef = AutoDisposeProviderRef<Map<String, int>>;
String _$articleListHash() => r'430534c9613779e361bbe2f6a0a2c63ee97bb9c2';

/// See also [ArticleList].
@ProviderFor(ArticleList)
final articleListProvider =
    AutoDisposeNotifierProvider<ArticleList, List<Article>>.internal(
  ArticleList.new,
  name: r'articleListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$articleListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ArticleList = AutoDisposeNotifier<List<Article>>;
String _$articleSearchQueryHash() =>
    r'67014fd809dcff4b6f3972cc40d257db7a2786e0';

/// See also [ArticleSearchQuery].
@ProviderFor(ArticleSearchQuery)
final articleSearchQueryProvider =
    AutoDisposeNotifierProvider<ArticleSearchQuery, String>.internal(
  ArticleSearchQuery.new,
  name: r'articleSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$articleSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ArticleSearchQuery = AutoDisposeNotifier<String>;
String _$articleActiveFilterHash() =>
    r'7a5a8cfffd411a0f829d8e48e8b84d681da34fa1';

/// See also [ArticleActiveFilter].
@ProviderFor(ArticleActiveFilter)
final articleActiveFilterProvider =
    AutoDisposeNotifierProvider<ArticleActiveFilter, bool?>.internal(
  ArticleActiveFilter.new,
  name: r'articleActiveFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$articleActiveFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ArticleActiveFilter = AutoDisposeNotifier<bool?>;
String _$articleClientFilterHash() =>
    r'5e7514e0a247e3b0aae31899109be4a9d031b4d2';

/// See also [ArticleClientFilter].
@ProviderFor(ArticleClientFilter)
final articleClientFilterProvider =
    AutoDisposeNotifierProvider<ArticleClientFilter, String?>.internal(
  ArticleClientFilter.new,
  name: r'articleClientFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$articleClientFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ArticleClientFilter = AutoDisposeNotifier<String?>;
String _$selectedArticleHash() => r'0982cfc9ab11de72631b21297506975eeb86ed70';

/// See also [SelectedArticle].
@ProviderFor(SelectedArticle)
final selectedArticleProvider =
    AutoDisposeNotifierProvider<SelectedArticle, Article?>.internal(
  SelectedArticle.new,
  name: r'selectedArticleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedArticleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedArticle = AutoDisposeNotifier<Article?>;
String _$articleFormStateHash() => r'9de2fb1333b60b45afb4877c39e76ed7b67ddba7';

/// See also [ArticleFormState].
@ProviderFor(ArticleFormState)
final articleFormStateProvider = AutoDisposeNotifierProvider<ArticleFormState,
    Map<String, dynamic>>.internal(
  ArticleFormState.new,
  name: r'articleFormStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$articleFormStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ArticleFormState = AutoDisposeNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

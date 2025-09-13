// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bon_reception_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bonReceptionRepositoryHash() =>
    r'5bb65f4117bfc37f7f9782e3bc03d535cb3fed45';

/// See also [bonReceptionRepository].
@ProviderFor(bonReceptionRepository)
final bonReceptionRepositoryProvider =
    AutoDisposeProvider<BonReceptionRepository>.internal(
  bonReceptionRepository,
  name: r'bonReceptionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonReceptionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BonReceptionRepositoryRef
    = AutoDisposeProviderRef<BonReceptionRepository>;
String _$receptionsByClientHash() =>
    r'34d6fa8dddcee28db8f434dfd39ea0fb47d65f4e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [receptionsByClient].
@ProviderFor(receptionsByClient)
const receptionsByClientProvider = ReceptionsByClientFamily();

/// See also [receptionsByClient].
class ReceptionsByClientFamily extends Family<List<BonReception>> {
  /// See also [receptionsByClient].
  const ReceptionsByClientFamily();

  /// See also [receptionsByClient].
  ReceptionsByClientProvider call(
    String clientId,
  ) {
    return ReceptionsByClientProvider(
      clientId,
    );
  }

  @override
  ReceptionsByClientProvider getProviderOverride(
    covariant ReceptionsByClientProvider provider,
  ) {
    return call(
      provider.clientId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'receptionsByClientProvider';
}

/// See also [receptionsByClient].
class ReceptionsByClientProvider
    extends AutoDisposeProvider<List<BonReception>> {
  /// See also [receptionsByClient].
  ReceptionsByClientProvider(
    String clientId,
  ) : this._internal(
          (ref) => receptionsByClient(
            ref as ReceptionsByClientRef,
            clientId,
          ),
          from: receptionsByClientProvider,
          name: r'receptionsByClientProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$receptionsByClientHash,
          dependencies: ReceptionsByClientFamily._dependencies,
          allTransitiveDependencies:
              ReceptionsByClientFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  ReceptionsByClientProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clientId,
  }) : super.internal();

  final String clientId;

  @override
  Override overrideWith(
    List<BonReception> Function(ReceptionsByClientRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReceptionsByClientProvider._internal(
        (ref) => create(ref as ReceptionsByClientRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clientId: clientId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<BonReception>> createElement() {
    return _ReceptionsByClientProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceptionsByClientProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReceptionsByClientRef on AutoDisposeProviderRef<List<BonReception>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _ReceptionsByClientProviderElement
    extends AutoDisposeProviderElement<List<BonReception>>
    with ReceptionsByClientRef {
  _ReceptionsByClientProviderElement(super.provider);

  @override
  String get clientId => (origin as ReceptionsByClientProvider).clientId;
}

String _$recentReceptionsHash() => r'5ed83f07061f35daeab29e3b3dd113b5530aa467';

/// See also [recentReceptions].
@ProviderFor(recentReceptions)
const recentReceptionsProvider = RecentReceptionsFamily();

/// See also [recentReceptions].
class RecentReceptionsFamily extends Family<List<BonReception>> {
  /// See also [recentReceptions].
  const RecentReceptionsFamily();

  /// See also [recentReceptions].
  RecentReceptionsProvider call({
    int days = 30,
  }) {
    return RecentReceptionsProvider(
      days: days,
    );
  }

  @override
  RecentReceptionsProvider getProviderOverride(
    covariant RecentReceptionsProvider provider,
  ) {
    return call(
      days: provider.days,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentReceptionsProvider';
}

/// See also [recentReceptions].
class RecentReceptionsProvider extends AutoDisposeProvider<List<BonReception>> {
  /// See also [recentReceptions].
  RecentReceptionsProvider({
    int days = 30,
  }) : this._internal(
          (ref) => recentReceptions(
            ref as RecentReceptionsRef,
            days: days,
          ),
          from: recentReceptionsProvider,
          name: r'recentReceptionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recentReceptionsHash,
          dependencies: RecentReceptionsFamily._dependencies,
          allTransitiveDependencies:
              RecentReceptionsFamily._allTransitiveDependencies,
          days: days,
        );

  RecentReceptionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.days,
  }) : super.internal();

  final int days;

  @override
  Override overrideWith(
    List<BonReception> Function(RecentReceptionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentReceptionsProvider._internal(
        (ref) => create(ref as RecentReceptionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        days: days,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<BonReception>> createElement() {
    return _RecentReceptionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentReceptionsProvider && other.days == days;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, days.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RecentReceptionsRef on AutoDisposeProviderRef<List<BonReception>> {
  /// The parameter `days` of this provider.
  int get days;
}

class _RecentReceptionsProviderElement
    extends AutoDisposeProviderElement<List<BonReception>>
    with RecentReceptionsRef {
  _RecentReceptionsProviderElement(super.provider);

  @override
  int get days => (origin as RecentReceptionsProvider).days;
}

String _$receptionStatisticsHash() =>
    r'0db1aeec04699c6c2e5aa27a4c51b0c4b89bedeb';

/// See also [receptionStatistics].
@ProviderFor(receptionStatistics)
final receptionStatisticsProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
  receptionStatistics,
  name: r'receptionStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$receptionStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ReceptionStatisticsRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$receptionByIdHash() => r'40e00f384b1095c73df9b5401010a739ef8f18be';

/// See also [receptionById].
@ProviderFor(receptionById)
const receptionByIdProvider = ReceptionByIdFamily();

/// See also [receptionById].
class ReceptionByIdFamily extends Family<BonReception?> {
  /// See also [receptionById].
  const ReceptionByIdFamily();

  /// See also [receptionById].
  ReceptionByIdProvider call(
    String id,
  ) {
    return ReceptionByIdProvider(
      id,
    );
  }

  @override
  ReceptionByIdProvider getProviderOverride(
    covariant ReceptionByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'receptionByIdProvider';
}

/// See also [receptionById].
class ReceptionByIdProvider extends AutoDisposeProvider<BonReception?> {
  /// See also [receptionById].
  ReceptionByIdProvider(
    String id,
  ) : this._internal(
          (ref) => receptionById(
            ref as ReceptionByIdRef,
            id,
          ),
          from: receptionByIdProvider,
          name: r'receptionByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$receptionByIdHash,
          dependencies: ReceptionByIdFamily._dependencies,
          allTransitiveDependencies:
              ReceptionByIdFamily._allTransitiveDependencies,
          id: id,
        );

  ReceptionByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    BonReception? Function(ReceptionByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReceptionByIdProvider._internal(
        (ref) => create(ref as ReceptionByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<BonReception?> createElement() {
    return _ReceptionByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceptionByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReceptionByIdRef on AutoDisposeProviderRef<BonReception?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ReceptionByIdProviderElement
    extends AutoDisposeProviderElement<BonReception?> with ReceptionByIdRef {
  _ReceptionByIdProviderElement(super.provider);

  @override
  String get id => (origin as ReceptionByIdProvider).id;
}

String _$bonReceptionSearchQueryHash() =>
    r'b24aae8e3a362587365d6b6a302fdeab3b043d51';

/// See also [BonReceptionSearchQuery].
@ProviderFor(BonReceptionSearchQuery)
final bonReceptionSearchQueryProvider =
    AutoDisposeNotifierProvider<BonReceptionSearchQuery, String>.internal(
  BonReceptionSearchQuery.new,
  name: r'bonReceptionSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonReceptionSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonReceptionSearchQuery = AutoDisposeNotifier<String>;
String _$bonReceptionClientFilterHash() =>
    r'638c14e5f7a6b17e3437020109f5761bdbe26ab8';

/// See also [BonReceptionClientFilter].
@ProviderFor(BonReceptionClientFilter)
final bonReceptionClientFilterProvider =
    AutoDisposeNotifierProvider<BonReceptionClientFilter, String?>.internal(
  BonReceptionClientFilter.new,
  name: r'bonReceptionClientFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonReceptionClientFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonReceptionClientFilter = AutoDisposeNotifier<String?>;
String _$bonReceptionStatusFilterHash() =>
    r'b140548578557f1e88b64e5fc0de6872e51e6194';

/// See also [BonReceptionStatusFilter].
@ProviderFor(BonReceptionStatusFilter)
final bonReceptionStatusFilterProvider =
    AutoDisposeNotifierProvider<BonReceptionStatusFilter, String?>.internal(
  BonReceptionStatusFilter.new,
  name: r'bonReceptionStatusFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonReceptionStatusFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonReceptionStatusFilter = AutoDisposeNotifier<String?>;
String _$bonReceptionDateFilterHash() =>
    r'111ae0f4341b0f524d334c549c5d971b1e828bdc';

/// See also [BonReceptionDateFilter].
@ProviderFor(BonReceptionDateFilter)
final bonReceptionDateFilterProvider =
    AutoDisposeNotifierProvider<BonReceptionDateFilter, DateRange?>.internal(
  BonReceptionDateFilter.new,
  name: r'bonReceptionDateFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonReceptionDateFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonReceptionDateFilter = AutoDisposeNotifier<DateRange?>;
String _$bonReceptionListHash() => r'0fceff7082e5d668e3290b66e726b134d0611b3d';

/// See also [BonReceptionList].
@ProviderFor(BonReceptionList)
final bonReceptionListProvider =
    AutoDisposeNotifierProvider<BonReceptionList, List<BonReception>>.internal(
  BonReceptionList.new,
  name: r'bonReceptionListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonReceptionListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonReceptionList = AutoDisposeNotifier<List<BonReception>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

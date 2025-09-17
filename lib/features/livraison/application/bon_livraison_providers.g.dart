// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bon_livraison_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bonLivraisonRepositoryHash() =>
    r'4e2772d09465c97b20403e270e6dd4190ba63276';

/// See also [bonLivraisonRepository].
@ProviderFor(bonLivraisonRepository)
final bonLivraisonRepositoryProvider =
    AutoDisposeProvider<BonLivraisonRepository>.internal(
  bonLivraisonRepository,
  name: r'bonLivraisonRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonLivraisonRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BonLivraisonRepositoryRef
    = AutoDisposeProviderRef<BonLivraisonRepository>;
String _$nextBlNumberHash() => r'a6dc3a63f477cc173da5e70aa783b615b701e869';

/// See also [nextBlNumber].
@ProviderFor(nextBlNumber)
final nextBlNumberProvider = AutoDisposeProvider<String>.internal(
  nextBlNumber,
  name: r'nextBlNumberProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$nextBlNumberHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NextBlNumberRef = AutoDisposeProviderRef<String>;
String _$bonLivraisonStatisticsHash() =>
    r'8af23d00ef0e2a234fcdcef02bc62c7a03ed40fb';

/// See also [bonLivraisonStatistics].
@ProviderFor(bonLivraisonStatistics)
final bonLivraisonStatisticsProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
  bonLivraisonStatistics,
  name: r'bonLivraisonStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonLivraisonStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BonLivraisonStatisticsRef
    = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$deliveriesByClientHash() =>
    r'70bb1e89266c4d82ee566bae875ee37de7fa9e2f';

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

/// See also [deliveriesByClient].
@ProviderFor(deliveriesByClient)
const deliveriesByClientProvider = DeliveriesByClientFamily();

/// See also [deliveriesByClient].
class DeliveriesByClientFamily extends Family<List<BonLivraison>> {
  /// See also [deliveriesByClient].
  const DeliveriesByClientFamily();

  /// See also [deliveriesByClient].
  DeliveriesByClientProvider call(
    String clientId,
  ) {
    return DeliveriesByClientProvider(
      clientId,
    );
  }

  @override
  DeliveriesByClientProvider getProviderOverride(
    covariant DeliveriesByClientProvider provider,
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
  String? get name => r'deliveriesByClientProvider';
}

/// See also [deliveriesByClient].
class DeliveriesByClientProvider
    extends AutoDisposeProvider<List<BonLivraison>> {
  /// See also [deliveriesByClient].
  DeliveriesByClientProvider(
    String clientId,
  ) : this._internal(
          (ref) => deliveriesByClient(
            ref as DeliveriesByClientRef,
            clientId,
          ),
          from: deliveriesByClientProvider,
          name: r'deliveriesByClientProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deliveriesByClientHash,
          dependencies: DeliveriesByClientFamily._dependencies,
          allTransitiveDependencies:
              DeliveriesByClientFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  DeliveriesByClientProvider._internal(
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
    List<BonLivraison> Function(DeliveriesByClientRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeliveriesByClientProvider._internal(
        (ref) => create(ref as DeliveriesByClientRef),
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
  AutoDisposeProviderElement<List<BonLivraison>> createElement() {
    return _DeliveriesByClientProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveriesByClientProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeliveriesByClientRef on AutoDisposeProviderRef<List<BonLivraison>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _DeliveriesByClientProviderElement
    extends AutoDisposeProviderElement<List<BonLivraison>>
    with DeliveriesByClientRef {
  _DeliveriesByClientProviderElement(super.provider);

  @override
  String get clientId => (origin as DeliveriesByClientProvider).clientId;
}

String _$deliveriesByStatusHash() =>
    r'b54827e6bae0a582a7e5314dc917194428ce897e';

/// See also [deliveriesByStatus].
@ProviderFor(deliveriesByStatus)
const deliveriesByStatusProvider = DeliveriesByStatusFamily();

/// See also [deliveriesByStatus].
class DeliveriesByStatusFamily extends Family<List<BonLivraison>> {
  /// See also [deliveriesByStatus].
  const DeliveriesByStatusFamily();

  /// See also [deliveriesByStatus].
  DeliveriesByStatusProvider call(
    String status,
  ) {
    return DeliveriesByStatusProvider(
      status,
    );
  }

  @override
  DeliveriesByStatusProvider getProviderOverride(
    covariant DeliveriesByStatusProvider provider,
  ) {
    return call(
      provider.status,
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
  String? get name => r'deliveriesByStatusProvider';
}

/// See also [deliveriesByStatus].
class DeliveriesByStatusProvider
    extends AutoDisposeProvider<List<BonLivraison>> {
  /// See also [deliveriesByStatus].
  DeliveriesByStatusProvider(
    String status,
  ) : this._internal(
          (ref) => deliveriesByStatus(
            ref as DeliveriesByStatusRef,
            status,
          ),
          from: deliveriesByStatusProvider,
          name: r'deliveriesByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deliveriesByStatusHash,
          dependencies: DeliveriesByStatusFamily._dependencies,
          allTransitiveDependencies:
              DeliveriesByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  DeliveriesByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String status;

  @override
  Override overrideWith(
    List<BonLivraison> Function(DeliveriesByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeliveriesByStatusProvider._internal(
        (ref) => create(ref as DeliveriesByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<BonLivraison>> createElement() {
    return _DeliveriesByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveriesByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeliveriesByStatusRef on AutoDisposeProviderRef<List<BonLivraison>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _DeliveriesByStatusProviderElement
    extends AutoDisposeProviderElement<List<BonLivraison>>
    with DeliveriesByStatusRef {
  _DeliveriesByStatusProviderElement(super.provider);

  @override
  String get status => (origin as DeliveriesByStatusProvider).status;
}

String _$pendingDeliveriesHash() => r'e475f98df966f9f160ad45aad697d119063644ba';

/// See also [pendingDeliveries].
@ProviderFor(pendingDeliveries)
final pendingDeliveriesProvider =
    AutoDisposeProvider<List<BonLivraison>>.internal(
  pendingDeliveries,
  name: r'pendingDeliveriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingDeliveriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingDeliveriesRef = AutoDisposeProviderRef<List<BonLivraison>>;
String _$deliveredDeliveriesHash() =>
    r'5a1c9c75ecd5cde406fb6ed7fcdcb547342581a6';

/// See also [deliveredDeliveries].
@ProviderFor(deliveredDeliveries)
final deliveredDeliveriesProvider =
    AutoDisposeProvider<List<BonLivraison>>.internal(
  deliveredDeliveries,
  name: r'deliveredDeliveriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deliveredDeliveriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeliveredDeliveriesRef = AutoDisposeProviderRef<List<BonLivraison>>;
String _$bonLivraisonListHash() => r'1d21b7ea967ba34227d11914b588c51ed19ad941';

/// See also [BonLivraisonList].
@ProviderFor(BonLivraisonList)
final bonLivraisonListProvider =
    AutoDisposeNotifierProvider<BonLivraisonList, List<BonLivraison>>.internal(
  BonLivraisonList.new,
  name: r'bonLivraisonListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonLivraisonListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonLivraisonList = AutoDisposeNotifier<List<BonLivraison>>;
String _$bonLivraisonSearchQueryHash() =>
    r'e143a75b3d54bd071c9f5a6d93e78749411fc53a';

/// See also [BonLivraisonSearchQuery].
@ProviderFor(BonLivraisonSearchQuery)
final bonLivraisonSearchQueryProvider =
    AutoDisposeNotifierProvider<BonLivraisonSearchQuery, String>.internal(
  BonLivraisonSearchQuery.new,
  name: r'bonLivraisonSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonLivraisonSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonLivraisonSearchQuery = AutoDisposeNotifier<String>;
String _$bonLivraisonClientFilterHash() =>
    r'9a1300a0f019a4e9c7c04a49c04f2d0ee8320280';

/// See also [BonLivraisonClientFilter].
@ProviderFor(BonLivraisonClientFilter)
final bonLivraisonClientFilterProvider =
    AutoDisposeNotifierProvider<BonLivraisonClientFilter, String?>.internal(
  BonLivraisonClientFilter.new,
  name: r'bonLivraisonClientFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonLivraisonClientFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonLivraisonClientFilter = AutoDisposeNotifier<String?>;
String _$bonLivraisonStatusFilterHash() =>
    r'049167d2f65388d0e9bb78f8850bc22a407753b9';

/// See also [BonLivraisonStatusFilter].
@ProviderFor(BonLivraisonStatusFilter)
final bonLivraisonStatusFilterProvider =
    AutoDisposeNotifierProvider<BonLivraisonStatusFilter, String?>.internal(
  BonLivraisonStatusFilter.new,
  name: r'bonLivraisonStatusFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonLivraisonStatusFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonLivraisonStatusFilter = AutoDisposeNotifier<String?>;
String _$selectedBonLivraisonHash() =>
    r'5a4efc59a598677fd1c7eba10cb273162980d645';

/// See also [SelectedBonLivraison].
@ProviderFor(SelectedBonLivraison)
final selectedBonLivraisonProvider =
    AutoDisposeNotifierProvider<SelectedBonLivraison, BonLivraison?>.internal(
  SelectedBonLivraison.new,
  name: r'selectedBonLivraisonProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedBonLivraisonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedBonLivraison = AutoDisposeNotifier<BonLivraison?>;
String _$availableStockForClientHash() =>
    r'bf1d88d2821f279e869615419041f0ae2e99dddf';

abstract class _$AvailableStockForClient
    extends BuildlessAutoDisposeNotifier<Map<String, Map<String, int>>> {
  late final String clientId;

  Map<String, Map<String, int>> build(
    String clientId,
  );
}

/// See also [AvailableStockForClient].
@ProviderFor(AvailableStockForClient)
const availableStockForClientProvider = AvailableStockForClientFamily();

/// See also [AvailableStockForClient].
class AvailableStockForClientFamily
    extends Family<Map<String, Map<String, int>>> {
  /// See also [AvailableStockForClient].
  const AvailableStockForClientFamily();

  /// See also [AvailableStockForClient].
  AvailableStockForClientProvider call(
    String clientId,
  ) {
    return AvailableStockForClientProvider(
      clientId,
    );
  }

  @override
  AvailableStockForClientProvider getProviderOverride(
    covariant AvailableStockForClientProvider provider,
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
  String? get name => r'availableStockForClientProvider';
}

/// See also [AvailableStockForClient].
class AvailableStockForClientProvider extends AutoDisposeNotifierProviderImpl<
    AvailableStockForClient, Map<String, Map<String, int>>> {
  /// See also [AvailableStockForClient].
  AvailableStockForClientProvider(
    String clientId,
  ) : this._internal(
          () => AvailableStockForClient()..clientId = clientId,
          from: availableStockForClientProvider,
          name: r'availableStockForClientProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableStockForClientHash,
          dependencies: AvailableStockForClientFamily._dependencies,
          allTransitiveDependencies:
              AvailableStockForClientFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  AvailableStockForClientProvider._internal(
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
  Map<String, Map<String, int>> runNotifierBuild(
    covariant AvailableStockForClient notifier,
  ) {
    return notifier.build(
      clientId,
    );
  }

  @override
  Override overrideWith(AvailableStockForClient Function() create) {
    return ProviderOverride(
      origin: this,
      override: AvailableStockForClientProvider._internal(
        () => create()..clientId = clientId,
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
  AutoDisposeNotifierProviderElement<AvailableStockForClient,
      Map<String, Map<String, int>>> createElement() {
    return _AvailableStockForClientProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableStockForClientProvider &&
        other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AvailableStockForClientRef
    on AutoDisposeNotifierProviderRef<Map<String, Map<String, int>>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _AvailableStockForClientProviderElement
    extends AutoDisposeNotifierProviderElement<AvailableStockForClient,
        Map<String, Map<String, int>>> with AvailableStockForClientRef {
  _AvailableStockForClientProviderElement(super.provider);

  @override
  String get clientId => (origin as AvailableStockForClientProvider).clientId;
}

String _$bonLivraisonFormStateHash() =>
    r'f81f7d3540f7c349ccff8f7f635d6f13c69aac27';

/// See also [BonLivraisonFormState].
@ProviderFor(BonLivraisonFormState)
final bonLivraisonFormStateProvider = AutoDisposeNotifierProvider<
    BonLivraisonFormState, Map<String, dynamic>>.internal(
  BonLivraisonFormState.new,
  name: r'bonLivraisonFormStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonLivraisonFormStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BonLivraisonFormState = AutoDisposeNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

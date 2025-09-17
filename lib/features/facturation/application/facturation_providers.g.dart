// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facturation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$facturationRepositoryHash() =>
    r'ec577c9dcba30881ca882494288c501121211704';

/// See also [facturationRepository].
@ProviderFor(facturationRepository)
final facturationRepositoryProvider = Provider<FacturationRepository>.internal(
  facturationRepository,
  name: r'facturationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$facturationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FacturationRepositoryRef = ProviderRef<FacturationRepository>;
String _$allInvoicesHash() => r'3cce59c4fc45231ed5451baee6e85e0590937722';

/// See also [allInvoices].
@ProviderFor(allInvoices)
final allInvoicesProvider = AutoDisposeProvider<List<Facturation>>.internal(
  allInvoices,
  name: r'allInvoicesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allInvoicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllInvoicesRef = AutoDisposeProviderRef<List<Facturation>>;
String _$invoicesByClientHash() => r'0ad88933453feab720f707e5bbb98b5555a448f8';

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

/// See also [invoicesByClient].
@ProviderFor(invoicesByClient)
const invoicesByClientProvider = InvoicesByClientFamily();

/// See also [invoicesByClient].
class InvoicesByClientFamily extends Family<List<Facturation>> {
  /// See also [invoicesByClient].
  const InvoicesByClientFamily();

  /// See also [invoicesByClient].
  InvoicesByClientProvider call(
    String clientId,
  ) {
    return InvoicesByClientProvider(
      clientId,
    );
  }

  @override
  InvoicesByClientProvider getProviderOverride(
    covariant InvoicesByClientProvider provider,
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
  String? get name => r'invoicesByClientProvider';
}

/// See also [invoicesByClient].
class InvoicesByClientProvider extends AutoDisposeProvider<List<Facturation>> {
  /// See also [invoicesByClient].
  InvoicesByClientProvider(
    String clientId,
  ) : this._internal(
          (ref) => invoicesByClient(
            ref as InvoicesByClientRef,
            clientId,
          ),
          from: invoicesByClientProvider,
          name: r'invoicesByClientProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$invoicesByClientHash,
          dependencies: InvoicesByClientFamily._dependencies,
          allTransitiveDependencies:
              InvoicesByClientFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  InvoicesByClientProvider._internal(
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
    List<Facturation> Function(InvoicesByClientRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvoicesByClientProvider._internal(
        (ref) => create(ref as InvoicesByClientRef),
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
  AutoDisposeProviderElement<List<Facturation>> createElement() {
    return _InvoicesByClientProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoicesByClientProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InvoicesByClientRef on AutoDisposeProviderRef<List<Facturation>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _InvoicesByClientProviderElement
    extends AutoDisposeProviderElement<List<Facturation>>
    with InvoicesByClientRef {
  _InvoicesByClientProviderElement(super.provider);

  @override
  String get clientId => (origin as InvoicesByClientProvider).clientId;
}

String _$invoicesByStatusHash() => r'7ad88ad49ab1b18638a4a09f9c0119db59524676';

/// See also [invoicesByStatus].
@ProviderFor(invoicesByStatus)
const invoicesByStatusProvider = InvoicesByStatusFamily();

/// See also [invoicesByStatus].
class InvoicesByStatusFamily extends Family<List<Facturation>> {
  /// See also [invoicesByStatus].
  const InvoicesByStatusFamily();

  /// See also [invoicesByStatus].
  InvoicesByStatusProvider call(
    String status,
  ) {
    return InvoicesByStatusProvider(
      status,
    );
  }

  @override
  InvoicesByStatusProvider getProviderOverride(
    covariant InvoicesByStatusProvider provider,
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
  String? get name => r'invoicesByStatusProvider';
}

/// See also [invoicesByStatus].
class InvoicesByStatusProvider extends AutoDisposeProvider<List<Facturation>> {
  /// See also [invoicesByStatus].
  InvoicesByStatusProvider(
    String status,
  ) : this._internal(
          (ref) => invoicesByStatus(
            ref as InvoicesByStatusRef,
            status,
          ),
          from: invoicesByStatusProvider,
          name: r'invoicesByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$invoicesByStatusHash,
          dependencies: InvoicesByStatusFamily._dependencies,
          allTransitiveDependencies:
              InvoicesByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  InvoicesByStatusProvider._internal(
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
    List<Facturation> Function(InvoicesByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvoicesByStatusProvider._internal(
        (ref) => create(ref as InvoicesByStatusRef),
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
  AutoDisposeProviderElement<List<Facturation>> createElement() {
    return _InvoicesByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoicesByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InvoicesByStatusRef on AutoDisposeProviderRef<List<Facturation>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _InvoicesByStatusProviderElement
    extends AutoDisposeProviderElement<List<Facturation>>
    with InvoicesByStatusRef {
  _InvoicesByStatusProviderElement(super.provider);

  @override
  String get status => (origin as InvoicesByStatusProvider).status;
}

String _$pendingInvoicesHash() => r'2795b35d27b4309746b49a3640363e97c67f6c11';

/// See also [pendingInvoices].
@ProviderFor(pendingInvoices)
final pendingInvoicesProvider = AutoDisposeProvider<List<Facturation>>.internal(
  pendingInvoices,
  name: r'pendingInvoicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingInvoicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingInvoicesRef = AutoDisposeProviderRef<List<Facturation>>;
String _$paidInvoicesHash() => r'496e18055afc0999dd824f2ca88b51a0dd2d5d7e';

/// See also [paidInvoices].
@ProviderFor(paidInvoices)
final paidInvoicesProvider = AutoDisposeProvider<List<Facturation>>.internal(
  paidInvoices,
  name: r'paidInvoicesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$paidInvoicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PaidInvoicesRef = AutoDisposeProviderRef<List<Facturation>>;
String _$pendingBLsForInvoicingHash() =>
    r'd6d47bd680945c512696ec2a3c3ace3de625cc44';

/// See also [pendingBLsForInvoicing].
@ProviderFor(pendingBLsForInvoicing)
final pendingBLsForInvoicingProvider =
    AutoDisposeProvider<List<BonLivraison>>.internal(
  pendingBLsForInvoicing,
  name: r'pendingBLsForInvoicingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingBLsForInvoicingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingBLsForInvoicingRef = AutoDisposeProviderRef<List<BonLivraison>>;
String _$pendingBLsForClientHash() =>
    r'fd409e9a49aef78f5523ac406f7d88fdd4729843';

/// See also [pendingBLsForClient].
@ProviderFor(pendingBLsForClient)
const pendingBLsForClientProvider = PendingBLsForClientFamily();

/// See also [pendingBLsForClient].
class PendingBLsForClientFamily extends Family<List<BonLivraison>> {
  /// See also [pendingBLsForClient].
  const PendingBLsForClientFamily();

  /// See also [pendingBLsForClient].
  PendingBLsForClientProvider call(
    String clientId,
  ) {
    return PendingBLsForClientProvider(
      clientId,
    );
  }

  @override
  PendingBLsForClientProvider getProviderOverride(
    covariant PendingBLsForClientProvider provider,
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
  String? get name => r'pendingBLsForClientProvider';
}

/// See also [pendingBLsForClient].
class PendingBLsForClientProvider
    extends AutoDisposeProvider<List<BonLivraison>> {
  /// See also [pendingBLsForClient].
  PendingBLsForClientProvider(
    String clientId,
  ) : this._internal(
          (ref) => pendingBLsForClient(
            ref as PendingBLsForClientRef,
            clientId,
          ),
          from: pendingBLsForClientProvider,
          name: r'pendingBLsForClientProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pendingBLsForClientHash,
          dependencies: PendingBLsForClientFamily._dependencies,
          allTransitiveDependencies:
              PendingBLsForClientFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  PendingBLsForClientProvider._internal(
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
    List<BonLivraison> Function(PendingBLsForClientRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PendingBLsForClientProvider._internal(
        (ref) => create(ref as PendingBLsForClientRef),
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
    return _PendingBLsForClientProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingBLsForClientProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PendingBLsForClientRef on AutoDisposeProviderRef<List<BonLivraison>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _PendingBLsForClientProviderElement
    extends AutoDisposeProviderElement<List<BonLivraison>>
    with PendingBLsForClientRef {
  _PendingBLsForClientProviderElement(super.provider);

  @override
  String get clientId => (origin as PendingBLsForClientProvider).clientId;
}

String _$facturationStatisticsHash() =>
    r'11b94fc325739f4b42cc1c05eea1b063fcb65a16';

/// See also [facturationStatistics].
@ProviderFor(facturationStatistics)
final facturationStatisticsProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
  facturationStatistics,
  name: r'facturationStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$facturationStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FacturationStatisticsRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$filteredInvoicesHash() => r'e30ddf98f963a750068a419db54fa2cf11592f00';

/// See also [filteredInvoices].
@ProviderFor(filteredInvoices)
final filteredInvoicesProvider =
    AutoDisposeProvider<List<Facturation>>.internal(
  filteredInvoices,
  name: r'filteredInvoicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredInvoicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredInvoicesRef = AutoDisposeProviderRef<List<Facturation>>;
String _$selectedFacturationClientHash() =>
    r'c6bcf881e7ce63c39863121e667ccadd45beec82';

/// See also [SelectedFacturationClient].
@ProviderFor(SelectedFacturationClient)
final selectedFacturationClientProvider =
    AutoDisposeNotifierProvider<SelectedFacturationClient, String?>.internal(
  SelectedFacturationClient.new,
  name: r'selectedFacturationClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedFacturationClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedFacturationClient = AutoDisposeNotifier<String?>;
String _$selectedFacturationStatusHash() =>
    r'8a435c880ec73d7d4f1afd8499cb2753bfe84a91';

/// See also [SelectedFacturationStatus].
@ProviderFor(SelectedFacturationStatus)
final selectedFacturationStatusProvider =
    AutoDisposeNotifierProvider<SelectedFacturationStatus, String?>.internal(
  SelectedFacturationStatus.new,
  name: r'selectedFacturationStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedFacturationStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedFacturationStatus = AutoDisposeNotifier<String?>;
String _$facturationSearchQueryHash() =>
    r'022e671ed292a280b22ba8fb5f66b9ce00ea63a0';

/// See also [FacturationSearchQuery].
@ProviderFor(FacturationSearchQuery)
final facturationSearchQueryProvider =
    AutoDisposeNotifierProvider<FacturationSearchQuery, String>.internal(
  FacturationSearchQuery.new,
  name: r'facturationSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$facturationSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FacturationSearchQuery = AutoDisposeNotifier<String>;
String _$facturationFormStateHash() =>
    r'ad2d95cf8f8edada640239f718508297a24a70bf';

/// See also [FacturationFormState].
@ProviderFor(FacturationFormState)
final facturationFormStateProvider = AutoDisposeNotifierProvider<
    FacturationFormState, FacturationFormData>.internal(
  FacturationFormState.new,
  name: r'facturationFormStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$facturationFormStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FacturationFormState = AutoDisposeNotifier<FacturationFormData>;
String _$facturationCrudHash() => r'928e00aeec85d491c4c9a3bea9e3dce593bebb8d';

/// See also [FacturationCrud].
@ProviderFor(FacturationCrud)
final facturationCrudProvider =
    AutoDisposeNotifierProvider<FacturationCrud, AsyncValue<void>>.internal(
  FacturationCrud.new,
  name: r'facturationCrudProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$facturationCrudHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FacturationCrud = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

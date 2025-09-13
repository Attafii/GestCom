// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientRepositoryHash() => r'1df43ba9994bb78a2be0fa0d111cb4ca870cfb94';

/// See also [clientRepository].
@ProviderFor(clientRepository)
final clientRepositoryProvider = AutoDisposeProvider<ClientRepository>.internal(
  clientRepository,
  name: r'clientRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ClientRepositoryRef = AutoDisposeProviderRef<ClientRepository>;
String _$activeClientsHash() => r'3ffbb46be990ac88fe7ace482fed55a70e0db32c';

/// See also [activeClients].
@ProviderFor(activeClients)
final activeClientsProvider = AutoDisposeProvider<List<Client>>.internal(
  activeClients,
  name: r'activeClientsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeClientsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveClientsRef = AutoDisposeProviderRef<List<Client>>;
String _$clientListHash() => r'5c70f5f1b64c395d8fc57346c1c4d509caee28c3';

/// See also [ClientList].
@ProviderFor(ClientList)
final clientListProvider =
    AutoDisposeNotifierProvider<ClientList, List<Client>>.internal(
  ClientList.new,
  name: r'clientListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$clientListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClientList = AutoDisposeNotifier<List<Client>>;
String _$clientSearchQueryHash() => r'1402788c59e3d893cbde5f959818d8ade4aa3f7f';

/// See also [ClientSearchQuery].
@ProviderFor(ClientSearchQuery)
final clientSearchQueryProvider =
    AutoDisposeNotifierProvider<ClientSearchQuery, String>.internal(
  ClientSearchQuery.new,
  name: r'clientSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClientSearchQuery = AutoDisposeNotifier<String>;
String _$selectedClientHash() => r'4f59343e7a865195f19da2b52b57da679881db6c';

/// See also [SelectedClient].
@ProviderFor(SelectedClient)
final selectedClientProvider =
    AutoDisposeNotifierProvider<SelectedClient, Client?>.internal(
  SelectedClient.new,
  name: r'selectedClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedClient = AutoDisposeNotifier<Client?>;
String _$clientFormStateHash() => r'0aea19df1133189d93b2b8513071f9da1403f108';

/// See also [ClientFormState].
@ProviderFor(ClientFormState)
final clientFormStateProvider =
    AutoDisposeNotifierProvider<ClientFormState, Map<String, String>>.internal(
  ClientFormState.new,
  name: r'clientFormStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientFormStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClientFormState = AutoDisposeNotifier<Map<String, String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

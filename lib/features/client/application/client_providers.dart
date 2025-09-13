import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/client_model.dart';
import '../../../data/repositories/client_repository.dart';

part 'client_providers.g.dart';

// Repository provider
@riverpod
ClientRepository clientRepository(ClientRepositoryRef ref) {
  return ClientRepository();
}

// Client list provider
@riverpod
class ClientList extends _$ClientList {
  @override
  List<Client> build() {
    final repository = ref.read(clientRepositoryProvider);
    return repository.getAllClients();
  }

  // Add client
  Future<void> addClient(Client client) async {
    final repository = ref.read(clientRepositoryProvider);
    try {
      await repository.addClient(client);
      state = repository.getAllClients();
    } catch (e) {
      rethrow;
    }
  }

  // Update client
  Future<void> updateClient(Client client) async {
    final repository = ref.read(clientRepositoryProvider);
    try {
      await repository.updateClient(client);
      state = repository.getAllClients();
    } catch (e) {
      rethrow;
    }
  }

  // Delete client
  Future<void> deleteClient(String id) async {
    final repository = ref.read(clientRepositoryProvider);
    try {
      await repository.deleteClient(id);
      state = repository.getAllClients();
    } catch (e) {
      rethrow;
    }
  }

  // Search clients
  void searchClients(String query) {
    final repository = ref.read(clientRepositoryProvider);
    state = repository.searchClients(query);
  }

  // Refresh clients list
  void refresh() {
    final repository = ref.read(clientRepositoryProvider);
    state = repository.getAllClients();
  }
}

// Search query provider
@riverpod
class ClientSearchQuery extends _$ClientSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
    // Trigger search in client list
    ref.read(clientListProvider.notifier).searchClients(query);
  }

  void clear() {
    state = '';
    ref.read(clientListProvider.notifier).refresh();
  }
}

// Selected client provider (for editing)
@riverpod
class SelectedClient extends _$SelectedClient {
  @override
  Client? build() => null;

  void selectClient(Client? client) {
    state = client;
  }

  void clearSelection() {
    state = null;
  }
}

// Client form state provider
@riverpod
class ClientFormState extends _$ClientFormState {
  @override
  Map<String, String> build() {
    return {
      'name': '',
      'address': '',
      'matriculeFiscal': '',
      'phone': '',
      'email': '',
    };
  }

  void updateField(String field, String value) {
    state = {...state, field: value};
  }

  void loadClient(Client client) {
    state = {
      'name': client.name,
      'address': client.address,
      'matriculeFiscal': client.matriculeFiscal,
      'phone': client.phone,
      'email': client.email,
    };
  }

  void clear() {
    state = {
      'name': '',
      'address': '',
      'matriculeFiscal': '',
      'phone': '',
      'email': '',
    };
  }

  bool get isValid {
    return state['name']!.isNotEmpty &&
           state['address']!.isNotEmpty &&
           state['matriculeFiscal']!.isNotEmpty &&
           state['phone']!.isNotEmpty &&
           state['email']!.isNotEmpty &&
           _isValidEmail(state['email']!);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

// Active clients provider
@riverpod
List<Client> activeClients(ActiveClientsRef ref) {
  final allClients = ref.watch(clientListProvider);
  return allClients; // Return all clients since Client model doesn't have isActive field
}
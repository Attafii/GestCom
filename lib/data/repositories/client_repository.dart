import 'package:hive/hive.dart';
import '../models/client_model.dart';

class ClientRepository {
  static const String _boxName = 'clients';
  
  Box<Client> get _box => Hive.box<Client>(_boxName);

  // Get all clients
  List<Client> getAllClients() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get client by ID
  Client? getClientById(String id) {
    return _box.values.firstWhere(
      (client) => client.id == id,
      orElse: () => throw Exception('Client not found'),
    );
  }

  // Search clients by name or matricule fiscal
  List<Client> searchClients(String query) {
    if (query.isEmpty) return getAllClients();
    
    final lowercaseQuery = query.toLowerCase();
    return _box.values.where((client) {
      return client.name.toLowerCase().contains(lowercaseQuery) ||
             client.matriculeFiscal.toLowerCase().contains(lowercaseQuery) ||
             client.phone.contains(query) ||
             client.email.toLowerCase().contains(lowercaseQuery);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Add new client
  Future<void> addClient(Client client) async {
    // Check if matricule fiscal already exists
    Client? existingClient;
    try {
      existingClient = _box.values.firstWhere(
        (c) => c.matriculeFiscal == client.matriculeFiscal,
      );
    } catch (e) {
      existingClient = null;
    }
    
    if (existingClient != null) {
      throw Exception('Un client avec ce matricule fiscal existe déjà');
    }

    await _box.put(client.id, client);
  }

  // Update existing client
  Future<void> updateClient(Client client) async {
    if (!_box.containsKey(client.id)) {
      throw Exception('Client not found');
    }

    // Check if matricule fiscal already exists for another client
    Client? existingClient;
    try {
      existingClient = _box.values.firstWhere(
        (c) => c.matriculeFiscal == client.matriculeFiscal && c.id != client.id,
      );
    } catch (e) {
      existingClient = null;
    }
    
    if (existingClient != null) {
      throw Exception('Un client avec ce matricule fiscal existe déjà');
    }

    await _box.put(client.id, client);
  }

  // Delete client
  Future<void> deleteClient(String id) async {
    if (!_box.containsKey(id)) {
      throw Exception('Client not found');
    }

    await _box.delete(id);
  }

  // Get clients count
  int getClientsCount() {
    return _box.length;
  }

  // Check if matricule fiscal exists
  bool matriculeFiscalExists(String matriculeFiscal, {String? excludeId}) {
    return _box.values.any((client) => 
      client.matriculeFiscal == matriculeFiscal && 
      (excludeId == null || client.id != excludeId)
    );
  }

  // Export clients to JSON
  List<Map<String, dynamic>> exportToJson() {
    return _box.values.map((client) => client.toJson()).toList();
  }

  // Clear all clients (for testing or reset)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
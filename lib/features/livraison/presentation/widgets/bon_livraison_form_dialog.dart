import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gestcom/core/constants/app_colors.dart';
import 'package:gestcom/core/constants/app_strings.dart';
import 'package:gestcom/data/models/bon_livraison_model.dart';
import 'package:gestcom/data/models/article_livraison_model.dart';
import 'package:gestcom/data/models/client_model.dart';
import 'package:gestcom/data/models/article_model.dart';
import 'package:gestcom/data/models/treatment_model.dart';
import 'package:gestcom/features/client/application/client_providers.dart';
import 'package:gestcom/features/articles/application/article_providers.dart';
import 'package:gestcom/features/articles/application/treatment_providers.dart';
import '../../application/bon_livraison_providers.dart';

class BonLivraisonFormDialog extends ConsumerStatefulWidget {
  const BonLivraisonFormDialog({super.key, this.delivery});

  final BonLivraison? delivery;

  @override
  ConsumerState<BonLivraisonFormDialog> createState() => _BonLivraisonFormDialogState();
}

class _BonLivraisonFormDialogState extends ConsumerState<BonLivraisonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _signatureController = TextEditingController();
  
  Client? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _selectedArticles = [];
  bool _isLoading = false;
  
  bool get _isEditing => widget.delivery != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadDeliveryData();
    }
  }

  void _loadDeliveryData() {
    final delivery = widget.delivery!;
    
    // Find client
    final clients = ref.read(activeClientsProvider);
    _selectedClient = clients.firstWhere(
      (client) => client.id == delivery.clientId,
      orElse: () => clients.first,
    );
    
    _selectedDate = delivery.dateLivraison;
    _notesController.text = delivery.notes ?? '';
    _signatureController.text = delivery.signature ?? '';
    
    // Load articles
    _selectedArticles = delivery.articles.map((article) => {
      'articleReference': article.articleReference,
      'articleDesignation': article.articleDesignation,
      'treatmentId': article.treatmentId,
      'treatmentName': article.treatmentName,
      'quantity': article.quantityLivree,
      'price': article.prixUnitaire,
      'receptionId': article.receptionId,
      'commentaire': article.commentaire,
      'availableStock': 0, // Will be updated when client is selected
    }).toList();
    
    // Update available stock
    if (_selectedClient != null) {
      _updateAvailableStock();
    }
  }

  void _updateAvailableStock() {
    if (_selectedClient == null) return;
    
    final availableStock = ref.read(availableStockForClientProvider(_selectedClient!.id));
    
    for (var i = 0; i < _selectedArticles.length; i++) {
      final article = _selectedArticles[i];
      final available = availableStock[article['articleReference']]?[article['treatmentId']] ?? 0;
      
      setState(() {
        _selectedArticles[i]['availableStock'] = available;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(activeClientsProvider);
    final nextBlNumber = ref.watch(nextBlNumberProvider);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(nextBlNumber),
            const SizedBox(height: 24),

            // Form
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Client and date selection
                      _buildClientAndDateSection(clients),
                      const SizedBox(height: 24),

                      // Available stock section
                      if (_selectedClient != null) ...[
                        _buildAvailableStockSection(),
                        const SizedBox(height: 24),
                      ],

                      // Selected articles section
                      _buildSelectedArticlesSection(),
                      const SizedBox(height: 24),

                      // Additional fields
                      _buildAdditionalFields(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String nextBlNumber) {
    return Row(
      children: [
        Icon(
          _isEditing ? Icons.edit : Icons.add_box,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Modifier le bon de livraison' : 'Nouveau bon de livraison',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (!_isEditing)
              Text(
                'Numéro: $nextBlNumber',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildClientAndDateSection(List<Client> clients) {
    return Row(
      children: [
        // Client selection
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<Client>(
            value: _selectedClient,
            decoration: InputDecoration(
              labelText: 'Client *',
              prefixIcon: Icon(Icons.person, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            items: clients.map((client) {
              return DropdownMenuItem<Client>(
                value: client,
                child: Text(
                  client.name,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (client) {
              setState(() {
                _selectedClient = client;
                _selectedArticles.clear(); // Clear articles when client changes
              });
              if (client != null) {
                _updateAvailableStock();
              }
            },
            validator: (value) => value == null ? AppStrings.fieldRequired : null,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Date selection
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date de livraison *',
                prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableStockSection() {
    final availableStock = ref.watch(availableStockForClientProvider(_selectedClient!.id));
    
    if (availableStock.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Aucun stock disponible pour ce client.'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock disponible',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 2, child: Text('Article', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Traitement', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 50), // Space for add button
                  ],
                ),
              ),
              // Stock items
              ...availableStock.entries.expand((articleEntry) {
                final articleRef = articleEntry.key;
                final treatments = articleEntry.value;
                
                return treatments.entries.map((treatmentEntry) {
                  final treatmentId = treatmentEntry.key;
                  final quantity = treatmentEntry.value;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.divider)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            articleRef,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final treatments = ref.watch(activeTreatmentsProvider);
                              final treatment = treatments.firstWhere(
                                (t) => t.id == treatmentId,
                                orElse: () => Treatment(name: 'Inconnu', description: '', defaultPrice: 0),
                              );
                              return Text(
                                treatment.name,
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            quantity.toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: IconButton(
                            onPressed: () => _addArticleToDelivery(articleRef, treatmentId, quantity),
                            icon: Icon(Icons.add, color: AppColors.success, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedArticlesSection() {
    if (_selectedArticles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info, color: AppColors.info),
            SizedBox(width: 8),
            Expanded(
              child: Text('Sélectionnez des articles à livrer depuis le stock disponible ci-dessus.'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Articles à livrer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              'Total: ${_calculateTotalPieces()} pi\u00e8ces',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Article', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Traitement', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Quantité', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 50), // Space for remove button
                  ],
                ),
              ),
              // Article items
              ...List.generate(_selectedArticles.length, (index) {
                final article = _selectedArticles[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.divider)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          article['articleReference'],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          article['treatmentName'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: article['quantity'].toString(),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                          onChanged: (value) {
                            final quantity = int.tryParse(value) ?? 0;
                            setState(() {
                              _selectedArticles[index]['quantity'] = quantity;
                            });
                          },
                          validator: (value) {
                            final quantity = int.tryParse(value ?? '') ?? 0;
                            if (quantity <= 0) return 'Qté invalide';
                            if (quantity > article['availableStock']) {
                              return 'Max: ${article['availableStock']}';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 50,
                        child: IconButton(
                          onPressed: () => _removeArticleFromDelivery(index),
                          icon: Icon(Icons.remove_circle, color: AppColors.error, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalFields() {
    return Column(
      children: [
        // Notes field
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Notes',
            prefixIcon: Icon(Icons.note, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          maxLines: 3,
        ),
        
        const SizedBox(height: 16),
        
        // Signature field
        TextFormField(
          controller: _signatureController,
          decoration: InputDecoration(
            labelText: 'Signature / Nom du réceptionnaire',
            prefixIcon: Icon(Icons.draw, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveDelivery,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(_isEditing ? 'Modifier' : AppStrings.save),
        ),
      ],
    );
  }

  void _addArticleToDelivery(String articleRef, String treatmentId, int availableStock) {
    // Check if article already exists
    final existingIndex = _selectedArticles.indexWhere(
      (article) => article['articleReference'] == articleRef && article['treatmentId'] == treatmentId,
    );
    
    if (existingIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cet article avec ce traitement est déjà ajouté'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Get article and treatment details
    final articles = ref.read(activeArticlesProvider);
    final treatments = ref.read(activeTreatmentsProvider);
    
    final article = articles.firstWhere(
      (a) => a.reference == articleRef,
      orElse: () => Article(reference: articleRef, designation: 'Article inconnu', traitementPrix: {}),
    );
    
    final treatment = treatments.firstWhere(
      (t) => t.id == treatmentId,
      orElse: () => Treatment(name: 'Traitement inconnu', description: '', defaultPrice: 0),
    );

    // Get price from article
    final price = article.traitementPrix[treatmentId] ?? treatment.defaultPrice;

    setState(() {
      _selectedArticles.add({
        'articleReference': articleRef,
        'articleDesignation': article.designation,
        'treatmentId': treatmentId,
        'treatmentName': treatment.name,
        'quantity': 1,
        'price': price,
        'availableStock': availableStock,
      });
    });
  }

  void _removeArticleFromDelivery(int index) {
    setState(() {
      _selectedArticles.removeAt(index);
    });
  }

  int _calculateTotalPieces() {
    return _selectedArticles.fold(0, (sum, article) => 
        sum + (article['quantity'] as int));
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveDelivery() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un client'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_selectedArticles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un article'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final articles = _selectedArticles.map((articleData) {
        return ArticleLivraison(
          articleReference: articleData['articleReference'],
          articleDesignation: articleData['articleDesignation'],
          quantityLivree: articleData['quantity'],
          treatmentId: articleData['treatmentId'],
          treatmentName: articleData['treatmentName'],
          prixUnitaire: (articleData['price'] as num).toDouble(),
          receptionId: articleData['receptionId'] ?? '',
          commentaire: articleData['commentaire'],
        );
      }).toList();

      final delivery = _isEditing
          ? widget.delivery!.copyWith(
              clientId: _selectedClient!.id,
              clientName: _selectedClient!.name,
              dateLivraison: _selectedDate,
              articles: articles.cast<ArticleLivraison>(),
              signature: _signatureController.text.trim().isEmpty ? null : _signatureController.text.trim(),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            )
          : BonLivraison(
              blNumber: ref.read(nextBlNumberProvider),
              clientId: _selectedClient!.id,
              clientName: _selectedClient!.name,
              dateLivraison: _selectedDate,
              articles: articles.cast<ArticleLivraison>(),
              signature: _signatureController.text.trim().isEmpty ? null : _signatureController.text.trim(),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            );

      if (_isEditing) {
        await ref.read(bonLivraisonListProvider.notifier).updateDelivery(delivery);
      } else {
        await ref.read(bonLivraisonListProvider.notifier).addDelivery(delivery);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Bon de livraison modifié avec succès' : 'Bon de livraison créé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
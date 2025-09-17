import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/bon_reception_model.dart';
import '../../../../data/models/article_reception_model.dart';
import '../../../../data/models/client_model.dart';
import '../../../../data/models/article_model.dart';
import '../../../client/application/client_providers.dart';
import '../../../articles/application/article_providers.dart';
import '../../application/bon_reception_providers.dart';

class BonReceptionFormDialog extends ConsumerStatefulWidget {
  const BonReceptionFormDialog({super.key, this.reception});

  final BonReception? reception;

  @override
  ConsumerState<BonReceptionFormDialog> createState() => _BonReceptionFormDialogState();
}

class _BonReceptionFormDialogState extends ConsumerState<BonReceptionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commandeNumberController = TextEditingController();
  final _notesController = TextEditingController();
  
  Client? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'en_attente';
  List<ArticleReception> _articles = [];
  bool _isLoading = false;
  
  bool get _isEditing => widget.reception != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadReceptionData();
    }
  }

  void _loadReceptionData() {
    final reception = widget.reception!;
    _commandeNumberController.text = reception.commandeNumber;
    _notesController.text = reception.notes ?? '';
    _selectedDate = reception.dateReception;
    _selectedStatus = reception.status;
    _articles = List.from(reception.articles);
    
    // Load client data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clients = ref.read(activeClientsProvider);
      try {
        _selectedClient = clients.firstWhere(
          (client) => client.id == reception.clientId,
        );
      } catch (e) {
        _selectedClient = null;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commandeNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(activeClientsProvider);
    final articles = ref.watch(activeArticlesProvider);
    
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
            _buildHeader(),
            const SizedBox(height: 24),

            // Form
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Basic fields
                      _buildBasicFields(clients),
                      const SizedBox(height: 24),

                      // Articles section
                      _buildArticlesSection(articles),
                      const SizedBox(height: 16),

                      // Notes section
                      _buildNotesSection(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _isEditing ? Icons.edit : Icons.add_box,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          _isEditing ? 'Modifier le bon de réception' : 'Nouveau bon de réception',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
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

  Widget _buildBasicFields(List<Client> clients) {
    return Column(
      children: [
        Row(
          children: [
            // Client dropdown
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
                    child: Text(client.name),
                  );
                }).toList(),
                onChanged: (client) {
                  setState(() {
                    _selectedClient = client;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un client';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Commande number
            Expanded(
              child: TextFormField(
                controller: _commandeNumberController,
                decoration: InputDecoration(
                  labelText: 'N° Commande *',
                  prefixIcon: Icon(Icons.receipt_long, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  
                  // Check if commande number already exists
                  final repository = ref.read(bonReceptionRepositoryProvider);
                  final exists = repository.commandeNumberExists(
                    value.trim(),
                    excludeId: widget.reception?.id,
                  );
                  if (exists) {
                    return 'Ce numéro de commande existe déjà';
                  }
                  
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            // Date picker
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date de réception *',
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Status dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Statut',
                  prefixIcon: Icon(Icons.flag, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                  DropdownMenuItem(value: 'valide', child: Text('Validé')),
                  DropdownMenuItem(value: 'annule', child: Text('Annulé')),
                ],
                onChanged: (status) {
                  setState(() {
                    _selectedStatus = status!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticlesSection(List<Article> articles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Articles *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _addArticleDialog(articles),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter article'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_articles.isEmpty)
          Container(
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
                  child: Text('Veuillez ajouter au moins un article.'),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _articles.asMap().entries.map((entry) {
                final index = entry.key;
                final article = entry.value;
                
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: index < _articles.length - 1 
                          ? BorderSide(color: AppColors.divider) 
                          : BorderSide.none,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        article.quantity.toString(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      article.articleReference,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(article.articleDesignation),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${article.unitPrice.toStringAsFixed(2)} DT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _editArticle(index, articles),
                          icon: const Icon(Icons.edit),
                          color: AppColors.info,
                          iconSize: 20,
                        ),
                        IconButton(
                          onPressed: () => _removeArticle(index),
                          icon: const Icon(Icons.delete),
                          color: AppColors.error,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
        if (_articles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_articles.length} articles - ${_articles.fold(0, (sum, a) => sum + a.quantity)} unités',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${_articles.fold(0.0, (sum, a) => sum + a.totalPrice).toStringAsFixed(2)} DT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    return TextFormField(
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
      textInputAction: TextInputAction.done,
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
          onPressed: _isLoading ? null : _saveReception,
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _addArticleDialog(List<Article> articles) {
    showDialog(
      context: context,
      builder: (context) => _ArticleSelectionDialog(
        articles: articles,
        onArticleSelected: (articleReception) {
          setState(() {
            _articles.add(articleReception);
          });
        },
      ),
    );
  }

  void _editArticle(int index, List<Article> articles) {
    showDialog(
      context: context,
      builder: (context) => _ArticleSelectionDialog(
        articles: articles,
        initialArticle: _articles[index],
        onArticleSelected: (articleReception) {
          setState(() {
            _articles[index] = articleReception;
          });
        },
      ),
    );
  }

  void _removeArticle(int index) {
    setState(() {
      _articles.removeAt(index);
    });
  }

  Future<void> _saveReception() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner un client'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez ajouter au moins un article'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reception = _isEditing
          ? widget.reception!.copyWith(
              clientId: _selectedClient!.id,
              dateReception: _selectedDate,
              commandeNumber: _commandeNumberController.text.trim(),
              articles: List.from(_articles),
              status: _selectedStatus,
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            )
          : BonReception(
              clientId: _selectedClient!.id,
              dateReception: _selectedDate,
              commandeNumber: _commandeNumberController.text.trim(),
              articles: List.from(_articles),
              status: _selectedStatus,
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            );

      if (_isEditing) {
        await ref.read(bonReceptionListProvider.notifier).updateReception(reception);
      } else {
        await ref.read(bonReceptionListProvider.notifier).addReception(reception);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Bon de réception modifié avec succès' : 'Bon de réception créé avec succès'),
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

// Article selection dialog
class _ArticleSelectionDialog extends StatefulWidget {
  const _ArticleSelectionDialog({
    required this.articles,
    required this.onArticleSelected,
    this.initialArticle,
  });

  final List<Article> articles;
  final Function(ArticleReception) onArticleSelected;
  final ArticleReception? initialArticle;

  @override
  State<_ArticleSelectionDialog> createState() => _ArticleSelectionDialogState();
}

class _ArticleSelectionDialogState extends State<_ArticleSelectionDialog> {
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  Article? _selectedArticle;

  @override
  void initState() {
    super.initState();
    if (widget.initialArticle != null) {
      final initial = widget.initialArticle!;
      _quantityController.text = initial.quantity.toString();
      _priceController.text = initial.unitPrice.toString();
      
      // Find the article
      try {
        _selectedArticle = widget.articles.firstWhere(
          (article) => article.reference == initial.articleReference,
        );
      } catch (e) {
        _selectedArticle = null;
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialArticle != null ? 'Modifier l\'article' : 'Ajouter un article'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Article dropdown
            DropdownButtonFormField<Article>(
              value: _selectedArticle,
              decoration: InputDecoration(
                labelText: 'Article *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: widget.articles.map((article) {
                return DropdownMenuItem<Article>(
                  value: article,
                  child: Text('${article.reference} - ${article.designation}'),
                );
              }).toList(),
              onChanged: (article) {
                setState(() {
                  _selectedArticle = article;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un article';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Quantity field
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantité *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Quantité requise';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Quantité invalide';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Price field
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Prix unitaire *',
                suffixText: 'DT',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Prix requis';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Prix invalide';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveArticle,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  void _saveArticle() {
    if (_selectedArticle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un article')),
      );
      return;
    }
    
    final quantity = int.tryParse(_quantityController.text);
    final price = double.tryParse(_priceController.text);
    
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantité invalide')),
      );
      return;
    }
    
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prix invalide')),
      );
      return;
    }

    final articleReception = ArticleReception(
      articleReference: _selectedArticle!.reference,
      quantity: quantity,
      unitPrice: price,
      articleDesignation: _selectedArticle!.designation,
    );

    widget.onArticleSelected(articleReception);
    Navigator.pop(context);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gestcom/core/constants/app_colors.dart';
import 'package:gestcom/core/constants/app_strings.dart';
import 'package:gestcom/core/providers/currency_provider.dart';
import 'package:gestcom/core/services/counter_service.dart';
import 'package:gestcom/core/utils/treatment_suggestion_service.dart';
import 'package:gestcom/data/models/bon_reception_model.dart';
import 'package:gestcom/data/models/article_reception_model.dart';
import 'package:gestcom/data/models/client_model.dart';
import 'package:gestcom/data/models/article_model.dart';
import 'package:gestcom/data/models/treatment_model.dart';
import 'package:gestcom/features/client/application/client_providers.dart';
import 'package:gestcom/features/articles/application/article_providers.dart';
import 'package:gestcom/features/articles/application/treatment_providers.dart';
import 'package:gestcom/features/articles/presentation/widgets/article_form_dialog.dart';
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
  String _brNumber = '';
  List<ArticleReception> _articles = [];
  bool _isLoading = false;
  
  bool get _isEditing => widget.reception != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadReceptionData();
    } else {
      // For new BR, show placeholder until saved
      _brNumber = 'Nouveau BR';
    }
  }

  void _loadReceptionData() {
    final reception = widget.reception!;
    _commandeNumberController.text = reception.commandeNumber;
    _notesController.text = reception.notes ?? '';
    _selectedDate = reception.dateReception;
    _brNumber = reception.numeroBR;
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
            
            // BR Number display
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Numéro BR',
                  prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                child: Text(
                  _brNumber.isEmpty ? 'Génération...' : _brNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _brNumber.isEmpty ? Colors.grey : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        Row(
          children: [
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
            
            const SizedBox(width: 16),
            
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article.articleDesignation),
                        if (article.treatmentName != null)
                          Text(
                            'Traitement: ${article.treatmentName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.info,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
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
      // Generate BR number only when actually saving a new BR
      String brNumber = _brNumber;
      if (!_isEditing) {
        brNumber = await CounterService.getNextBRNumber();
      }

      final reception = _isEditing
          ? widget.reception!.copyWith(
              clientId: _selectedClient!.id,
              dateReception: _selectedDate,
              commandeNumber: _commandeNumberController.text.trim(),
              articles: List.from(_articles),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              numeroBR: brNumber,
            )
          : BonReception(
              clientId: _selectedClient!.id,
              dateReception: _selectedDate,
              commandeNumber: _commandeNumberController.text.trim(),
              articles: List.from(_articles),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              numeroBR: brNumber,
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

// Enhanced Article selection dialog with create new article option
class _ArticleSelectionDialog extends ConsumerStatefulWidget {
  const _ArticleSelectionDialog({
    required this.articles,
    required this.onArticleSelected,
    this.initialArticle,
  });

  final List<Article> articles;
  final Function(ArticleReception) onArticleSelected;
  final ArticleReception? initialArticle;

  @override
  ConsumerState<_ArticleSelectionDialog> createState() => _ArticleSelectionDialogState();
}

class _ArticleSelectionDialogState extends ConsumerState<_ArticleSelectionDialog> {
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _newRefController = TextEditingController();
  final _newDesignationController = TextEditingController();
  
  Article? _selectedArticle;
  Treatment? _selectedTreatment;
  String? _customTreatmentName;
  double? _customTreatmentPrice;
  List<String> _suggestedTreatments = [];
  bool _isCreatingNew = false;

  @override
  void initState() {
    super.initState();
    
    // Add listener for designation changes to trigger suggestions
    _newDesignationController.addListener(_onDesignationChanged);
    
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
        // Article not found, maybe it was created inline
        _isCreatingNew = true;
        _newRefController.text = initial.articleReference;
        _newDesignationController.text = initial.articleDesignation;
        _onDesignationChanged(); // Trigger suggestions for existing designation
      }

      // Load treatment if available
      if (initial.treatmentId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final treatments = ref.read(activeTreatmentsProvider);
          try {
            _selectedTreatment = treatments.firstWhere(
              (treatment) => treatment.id == initial.treatmentId,
            );
            setState(() {});
          } catch (e) {
            // Treatment not found - might be custom treatment
            _customTreatmentName = initial.treatmentName;
          }
        });
      }
    }
  }

  void _onDesignationChanged() {
    final designation = _newDesignationController.text.trim();
    if (designation.isNotEmpty) {
      setState(() {
        _suggestedTreatments = TreatmentSuggestionService.getSuggestedTreatmentsByCategory(designation);
      });
    } else {
      setState(() {
        _suggestedTreatments = [];
      });
    }
  }

  @override
  void dispose() {
    _newDesignationController.removeListener(_onDesignationChanged);
    _quantityController.dispose();
    _priceController.dispose();
    _newRefController.dispose();
    _newDesignationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialArticle != null ? 'Modifier l\'article' : 'Ajouter un article'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle between existing and new article
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCreatingNew = false;
                          _selectedArticle = null;
                        });
                      },
                      icon: Icon(
                        Icons.inventory,
                        color: !_isCreatingNew ? AppColors.primary : Colors.grey,
                      ),
                      label: Text(
                        'Article existant',
                        style: TextStyle(
                          color: !_isCreatingNew ? AppColors.primary : Colors.grey,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: !_isCreatingNew ? AppColors.primary : Colors.grey,
                          width: !_isCreatingNew ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCreatingNew = true;
                          _selectedArticle = null;
                        });
                      },
                      icon: Icon(
                        Icons.add_box,
                        color: _isCreatingNew ? AppColors.success : Colors.grey,
                      ),
                      label: Text(
                        'Créer nouveau',
                        style: TextStyle(
                          color: _isCreatingNew ? AppColors.success : Colors.grey,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _isCreatingNew ? AppColors.success : Colors.grey,
                          width: _isCreatingNew ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Article selection or creation
              if (_isCreatingNew) ...[
                // New article creation fields
                TextFormField(
                  controller: _newRefController,
                  decoration: InputDecoration(
                    labelText: 'Référence *',
                    prefixIcon: Icon(Icons.tag, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _newDesignationController,
                  decoration: InputDecoration(
                    labelText: 'Désignation *',
                    prefixIcon: Icon(Icons.description, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),
              ] else ...[
                // Existing article selection
                DropdownButtonFormField<Article>(
                  value: _selectedArticle,
                  decoration: InputDecoration(
                    labelText: 'Article *',
                    prefixIcon: Icon(Icons.inventory, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
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
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Common fields for both modes
              Row(
                children: [
                  // Quantity field
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantité *',
                        prefixIcon: Icon(Icons.confirmation_number, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Price field
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Prix unitaire *',
                        suffixText: 'DT',
                        prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Treatment suggestions for new articles
              if (_isCreatingNew && _suggestedTreatments.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Traitements suggérés:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _suggestedTreatments.take(6).map((suggestion) {
                          return ActionChip(
                            label: Text(suggestion),
                            onPressed: () => _addCustomTreatment(suggestion),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              
              if (_isCreatingNew && _suggestedTreatments.isNotEmpty)
                const SizedBox(height: 16),
              
              // Treatment selection
              DropdownButtonFormField<Treatment>(
                value: _selectedTreatment,
                decoration: InputDecoration(
                  labelText: 'Traitement existant (optionnel)',
                  prefixIcon: Icon(Icons.build, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                items: [
                  const DropdownMenuItem<Treatment>(
                    value: null,
                    child: Text('Aucun traitement'),
                  ),
                  ...ref.watch(activeTreatmentsProvider).map((treatment) {
                    final currencyService = ref.watch(currencyServiceProvider);
                    final formattedPrice = currencyService.formatPrice(treatment.defaultPrice);
                    return DropdownMenuItem<Treatment>(
                      value: treatment,
                      child: Text('${treatment.name} - $formattedPrice'),
                    );
                  }).toList(),
                ],
                onChanged: (treatment) {
                  setState(() {
                    _selectedTreatment = treatment;
                    // Clear custom treatment if existing treatment is selected
                    if (treatment != null) {
                      _customTreatmentName = null;
                      _customTreatmentPrice = null;
                      _priceController.text = treatment.defaultPrice.toString();
                    }
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Custom treatment section
              if (_customTreatmentName != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.label_outline, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Traitement personnalisé:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.success,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _customTreatmentName = null;
                                _customTreatmentPrice = null;
                              });
                            },
                            icon: Icon(Icons.close, size: 18),
                            color: AppColors.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _customTreatmentName!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (_customTreatmentPrice != null)
                        Text(
                          ref.watch(currencyServiceProvider).formatPrice(_customTreatmentPrice!),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Add custom treatment button
              if (_customTreatmentName == null && _selectedTreatment == null)
                TextButton.icon(
                  onPressed: () => _showCustomTreatmentDialog(),
                  icon: Icon(Icons.add, color: AppColors.primary),
                  label: Text(
                    'Ajouter un traitement personnalisé',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              
              if (_isCreatingNew) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: AppColors.info, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Le nouvel article sera automatiquement ajouté au catalogue.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveArticle,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isCreatingNew ? AppColors.success : AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(_isCreatingNew ? 'Créer et Ajouter' : 'Ajouter'),
        ),
      ],
    );
  }

  void _addCustomTreatment(String treatmentName) {
    setState(() {
      _customTreatmentName = treatmentName;
      _selectedTreatment = null; // Clear existing treatment selection
    });
    _showCustomTreatmentDialog(treatmentName);
  }

  Future<void> _showCustomTreatmentDialog([String? suggestedName]) async {
    final nameController = TextEditingController(text: suggestedName ?? _customTreatmentName ?? '');
    final priceController = TextEditingController(
      text: _customTreatmentPrice?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Traitement personnalisé'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du traitement',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Prix (${ref.watch(currencySymbolProvider)}) - optionnel',
                  border: const OutlineInputBorder(),
                  suffixText: ref.watch(currencySymbolProvider),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Prix invalide';
                    }
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final price = priceController.text.trim().isNotEmpty
                    ? double.tryParse(priceController.text.trim())
                    : null;
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'price': price,
                });
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _customTreatmentName = result['name'];
        _customTreatmentPrice = result['price'];
        _selectedTreatment = null;
        
        // Update price field if custom treatment has a price
        if (_customTreatmentPrice != null) {
          _priceController.text = _customTreatmentPrice!.toString();
        }
      });
    }
  }

  Future<void> _saveArticle() async {
    // Validate fields
    if (_isCreatingNew) {
      if (_newRefController.text.trim().isEmpty) {
        _showError('Veuillez saisir une référence');
        return;
      }
      if (_newDesignationController.text.trim().isEmpty) {
        _showError('Veuillez saisir une désignation');
        return;
      }
    } else {
      if (_selectedArticle == null) {
        _showError('Veuillez sélectionner un article');
        return;
      }
    }
    
    final quantity = int.tryParse(_quantityController.text);
    final price = double.tryParse(_priceController.text);
    
    if (quantity == null || quantity <= 0) {
      _showError('Quantité invalide');
      return;
    }
    
    if (price == null || price < 0) {
      _showError('Prix invalide');
      return;
    }

    try {
      String articleRef;
      String articleDesignation;
      
      if (_isCreatingNew) {
        // Create new article and save to repository
        final newArticle = Article(
          reference: _newRefController.text.trim(),
          designation: _newDesignationController.text.trim(),
          traitementPrix: {}, // Empty treatments map initially
        );
        
        // Auto-save to ArticleRepository
        await ref.read(articleListProvider.notifier).addArticle(newArticle);
        
        articleRef = newArticle.reference;
        articleDesignation = newArticle.designation;
        
        // Show success message for new article creation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nouvel article "${newArticle.reference}" créé et ajouté au catalogue'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        articleRef = _selectedArticle!.reference;
        articleDesignation = _selectedArticle!.designation;
      }

      final articleReception = ArticleReception(
        articleReference: articleRef,
        quantity: quantity,
        unitPrice: price,
        articleDesignation: articleDesignation,
        treatmentId: _selectedTreatment?.id ?? (_customTreatmentName != null ? 'custom_${DateTime.now().millisecondsSinceEpoch}' : null),
        treatmentName: _selectedTreatment?.name ?? _customTreatmentName,
      );

      widget.onArticleSelected(articleReception);
      Navigator.pop(context);
    } catch (e) {
      _showError('Erreur lors de la création: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
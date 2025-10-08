import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/treatment_suggestion_service.dart';
import '../../../../data/models/article_model.dart';
import '../../../../data/models/client_model.dart';
import '../../../../data/models/treatment_model.dart';
import '../../application/article_providers.dart';
import '../../application/treatment_providers.dart';
import '../../../client/application/client_providers.dart';

class ArticleFormDialog extends ConsumerStatefulWidget {
  const ArticleFormDialog({super.key, this.article});

  final Article? article;

  @override
  ConsumerState<ArticleFormDialog> createState() => _ArticleFormDialogState();
}

class _ArticleFormDialogState extends ConsumerState<ArticleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _designationController = TextEditingController();
  
  Map<String, TextEditingController> _priceControllers = {};
  Map<String, double> _treatmentPrices = {};
  Map<String, String> _customTreatmentNames = {}; // For custom treatments
  List<String> _suggestedTreatments = [];
  String? _selectedClientId; // null = general article
  bool _isActive = true;
  bool _isLoading = false;
  
  bool get _isEditing => widget.article != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadArticleData();
    }
    
    // Add listener for designation changes to trigger suggestions
    _designationController.addListener(_onDesignationChanged);
  }

  void _loadArticleData() {
    final article = widget.article!;
    _referenceController.text = article.reference;
    _designationController.text = article.designation;
    _treatmentPrices = Map.from(article.traitementPrix);
    _selectedClientId = article.clientId;
    _isActive = article.isActive;
    
    // Initialize price controllers for existing treatments
    for (final entry in article.traitementPrix.entries) {
      final controller = TextEditingController(text: entry.value.toString());
      _priceControllers[entry.key] = controller;
    }
  }

  void _onDesignationChanged() {
    final designation = _designationController.text.trim();
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
    _designationController.removeListener(_onDesignationChanged);
    _referenceController.dispose();
    _designationController.dispose();
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treatments = ref.watch(activeTreatmentsProvider);
    final clients = ref.watch(clientListProvider);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 600),
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

                      // Treatments section
                      _buildTreatmentsSection(treatments),
                      const SizedBox(height: 16),

                      // Active status
                      _buildActiveStatusField(),
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
          _isEditing ? 'Modifier l\'article' : 'Nouvel article',
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
            // Reference field
            Expanded(
              child: TextFormField(
                controller: _referenceController,
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  
                  // Check if reference already exists
                  final repository = ref.read(articleRepositoryProvider);
                  final exists = repository.referenceExists(
                    value.trim(),
                    excludeId: widget.article?.id,
                  );
                  if (exists) {
                    return 'Cette référence existe déjà';
                  }
                  
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Active status toggle
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  Text(
                    'Actif',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                    activeColor: AppColors.success,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Designation field
        TextFormField(
          controller: _designationController,
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.fieldRequired;
            }
            return null;
          },
          maxLines: 2,
          textInputAction: TextInputAction.next,
        ),
        
        const SizedBox(height: 16),
        
        // Client selection dropdown
        DropdownButtonFormField<String?>(
          value: _selectedClientId,
          decoration: InputDecoration(
            labelText: 'Client',
            prefixIcon: Icon(Icons.person, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            helperText: 'Laissez vide pour un article général',
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Article général (tous les clients)'),
            ),
            ...clients.map((client) => DropdownMenuItem<String?>(
              value: client.id,
              child: Text(client.name),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedClientId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTreatmentsSection(List<Treatment> treatments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prix par traitement *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sélectionnez les traitements et définissez leurs prix',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        
        // Treatment suggestions based on designation
        if (_suggestedTreatments.isNotEmpty) 
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
                    Icon(Icons.lightbulb_outline, 
                         color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Traitements suggérés pour cette catégorie:',
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
                  children: _suggestedTreatments.map((suggestion) {
                    final isAlreadySelected = treatments.any((t) => 
                        t.name.toLowerCase().contains(suggestion.toLowerCase()) &&
                        _treatmentPrices.containsKey(t.id));
                    
                    return FilterChip(
                      label: Text(suggestion),
                      selected: false,
                      onSelected: isAlreadySelected ? null : (selected) {
                        if (selected) {
                          _showManualTreatmentDialog(suggestion);
                        }
                      },
                      backgroundColor: isAlreadySelected 
                          ? AppColors.success.withOpacity(0.2)
                          : null,
                      disabledColor: AppColors.success.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isAlreadySelected 
                            ? AppColors.success 
                            : AppColors.primary,
                      ),
                    );
                  }).toList(),
                ),
                if (_suggestedTreatments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Cliquez sur une suggestion pour ajouter un traitement personnalisé',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (_suggestedTreatments.isNotEmpty)
          const SizedBox(height: 16),
        
        if (treatments.isEmpty)
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
                  child: Text('Aucun traitement actif disponible. Veuillez d\'abord créer des traitements.'),
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
              children: treatments.map((treatment) {
                final isSelected = _treatmentPrices.containsKey(treatment.id);
                final controller = _priceControllers[treatment.id] ??= 
                    TextEditingController(text: treatment.defaultPrice.toString());
                
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: treatments.last != treatment 
                          ? BorderSide(color: AppColors.divider) 
                          : BorderSide.none,
                    ),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _treatmentPrices[treatment.id] = 
                                double.tryParse(controller.text) ?? treatment.defaultPrice;
                          } else {
                            _treatmentPrices.remove(treatment.id);
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    title: Text(
                      treatment.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      treatment.description,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: controller,
                        enabled: isSelected,
                        decoration: InputDecoration(
                          isDense: true,
                          suffixText: ref.watch(currencySymbolProvider),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: isSelected ? (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Prix requis';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price < 0) {
                            return 'Prix invalide';
                          }
                          return null;
                        } : null,
                        onChanged: (value) {
                          if (isSelected) {
                            final price = double.tryParse(value);
                            if (price != null) {
                              _treatmentPrices[treatment.id] = price;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        
        // Manual treatment addition
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _showManualTreatmentDialog(null),
          icon: Icon(Icons.add, color: AppColors.primary),
          label: Text(
            'Ajouter un traitement personnalisé',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        
        // Custom treatments section
        if (_customTreatmentNames.isNotEmpty) 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Traitements personnalisés',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _customTreatmentNames.entries.map((entry) {
                final customId = entry.key;
                final treatmentName = entry.value;
                final controller = _priceControllers[customId]!;
                
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: _customTreatmentNames.entries.last.key != customId
                          ? BorderSide(color: AppColors.divider)
                          : BorderSide.none,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.label_outline,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      treatmentName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Traitement personnalisé',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Consumer(
                            builder: (context, ref, _) {
                              final currencyService = ref.watch(currencyServiceProvider);
                              return TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  isDense: true,
                                  suffixText: currencyService.getCurrencySymbol(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
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
                                onChanged: (value) {
                                  final price = double.tryParse(value);
                                  if (price != null) {
                                    _treatmentPrices[customId] = price;
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _treatmentPrices.remove(customId);
                              _customTreatmentNames.remove(customId);
                              _priceControllers[customId]?.dispose();
                              _priceControllers.remove(customId);
                            });
                          },
                          icon: Icon(Icons.delete_outline),
                          color: AppColors.error,
                          tooltip: 'Supprimer ce traitement',
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
            ],
          ),
        
        if (_treatmentPrices.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Veuillez sélectionner au moins un traitement',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveStatusField() {
    return const SizedBox(); // Already included in basic fields
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
          onPressed: _isLoading ? null : _saveArticle,
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

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_treatmentPrices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner au moins un traitement'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final article = _isEditing
          ? widget.article!.copyWith(
              reference: _referenceController.text.trim(),
              designation: _designationController.text.trim(),
              traitementPrix: Map.from(_treatmentPrices),
              clientId: _selectedClientId,
              isActive: _isActive,
            )
          : Article(
              reference: _referenceController.text.trim(),
              designation: _designationController.text.trim(),
              traitementPrix: Map.from(_treatmentPrices),
              clientId: _selectedClientId,
              isActive: _isActive,
            );

      if (_isEditing) {
        await ref.read(articleListProvider.notifier).updateArticle(article);
      } else {
        await ref.read(articleListProvider.notifier).addArticle(article);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Article modifié avec succès' : 'Article ajouté avec succès'),
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

  Future<void> _showManualTreatmentDialog(String? suggestedName) async {
    final nameController = TextEditingController(text: suggestedName ?? '');
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un traitement personnalisé'),
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
              Consumer(
                builder: (context, ref, _) {
                  final currencyService = ref.watch(currencyServiceProvider);
                  return TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Prix',
                      border: const OutlineInputBorder(),
                      suffixText: currencyService.getCurrencySymbol(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le prix est requis';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 0) {
                        return 'Prix invalide';
                      }
                      return null;
                    },
                  );
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
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'price': double.parse(priceController.text.trim()),
                });
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result != null) {
      // Store custom treatment with name embedded in ID for persistence
      final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}_${result['name'].replaceAll(' ', '_')}';
      setState(() {
        _treatmentPrices[customId] = result['price'];
        _customTreatmentNames[customId] = result['name'];
        _priceControllers[customId] = TextEditingController(
          text: result['price'].toString(),
        );
      });
    }
  }
}
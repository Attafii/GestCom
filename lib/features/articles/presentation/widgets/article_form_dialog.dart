import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/article_model.dart';
import '../../../../data/models/treatment_model.dart';
import '../../application/article_providers.dart';
import '../../application/treatment_providers.dart';

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
  bool _isActive = true;
  bool _isLoading = false;
  
  bool get _isEditing => widget.article != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadArticleData();
    }
  }

  void _loadArticleData() {
    final article = widget.article!;
    _referenceController.text = article.reference;
    _designationController.text = article.designation;
    _treatmentPrices = Map.from(article.traitementPrix);
    _isActive = article.isActive;
    
    // Initialize price controllers for existing treatments
    for (final entry in article.traitementPrix.entries) {
      final controller = TextEditingController(text: entry.value.toString());
      _priceControllers[entry.key] = controller;
    }
  }

  @override
  void dispose() {
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
                      _buildBasicFields(),
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

  Widget _buildBasicFields() {
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
                          suffixText: 'DT',
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
              isActive: _isActive,
            )
          : Article(
              reference: _referenceController.text.trim(),
              designation: _designationController.text.trim(),
              traitementPrix: Map.from(_treatmentPrices),
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
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/article_model.dart';
import '../../../../data/models/treatment_model.dart';
import '../../application/article_providers.dart';
import '../../application/treatment_providers.dart';
import '../widgets/article_form_dialog.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({super.key});

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref.watch(articleListProvider);
    final treatments = ref.watch(activeTreatmentsProvider);
    final activeFilter = ref.watch(articleActiveFilterProvider);
    final searchQuery = ref.watch(articleSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            _buildHeader(context),
            const SizedBox(height: 24),

            // Search and filters
            _buildSearchAndFilters(context, activeFilter),
            const SizedBox(height: 24),

            // Data table
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table header
                      _buildTableHeader(articles, activeFilter),
                      const SizedBox(height: 16),

                      // Data table
                      Expanded(
                        child: _buildDataTable(context, articles, treatments),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.inventory,
          size: 32,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Text(
          'Gestion des Articles',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showArticleDialog(context),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.add),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _exportArticles,
          icon: const Icon(Icons.download),
          label: const Text(AppStrings.export),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, bool? activeFilter) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par référence ou désignation...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(articleSearchQueryProvider.notifier).clear();
                      },
                      icon: Icon(Icons.clear, color: AppColors.textSecondary),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (value) {
              ref.read(articleSearchQueryProvider.notifier).updateQuery(value);
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Active status filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surface,
          ),
          child: DropdownButton<bool?>(
            value: activeFilter,
            hint: const Text('Statut'),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem<bool?>(
                value: null,
                child: Text('Tous'),
              ),
              DropdownMenuItem<bool?>(
                value: true,
                child: Text('Actifs'),
              ),
              DropdownMenuItem<bool?>(
                value: false,
                child: Text('Inactifs'),
              ),
            ],
            onChanged: (value) {
              ref.read(articleActiveFilterProvider.notifier).setFilter(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(List<Article> articles, bool? activeFilter) {
    String countText;
    if (activeFilter == null) {
      countText = '${articles.length} article(s)';
    } else if (activeFilter) {
      countText = '${articles.length} article(s) actif(s)';
    } else {
      countText = '${articles.length} article(s) inactif(s)';
    }

    return Row(
      children: [
        Text(
          'Liste des articles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          countText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context, List<Article> articles, List<Treatment> treatments) {
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun article trouvé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cliquez sur "Ajouter" pour créer votre premier article',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 900,
      headingRowColor: MaterialStateProperty.all(AppColors.tableHeader),
      dataRowColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withOpacity(0.1);
        }
        return null;
      }),
      columns: const [
        DataColumn2(
          label: Text('Référence', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Désignation', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Traitements', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
          fixedWidth: 140,
        ),
      ],
      rows: articles.map((article) {
        return DataRow2(
          cells: [
            DataCell(
              Text(
                article.reference,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(
              Text(
                article.designation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              _buildTreatmentsList(article, treatments),
            ),
            DataCell(
              _buildStatusChip(article.isActive),
            ),
            DataCell(
              _buildActionButtons(context, article),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTreatmentsList(Article article, List<Treatment> treatments) {
    if (article.traitementPrix.isEmpty) {
      return Text(
        'Aucun traitement',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final treatmentWidgets = <Widget>[];
    for (final treatmentId in article.treatmentIds) {
      final treatment = treatments.firstWhere(
        (t) => t.id == treatmentId,
        orElse: () => Treatment(name: 'Inconnu', description: '', defaultPrice: 0),
      );
      final price = article.getPriceForTreatment(treatmentId) ?? 0;

      treatmentWidgets.add(
        Container(
          margin: const EdgeInsets.only(right: 4, bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            '${treatment.name}: ${price.toStringAsFixed(2)} DT',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Wrap(
      children: treatmentWidgets,
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Text(
        isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Article article) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _toggleArticleStatus(article),
          icon: Icon(
            article.isActive ? Icons.pause_circle : Icons.play_circle,
            color: article.isActive ? AppColors.warning : AppColors.success,
          ),
          tooltip: article.isActive ? 'Désactiver' : 'Activer',
          iconSize: 20,
        ),
        IconButton(
          onPressed: () => _showArticleDialog(context, article: article),
          icon: Icon(Icons.edit, color: AppColors.primary),
          tooltip: AppStrings.edit,
          iconSize: 20,
        ),
        IconButton(
          onPressed: () => _deleteArticle(context, article),
          icon: Icon(Icons.delete, color: AppColors.error),
          tooltip: AppStrings.delete,
          iconSize: 20,
        ),
      ],
    );
  }

  void _showArticleDialog(BuildContext context, {Article? article}) {
    showDialog(
      context: context,
      builder: (context) => ArticleFormDialog(article: article),
    );
  }

  void _toggleArticleStatus(Article article) async {
    try {
      await ref.read(articleListProvider.notifier).toggleArticleStatus(article.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              article.isActive 
                ? 'Article désactivé avec succès' 
                : 'Article activé avec succès'
            ),
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
    }
  }

  void _deleteArticle(BuildContext context, Article article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'article "${article.reference}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(articleListProvider.notifier).deleteArticle(article.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Article supprimé avec succès'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _exportArticles() {
    // TODO: Implement Excel export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export Excel en cours de développement...'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
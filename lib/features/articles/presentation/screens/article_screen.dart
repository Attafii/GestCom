import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/services/excel_export_service.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../data/models/article_model.dart';
import '../../../../data/models/client_model.dart';
import '../../../../data/models/treatment_model.dart';
import '../../application/article_providers.dart';
import '../../application/treatment_providers.dart';
import '../../../client/application/client_providers.dart';
import '../widgets/article_form_dialog.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({super.key});

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, double> _rowHeights = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref.watch(articleListProvider);
    final treatments = ref.watch(activeTreatmentsProvider);
    final clients = ref.watch(clientListProvider);
    final activeFilter = ref.watch(articleActiveFilterProvider);
    final clientFilter = ref.watch(articleClientFilterProvider);
    final searchQuery = ref.watch(articleSearchQueryProvider);
    final responsive = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: responsive.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            _buildHeader(context, responsive),
            SizedBox(height: responsive.spacing),

            // Search and filters
            _buildSearchAndFilters(context, responsive, activeFilter, clientFilter, clients),
            SizedBox(height: responsive.spacing),

            // Data table
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(responsive.smallSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table header
                      _buildTableHeader(articles, activeFilter, clientFilter, clients, responsive),
                      SizedBox(height: responsive.smallSpacing),

                      // Data table
                      Expanded(
                        child: _buildDataTable(context, articles, treatments, clients, responsive),
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

  Widget _buildHeader(BuildContext context, ResponsiveUtils responsive) {
    if (responsive.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory,
                size: responsive.iconSize + 8,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gestion des Articles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: responsive.headerFontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.smallSpacing),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showArticleDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(AppStrings.add),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, responsive.buttonHeight),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _exportArticles,
                icon: const Icon(Icons.download, size: 18),
                label: const Text(AppStrings.export),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, responsive.buttonHeight),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(
          Icons.inventory,
          size: responsive.iconSize + 8,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Gestion des Articles',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: responsive.headerFontSize,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showArticleDialog(context),
          icon: Icon(Icons.add, size: responsive.iconSize),
          label: const Text(AppStrings.add),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            minimumSize: Size(0, responsive.buttonHeight),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _exportArticles,
          icon: Icon(Icons.download, size: responsive.iconSize),
          label: const Text(AppStrings.export),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, responsive.buttonHeight),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ResponsiveUtils responsive, bool? activeFilter, String? clientFilter, List<Client> clients) {
    final searchField = TextField(
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
    );

    final statusFilter = Container(
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
        isExpanded: true,
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
    );

    final clientFilterWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: DropdownButton<String?>(
        value: clientFilter,
        hint: const Text('Client'),
        underline: const SizedBox(),
        isExpanded: true,
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Tous les clients'),
          ),
          const DropdownMenuItem<String?>(
            value: 'general',
            child: Text('Articles généraux'),
          ),
          ...clients.map((client) => DropdownMenuItem<String?>(
            value: client.id,
            child: Text(client.name),
          )),
        ],
        onChanged: (value) {
          ref.read(articleClientFilterProvider.notifier).setFilter(value);
        },
      ),
    );

    if (responsive.isMobile) {
      return Column(
        children: [
          searchField,
          SizedBox(height: responsive.smallSpacing),
          statusFilter,
          SizedBox(height: responsive.smallSpacing),
          clientFilterWidget,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: searchField,
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 140,
          child: statusFilter,
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 180,
          child: clientFilterWidget,
        ),
      ],
    );
  }

  Widget _buildTableHeader(List<Article> articles, bool? activeFilter, String? clientFilter, List<Client> clients, ResponsiveUtils responsive) {
    String countText;
    final filters = <String>[];
    
    if (activeFilter == true) {
      filters.add('actif(s)');
    } else if (activeFilter == false) {
      filters.add('inactif(s)');
    }
    
    if (clientFilter != null) {
      if (clientFilter == 'general') {
        filters.add('généraux');
      } else {
        try {
          final client = clients.firstWhere((c) => c.id == clientFilter);
          filters.add('pour ${client.name}');
        } catch (e) {
          // Client not found, skip adding filter text
        }
      }
    }
    
    if (filters.isEmpty) {
      countText = '${articles.length} article(s)';
    } else {
      countText = '${articles.length} article(s) ${filters.join(', ')}';
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

  Widget _buildDataTable(BuildContext context, List<Article> articles, List<Treatment> treatments, List<Client> clients, ResponsiveUtils responsive) {
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
      minWidth: 1000,
      dataRowHeight: null,
      headingRowColor: MaterialStateProperty.all(AppColors.tableHeader),
      dataRowColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withOpacity(0.1);
        }
        return null;
      }),
      columns: [
        const DataColumn2(
          label: Text('Référence', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ),
        const DataColumn2(
          label: Text('Désignation', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.L,
        ),
        const DataColumn2(
          label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Traitements', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.L,
          fixedWidth: responsive.isMobile ? 250 : 350,
        ),
        const DataColumn2(
          label: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.S,
        ),
        const DataColumn2(
          label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
          fixedWidth: 140,
        ),
      ],
      rows: articles.asMap().entries.map((entry) {
        final index = entry.key;
        final article = entry.value;
        final minHeight = 48.0;
        final currentHeight = _rowHeights[index] ?? minHeight;
        
        return DataRow2(
          onSelectChanged: (_) {},
          specificRowHeight: currentHeight,
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
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
            ),
            DataCell(
              _buildClientCell(article, clients),
            ),
            DataCell(
              ClipRect(
                child: SizedBox(
                  width: responsive.isMobile ? 240 : 340,
                  child: _buildTreatmentsList(article, treatments, responsive),
                ),
              ),
            ),
            DataCell(
              _buildStatusChip(article.isActive),
            ),
            DataCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButtons(context, article),
                  if (index < articles.length - 1)
                    Expanded(child: SizedBox()),
                  if (index < articles.length - 1)
                    _buildRowResizeHandle(index, minHeight),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRowResizeHandle(int rowIndex, double minHeight) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          final currentHeight = _rowHeights[rowIndex] ?? minHeight;
          final newHeight = (currentHeight + details.delta.dy).clamp(minHeight, 300.0);
          _rowHeights[rowIndex] = newHeight;
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: Container(
          height: 8,
          width: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: Container(
              height: 2,
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientCell(Article article, List<Client> clients) {
    if (article.clientId == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Général',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    try {
      final client = clients.firstWhere(
        (c) => c.id == article.clientId,
      );
      
      return Text(
        client.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      );
    } catch (e) {
      return Text(
        'Client inconnu',
        style: TextStyle(
          color: AppColors.error,
          fontSize: 12,
        ),
      );
    }
  }

  Widget _buildTreatmentsList(Article article, List<Treatment> treatments, ResponsiveUtils responsive) {
    if (article.traitementPrix.isEmpty) {
      return Text(
        'Aucun traitement',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
          fontSize: responsive.isMobile ? 10 : 12,
        ),
      );
    }

    final currencyService = ref.watch(currencyServiceProvider);
    final treatmentWidgets = <Widget>[];
    
    for (final treatmentId in article.treatmentIds) {
      
      String treatmentName;
      
      // Check if it's a custom treatment (starts with 'custom_')
      if (treatmentId.startsWith('custom_')) {
        // Extract the name from the custom ID (format: custom_timestamp_name_with_underscores)
        final parts = treatmentId.split('_');
        if (parts.length > 2) {
          // Join all parts after 'custom_timestamp' to get the full name and replace underscores with spaces
          treatmentName = parts.sublist(2).join('_').replaceAll('_', ' ');
        } else {
          treatmentName = 'Traitement personnalisé';
        }
      } else {
        // Try to find the treatment in the treatments list
        final treatment = treatments.firstWhere(
          (t) => t.id == treatmentId,
          orElse: () => Treatment(name: 'Inconnu', description: '', defaultPrice: 0),
        );
        treatmentName = treatment.name;
      }
      
      final price = article.getPriceForTreatment(treatmentId) ?? 0;

      treatmentWidgets.add(
        Container(
          margin: EdgeInsets.only(
            right: responsive.isMobile ? 2 : 4,
            bottom: responsive.isMobile ? 2 : 3,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.isMobile ? 4 : 6,
            vertical: responsive.isMobile ? 1 : 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive.isMobile ? 3 : 4),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            '$treatmentName: ${currencyService.formatPrice(price)}',
            style: TextStyle(
              fontSize: responsive.isMobile ? 9 : 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: responsive.isMobile ? 2 : 4,
      runSpacing: responsive.isMobile ? 2 : 3,
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
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => _showArticleDialog(context, article: article),
          icon: Icon(Icons.edit, color: AppColors.primary),
          tooltip: AppStrings.edit,
          iconSize: 20,
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => _deleteArticle(context, article),
          icon: Icon(Icons.delete, color: AppColors.error),
          tooltip: AppStrings.delete,
          iconSize: 20,
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(),
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

  void _exportArticles() async {
    final articles = ref.read(articleListProvider);
    
    if (articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun article à exporter'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Export to Excel
      final excelService = ExcelExportService();
      final file = await excelService.exportArticles(articles);

      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 8),
                Text('Export Réussi'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${articles.length} article(s) exporté(s) avec succès.'),
                const SizedBox(height: 12),
                Text(
                  'Emplacement:\n${file.path}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await Process.run('start', ['', file.path], runInShell: true);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l\'ouverture: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ouvrir'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading if open
      if (mounted) Navigator.of(context).pop();
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
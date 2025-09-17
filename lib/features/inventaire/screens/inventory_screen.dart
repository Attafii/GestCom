import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_providers.dart';
import '../dialogs/inventory_filter_dialog.dart';
import '../dialogs/article_history_dialog.dart';
import '../../../core/services/export_service.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(paginatedInventoryItemsProvider);
    final statistics = ref.watch(inventoryStatisticsProvider);
    final viewMode = ref.watch(inventoryViewModeProvider);
    final isLoading = ref.watch(inventoryExportLoadingProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final currentPage = ref.watch(inventoryCurrentPageProvider);
    final totalPages = ref.watch(inventoryTotalPagesProvider);
    final pageSize = ref.watch(inventoryPageSizeProvider);
    final filter = ref.watch(inventoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaire'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // View mode toggle
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'table',
                icon: Icon(Icons.table_view),
                label: Text('Table'),
              ),
              ButtonSegment(
                value: 'cards',
                icon: Icon(Icons.view_agenda),
                label: Text('Cartes'),
              ),
              ButtonSegment(
                value: 'summary',
                icon: Icon(Icons.analytics),
                label: Text('Résumé'),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (Set<String> selection) {
              ref.read(inventoryViewModeProvider.notifier).state = selection.first;
            },
          ),
          const SizedBox(width: 8),
          
          // Export buttons
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Exporter',
            onSelected: (String value) async {
              if (value == 'pdf' || value == 'excel') {
                await _exportInventory(context, ref, value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Exporter en PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Exporter en Excel'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Articles Total',
                    value: statistics.totalStockItems.toString(),
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: 'En Stock',
                    value: statistics.itemsWithStock.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: 'Rupture',
                    value: statistics.itemsWithoutStock.toString(),
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: 'Clients',
                    value: statistics.totalClients.toString(),
                    icon: Icons.people,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),

          // Search and filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un article, client ou traitement...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                      ref.read(inventoryCurrentPageProvider.notifier).state = 0;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: Text(filter != null ? 'Filtres (actifs)' : 'Filtres'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: filter != null ? Colors.blue.shade100 : null,
                  ),
                  onPressed: () => _showFilterDialog(context, ref),
                ),
              ],
            ),
          ),

          // Content based on view mode
          Expanded(
            child: viewMode == 'summary' 
                ? _buildSummaryView(ref, statistics)
                : viewMode == 'cards'
                    ? _buildCardsView(items, ref)
                    : _buildTableView(items, ref),
          ),

          // Pagination
          if (viewMode == 'table' && totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${currentPage + 1} sur $totalPages',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      DropdownButton<int>(
                        value: pageSize,
                        items: [10, 25, 50, 100].map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text('$size par page'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(inventoryPageSizeProvider.notifier).state = value;
                            ref.read(inventoryCurrentPageProvider.notifier).state = 0;
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_left),
                        onPressed: currentPage > 0
                            ? () => ref.read(inventoryCurrentPageProvider.notifier).state--
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_right),
                        onPressed: currentPage < totalPages - 1
                            ? () => ref.read(inventoryCurrentPageProvider.notifier).state++
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableView(List items, WidgetRef ref) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade100),
      columns: [
        DataColumn2(
          label: const Text('Client'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            ref.read(inventorySortFieldProvider.notifier).state = InventorySortField.clientName;
            ref.read(inventorySortAscendingProvider.notifier).state = ascending;
          },
        ),
        DataColumn2(
          label: const Text('Article'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            ref.read(inventorySortFieldProvider.notifier).state = InventorySortField.articleReference;
            ref.read(inventorySortAscendingProvider.notifier).state = ascending;
          },
        ),
        DataColumn2(
          label: const Text('Traitement'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) {
            ref.read(inventorySortFieldProvider.notifier).state = InventorySortField.treatmentName;
            ref.read(inventorySortAscendingProvider.notifier).state = ascending;
          },
        ),
        DataColumn2(
          label: const Text('Stock'),
          size: ColumnSize.S,
          numeric: true,
          onSort: (columnIndex, ascending) {
            ref.read(inventorySortFieldProvider.notifier).state = InventorySortField.currentStock;
            ref.read(inventorySortAscendingProvider.notifier).state = ascending;
          },
        ),
        DataColumn2(
          label: const Text('Dernière Réception'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) {
            ref.read(inventorySortFieldProvider.notifier).state = InventorySortField.lastReceptionDate;
            ref.read(inventorySortAscendingProvider.notifier).state = ascending;
          },
        ),
        DataColumn2(
          label: const Text('Actions'),
          size: ColumnSize.S,
        ),
      ],
      rows: items.map((item) => DataRow2(
        cells: [
          DataCell(Text(item.clientName)),
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.articleReference,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  item.articleDesignation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          DataCell(Text(item.treatmentName)),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.currentStock > 0 
                    ? Colors.green.shade100 
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.currentStock.toString(),
                style: TextStyle(
                  color: item.currentStock > 0 
                      ? Colors.green.shade800 
                      : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              item.lastReceptionDate != null
                  ? DateFormat('dd/MM/yyyy').format(item.lastReceptionDate!)
                  : '-',
            ),
          ),
          DataCell(
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Voir l\'historique',
              onPressed: () => _showArticleHistory(ref, item),
            ),
          ),
        ],
      )).toList(),
    );
  }

  Widget _buildCardsView(List items, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item.currentStock > 0 
                  ? Colors.green.shade100 
                  : Colors.red.shade100,
              child: Text(
                item.currentStock.toString(),
                style: TextStyle(
                  color: item.currentStock > 0 
                      ? Colors.green.shade800 
                      : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('${item.articleReference} - ${item.articleDesignation}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client: ${item.clientName}'),
                Text('Traitement: ${item.treatmentName}'),
                if (item.lastReceptionDate != null)
                  Text('Dernière réception: ${DateFormat('dd/MM/yyyy').format(item.lastReceptionDate!)}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showArticleHistory(ref, item),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildSummaryView(WidgetRef ref, statistics) {
    final stockByClient = ref.watch(stockByClientSummaryProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé par Client',
            style: Theme.of(ref.context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...stockByClient.entries.map((entry) {
            final clientData = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientData['clientName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${clientData['totalItems']} articles'),
                          Text('${clientData['itemsWithStock']} en stock'),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${clientData['totalStock']} unités',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _exportInventory(BuildContext context, WidgetRef ref, String format) async {
    ref.read(inventoryExportLoadingProvider.notifier).state = true;
    
    try {
      final items = ref.read(sortedInventoryItemsProvider);
      final exportService = ExportService();
      
      if (format == 'pdf') {
        await exportService.exportInventoryToPdf(items);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inventaire exporté en PDF avec succès')),
          );
        }
      } else if (format == 'excel') {
        await exportService.exportInventoryToExcel(items);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inventaire exporté en Excel avec succès')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export: $e')),
        );
      }
    } finally {
      ref.read(inventoryExportLoadingProvider.notifier).state = false;
    }
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const InventoryFilterDialog(),
    );
  }

  void _showArticleHistory(WidgetRef ref, item) {
    ref.read(selectedInventoryItemProvider.notifier).state = item;
    showDialog(
      context: ref.context,
      builder: (context) => const ArticleHistoryDialog(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
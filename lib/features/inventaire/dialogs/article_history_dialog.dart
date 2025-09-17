import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_providers.dart';

class ArticleHistoryDialog extends ConsumerWidget {
  const ArticleHistoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = ref.watch(selectedInventoryItemProvider);
    final history = ref.watch(articleHistoryProvider);

    if (selectedItem == null || history == null) {
      return const AlertDialog(
        title: Text('Erreur'),
        content: Text('Aucun article sélectionné'),
      );
    }

    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historique de l\'article',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${history.articleReference} - ${history.articleDesignation}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Client: ${history.clientName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Traitement: ${history.treatmentName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Stock actuel',
                    value: history.currentStock.toString(),
                    icon: Icons.inventory,
                    color: history.currentStock > 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    title: 'Total reçu',
                    value: history.totalReceived.toString(),
                    icon: Icons.input,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    title: 'Total livré',
                    value: history.totalDelivered.toString(),
                    icon: Icons.output,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    title: 'Mouvements',
                    value: history.movements.length.toString(),
                    icon: Icons.swap_horiz,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Movements table
            Text(
              'Historique des mouvements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: history.movements.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun mouvement trouvé',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 0,
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.shade100,
                      ),
                      columns: const [
                        DataColumn2(
                          label: Text('Type'),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Text('Date'),
                          size: ColumnSize.M,
                        ),
                        DataColumn2(
                          label: Text('Référence'),
                          size: ColumnSize.M,
                        ),
                        DataColumn2(
                          label: Text('Quantité'),
                          size: ColumnSize.S,
                          numeric: true,
                        ),
                        DataColumn2(
                          label: Text('Prix unitaire'),
                          size: ColumnSize.S,
                          numeric: true,
                        ),
                        DataColumn2(
                          label: Text('Montant total'),
                          size: ColumnSize.M,
                          numeric: true,
                        ),
                        DataColumn2(
                          label: Text('Statut'),
                          size: ColumnSize.S,
                        ),
                      ],
                      rows: history.movements.map((movement) {
                        final isReception = movement.type == 'reception';
                        
                        return DataRow2(
                          cells: [
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isReception
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isReception ? 'Réception' : 'Livraison',
                                  style: TextStyle(
                                    color: isReception
                                        ? Colors.green.shade800
                                        : Colors.orange.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(movement.date)),
                            ),
                            DataCell(Text(movement.reference)),
                            DataCell(
                              Text(
                                '${isReception ? '+' : '-'}${movement.quantity}',
                                style: TextStyle(
                                  color: isReception ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                movement.unitPrice != null
                                    ? '${movement.unitPrice!.toStringAsFixed(2)} €'
                                    : '-',
                              ),
                            ),
                            DataCell(
                              Text(
                                movement.totalAmount != null
                                    ? '${movement.totalAmount!.toStringAsFixed(2)} €'
                                    : '-',
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(movement.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(movement.status),
                                  style: TextStyle(
                                    color: _getStatusColor(movement.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Exporter'),
                  onPressed: () {
                    // TODO: Implement export functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export non implémenté'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reçu':
      case 'livre':
        return Colors.green;
      case 'en_attente':
      case 'en_preparation':
        return Colors.orange;
      case 'annule':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'reçu':
        return 'Reçu';
      case 'livre':
        return 'Livré';
      case 'en_attente':
        return 'En attente';
      case 'en_preparation':
        return 'En préparation';
      case 'annule':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
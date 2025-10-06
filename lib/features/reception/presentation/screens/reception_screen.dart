import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import 'package:gestcom/core/constants/app_colors.dart';
import 'package:gestcom/core/constants/app_strings.dart';
import 'package:gestcom/data/models/bon_reception_model.dart';
import 'package:gestcom/data/models/client_model.dart';
import 'package:gestcom/features/client/application/client_providers.dart';
import '../../application/bon_reception_providers.dart';
import '../widgets/bon_reception_form_dialog.dart';

class ReceptionScreen extends ConsumerStatefulWidget {
  const ReceptionScreen({super.key});

  @override
  ConsumerState<ReceptionScreen> createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends ConsumerState<ReceptionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receptions = ref.watch(bonReceptionListProvider);
    final clients = ref.watch(activeClientsProvider);
    final clientFilter = ref.watch(bonReceptionClientFilterProvider);
    final searchQuery = ref.watch(bonReceptionSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            Row(
              children: [
                Icon(
                  Icons.input,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Bons de réception',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showReceptionDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau bon'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Filters and search
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Search field
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Rechercher par n° commande, notes ou articles...',
                              prefixIcon: Icon(Icons.search, color: AppColors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.divider),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.primary),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (value) {
                              ref.read(bonReceptionSearchQueryProvider.notifier).updateQuery(value);
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Client filter
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: clientFilter,
                            decoration: InputDecoration(
                              labelText: 'Filtrer par client',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Tous les clients'),
                              ),
                              ...clients.map((client) {
                                return DropdownMenuItem<String>(
                                  value: client.id,
                                  child: Text(client.name),
                                );
                              }),
                            ],
                            onChanged: (clientId) {
                              ref.read(bonReceptionClientFilterProvider.notifier).selectClient(clientId);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Clear filters button
                    if (searchQuery.isNotEmpty || clientFilter != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            ref.read(bonReceptionSearchQueryProvider.notifier).clearQuery();
                            ref.read(bonReceptionClientFilterProvider.notifier).clearFilter();
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Effacer les filtres'),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Statistics cards
            _buildStatisticsCards(receptions),

            const SizedBox(height: 16),

            // Data table
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liste des bons de réception (${receptions.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildDataTable(receptions, clients),
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

  Widget _buildStatisticsCards(List<BonReception> receptions) {
    // Statistics calculations
    final totalCount = receptions.length;
    final totalQuantity = receptions.fold(0, (sum, r) => sum + r.totalQuantity);
    final totalAmount = receptions.fold(0.0, (sum, r) => sum + r.totalAmount);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total des bons',
            receptions.length.toString(),
            Icons.receipt_long,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Montant total',
            '${totalAmount.toStringAsFixed(2)} DT',
            Icons.monetization_on,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Quantité totale',
            totalQuantity.toString(),
            Icons.inventory,
            AppColors.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Quantité totale',
            totalQuantity.toString(),
            Icons.inventory,
            AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<BonReception> receptions, List<Client> clients) {
    if (receptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun bon de réception trouvé',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez votre premier bon de réception pour commencer',
            ),
          ],
        ),
      );
    }

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1100,
      columns: const [
        DataColumn2(
          label: Text('N° BR'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('N° Commande'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Client'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Date'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Articles'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Quantité'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Montant'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.S,
        ),
      ],
      rows: receptions.map((reception) {
        final client = clients.firstWhere(
          (c) => c.id == reception.clientId,
          orElse: () => Client(name: 'Client inconnu', address: '', matriculeFiscal: '', phone: '', email: ''),
        );

        return DataRow2(
          cells: [
            DataCell(
              Text(
                reception.numeroBR,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            DataCell(
              Text(
                reception.commandeNumber,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(
              Text(client.name),
            ),
            DataCell(
              Text(DateFormat('dd/MM/yyyy').format(reception.dateReception)),
            ),
            DataCell(
              Text(reception.articlesCount.toString()),
            ),
            DataCell(
              Text(reception.totalQuantity.toString()),
            ),
            DataCell(
              Text(
                '${reception.totalAmount.toStringAsFixed(2)} DT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            DataCell(
              _buildActionButtons(reception),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BonReception reception) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View details
        Tooltip(
          message: 'Voir les détails',
          child: IconButton(
            onPressed: () => _showReceptionDetails(reception),
            icon: const Icon(Icons.visibility),
            iconSize: 20,
            color: AppColors.info,
          ),
        ),
        // Edit
        Tooltip(
          message: 'Modifier',
          child: IconButton(
            onPressed: () => _showReceptionDialog(context, reception: reception),
            icon: const Icon(Icons.edit),
            iconSize: 20,
            color: AppColors.primary,
          ),
        ),
        // Delete
        Tooltip(
          message: 'Supprimer',
          child: IconButton(
            onPressed: () => _deleteReception(reception),
            icon: const Icon(Icons.delete),
            iconSize: 20,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  void _showReceptionDialog(BuildContext context, {BonReception? reception}) {
    showDialog(
      context: context,
      builder: (context) => BonReceptionFormDialog(reception: reception),
    );
  }

  void _showReceptionDetails(BonReception reception) {
    showDialog(
      context: context,
      builder: (context) => _ReceptionDetailsDialog(reception: reception),
    );
  }

  void _deleteReception(BonReception reception) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le bon de réception "${reception.commandeNumber}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(bonReceptionListProvider.notifier).deleteReception(reception.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bon de réception supprimé avec succès'),
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

}

// Reception details dialog
class _ReceptionDetailsDialog extends StatelessWidget {
  const _ReceptionDetailsDialog({required this.reception});

  final BonReception reception;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Détails du bon de réception',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Reception info
            _buildInfoSection(context),

            const SizedBox(height: 16),

            // Articles list
            Text(
              'Articles (${reception.articles.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: reception.articles.length,
                itemBuilder: (context, index) {
                  final article = reception.articles[index];
                  return Card(
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
                      title: Text(article.articleReference),
                      subtitle: Text(article.articleDesignation),
                      trailing: Text(
                        '${article.totalPrice.toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Total
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
                    'Total: ${reception.totalQuantity} unités',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${reception.totalAmount.toStringAsFixed(2)} DT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('N° Commande:', reception.commandeNumber),
        _buildInfoRow('Date de réception:', DateFormat('dd/MM/yyyy').format(reception.dateReception)),
        if (reception.notes != null && reception.notes!.isNotEmpty)
          _buildInfoRow('Notes:', reception.notes!),
        _buildInfoRow('Créé le:', DateFormat('dd/MM/yyyy HH:mm').format(reception.createdAt)),
        if (reception.updatedAt != reception.createdAt)
          _buildInfoRow('Modifié le:', DateFormat('dd/MM/yyyy HH:mm').format(reception.updatedAt)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
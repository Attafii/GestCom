import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/pdf_bl_service.dart';
import '../../../../core/services/excel_export_service.dart';
import '../../../../data/models/bon_livraison_model.dart';
import '../../../../data/models/client_model.dart';
import '../../../client/application/client_providers.dart';
import '../../application/bon_livraison_providers.dart';
import '../widgets/bon_livraison_form_dialog.dart';

class LivraisonScreen extends ConsumerStatefulWidget {
  const LivraisonScreen({super.key});

  @override
  ConsumerState<LivraisonScreen> createState() => _LivraisonScreenState();
}

class _LivraisonScreenState extends ConsumerState<LivraisonScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final deliveries = ref.watch(bonLivraisonListProvider);
    final clients = ref.watch(activeClientsProvider);
    final clientFilter = ref.watch(bonLivraisonClientFilterProvider);
    final statusFilter = ref.watch(bonLivraisonStatusFilterProvider);
    final searchQuery = ref.watch(bonLivraisonSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: responsive.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            _buildHeader(responsive),
            
            SizedBox(height: responsive.spacing),
            
            // Filters
            _buildFiltersCard(responsive, clients, clientFilter, statusFilter),
            
            SizedBox(height: responsive.spacing),
            
            // Statistics cards
            _buildStatisticsCards(responsive),
            
            SizedBox(height: responsive.spacing),
            
            // Data table
            Expanded(
              child: _buildDeliveriesTable(deliveries, clients),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveUtils responsive) {
    if (responsive.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                size: responsive.iconSize + 8,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion des Livraisons',
                      style: TextStyle(
                        fontSize: responsive.headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Créez et gérez les bons de livraison',
                      style: TextStyle(
                        fontSize: responsive.bodyFontSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing / 2),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeliveryDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau BL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: Size(0, responsive.buttonHeight),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportDeliveries,
                  icon: const Icon(Icons.download),
                  label: const Text('Exporter'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, responsive.buttonHeight),
                  ),
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
          Icons.local_shipping,
          size: responsive.iconSize + 8,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Livraisons',
              style: TextStyle(
                fontSize: responsive.headerFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Créez et gérez les bons de livraison',
              style: TextStyle(
                fontSize: responsive.bodyFontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showDeliveryDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Nouveau BL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            minimumSize: Size(0, responsive.buttonHeight),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _exportDeliveries,
          icon: const Icon(Icons.download),
          label: const Text('Exporter'),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, responsive.buttonHeight),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersCard(ResponsiveUtils responsive, List<Client> clients, String? clientFilter, String? statusFilter) {
    if (responsive.isMobile) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Search field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par numéro BL, client...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  isDense: true,
                ),
                onChanged: (value) {
                  ref.read(bonLivraisonSearchQueryProvider.notifier).updateQuery(value);
                },
              ),
              
              const SizedBox(height: 12),
              
              // Client filter
              DropdownButtonFormField<String>(
                value: clientFilter,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Filtrer par client',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tous les clients'),
                  ),
                  ...clients.map((client) => DropdownMenuItem<String>(
                    value: client.id,
                    child: Text(
                      client.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                ],
                onChanged: (value) {
                  ref.read(bonLivraisonClientFilterProvider.notifier).updateFilter(value);
                },
              ),
              
              const SizedBox(height: 12),
              
              // Status filter
              DropdownButtonFormField<String>(
                value: statusFilter,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Filtrer par statut',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tous les statuts'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'en_attente',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'livre',
                    child: Text('Livré'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'annule',
                    child: Text('Annulé'),
                  ),
                ],
                onChanged: (value) {
                  ref.read(bonLivraisonStatusFilterProvider.notifier).updateFilter(value);
                },
              ),
              
              const SizedBox(height: 12),
              
              // Clear filters button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear, size: responsive.iconSize),
                  label: const Text('Effacer les filtres'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Search field
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par numéro BL, client...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  isDense: true,
                ),
                onChanged: (value) {
                  ref.read(bonLivraisonSearchQueryProvider.notifier).updateQuery(value);
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Client filter
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: clientFilter,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Filtrer par client',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tous les clients'),
                  ),
                  ...clients.map((client) => DropdownMenuItem<String>(
                    value: client.id,
                    child: Text(
                      client.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                ],
                onChanged: (value) {
                  ref.read(bonLivraisonClientFilterProvider.notifier).updateFilter(value);
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Status filter
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: statusFilter,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Filtrer par statut',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tous les statuts'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'en_attente',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'livre',
                    child: Text('Livré'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'annule',
                    child: Text('Annulé'),
                  ),
                ],
                onChanged: (value) {
                  ref.read(bonLivraisonStatusFilterProvider.notifier).updateFilter(value);
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Clear filters button
            IconButton(
              onPressed: _clearFilters,
              icon: Icon(Icons.clear, color: AppColors.textSecondary),
              tooltip: 'Effacer les filtres',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(ResponsiveUtils responsive) {
    final stats = ref.watch(bonLivraisonStatisticsProvider);
    
    final cards = [
      _buildStatCard(
        responsive,
        'Total BL',
        stats['total'].toString(),
        Icons.receipt_long,
        AppColors.primary,
      ),
      _buildStatCard(
        responsive,
        'En attente',
        stats['pending'].toString(),
        Icons.pending,
        AppColors.warning,
      ),
      _buildStatCard(
        responsive,
        'Livrés',
        stats['delivered'].toString(),
        Icons.check_circle,
        AppColors.success,
      ),
      _buildStatCard(
        responsive,
        'Total Pi\u00e8ces',
        '${stats['totalPieces']} pcs',
        Icons.inventory_2,
        AppColors.info,
      ),
    ];
    
    if (responsive.isMobile) {
      return Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: card,
        )).toList(),
      );
    }
    
    return Row(
      children: cards.map((card) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: card,
        ),
      )).toList(),
    );
  }

  Widget _buildStatCard(ResponsiveUtils responsive, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(responsive.isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: responsive.iconSize),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: responsive.isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: responsive.isMobile ? 12 : 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveriesTable(List<BonLivraison> deliveries, List<Client> clients) {
    if (deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun bon de livraison trouvé',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier bon de livraison',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bons de livraison (${deliveries.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1000,
                dataRowHeight: null,
                columns: const [
                  DataColumn2(
                    label: Text('Numéro BL', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Articles', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Quantité', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
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
                rows: deliveries.map((delivery) {
                  return DataRow2(
                    cells: [
                      DataCell(
                        Text(
                          delivery.blNumber,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(
                        Text(DateFormat('dd/MM/yyyy').format(delivery.dateLivraison)),
                      ),
                      DataCell(
                        Text(delivery.clientName),
                      ),
                      DataCell(
                        Text(delivery.totalArticles.toString()),
                      ),
                      DataCell(
                        Text(delivery.totalQuantity.toString()),
                      ),
                      DataCell(
                        Text(
                          '${delivery.totalPieces} pcs',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      DataCell(
                        _buildStatusChip(delivery.status),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showDeliveryDialog(context, delivery: delivery),
                              icon: Icon(Icons.edit, color: AppColors.primary, size: 20),
                              tooltip: 'Modifier',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                            IconButton(
                              onPressed: () => _toggleDeliveryStatus(delivery),
                              icon: Icon(
                                delivery.isDelivered ? Icons.undo : Icons.check,
                                color: delivery.isDelivered ? AppColors.warning : AppColors.success,
                                size: 20,
                              ),
                              tooltip: delivery.isDelivered ? 'Marquer en attente' : 'Marquer livré',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                            IconButton(
                              onPressed: () => _deleteDelivery(context, delivery),
                              icon: Icon(Icons.delete, color: AppColors.error, size: 20),
                              tooltip: 'Supprimer',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                            IconButton(
                              onPressed: () => _printDelivery(delivery),
                              icon: Icon(Icons.print, color: AppColors.info, size: 20),
                              tooltip: 'Imprimer',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'en_attente':
        color = AppColors.warning;
        label = 'En attente';
        break;
      case 'livre':
        color = AppColors.success;
        label = 'Livré';
        break;
      case 'annule':
        color = AppColors.error;
        label = 'Annulé';
        break;
      default:
        color = AppColors.textSecondary;
        label = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDeliveryDialog(BuildContext context, {BonLivraison? delivery}) {
    showDialog(
      context: context,
      builder: (context) => BonLivraisonFormDialog(delivery: delivery),
    );
  }

  void _toggleDeliveryStatus(BonLivraison delivery) async {
    try {
      final newStatus = delivery.isDelivered ? 'en_attente' : 'livre';
      await ref.read(bonLivraisonListProvider.notifier).updateDeliveryStatus(delivery.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              delivery.isDelivered 
                ? 'Bon de livraison marqué en attente' 
                : 'Bon de livraison marqué comme livré'
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

  void _deleteDelivery(BuildContext context, BonLivraison delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer le bon de livraison ${delivery.blNumber} ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(bonLivraisonListProvider.notifier).deleteDelivery(delivery.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bon de livraison supprimé avec succès'),
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

  void _printDelivery(BonLivraison delivery) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate PDF
      final pdfService = PdfBLService();
      final file = await pdfService.generateBLPdf(delivery);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message with options
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 8),
                Text('PDF Généré'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Le bon de livraison ${delivery.blNumber} a été généré avec succès.'),
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
                    // Open PDF with default viewer on Windows
                    await Process.run('start', ['', file.path], runInShell: true);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l\'ouverture du PDF: $e'),
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
      // Close loading dialog if open
      if (mounted) Navigator.of(context).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _exportDeliveries() async {
    final deliveries = ref.read(bonLivraisonListProvider);
    
    if (deliveries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune livraison à exporter'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final excelService = ExcelExportService();
      final file = await excelService.exportDeliveries(deliveries);

      if (mounted) Navigator.of(context).pop();

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
                Text('${deliveries.length} livraisons exportées avec succès.'),
                const SizedBox(height: 12),
                Text(
                  'Fichier: ${file.path.split('\\').last}',
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
                  await Process.run('start', ['', file.path], runInShell: true);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ouvrir'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
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

  void _clearFilters() {
    _searchController.clear();
    ref.read(bonLivraisonSearchQueryProvider.notifier).clear();
    ref.read(bonLivraisonClientFilterProvider.notifier).clear();
    ref.read(bonLivraisonStatusFilterProvider.notifier).clear();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/excel_export_service.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/client_model.dart';
import '../../application/client_providers.dart';
import '../widgets/client_form_dialog.dart';

class ClientScreen extends ConsumerStatefulWidget {
  const ClientScreen({super.key});

  @override
  ConsumerState<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends ConsumerState<ClientScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final clients = ref.watch(clientListProvider);
    final searchQuery = ref.watch(clientSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: responsive.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            _buildHeader(context),
            SizedBox(height: responsive.spacing),

            // Search and filters
            _buildSearchAndFilters(context),
            SizedBox(height: responsive.spacing),

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
                      Row(
                        children: [
                          Text(
                            'Liste des clients',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${clients.length} client(s)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Data table
                      Expanded(
                        child: _buildDataTable(context, clients),
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
    final responsive = context.responsive;

    if (responsive.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                size: responsive.iconSize + 8,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gestion des Clients',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: responsive.headerFontSize,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showClientDialog(context),
                  icon: Icon(Icons.add, size: responsive.iconSize),
                  label: const Text(AppStrings.add),
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
                  onPressed: _exportClients,
                  icon: Icon(Icons.download, size: responsive.iconSize),
                  label: const Text(AppStrings.export),
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
          Icons.people,
          size: responsive.iconSize + 8,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Text(
          'Gestion des Clients',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: responsive.headerFontSize,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showClientDialog(context),
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
          onPressed: _exportClients,
          icon: Icon(Icons.download, size: responsive.iconSize),
          label: const Text(AppStrings.export),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, responsive.buttonHeight),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isMobile) {
      return Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom, matricule fiscal, téléphone...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(clientSearchQueryProvider.notifier).clear();
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
              ref.read(clientSearchQueryProvider.notifier).updateQuery(value);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement filters
              },
              icon: Icon(Icons.filter_list, size: responsive.iconSize),
              label: const Text(AppStrings.filter),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, responsive.buttonHeight),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom, matricule fiscal, téléphone...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(clientSearchQueryProvider.notifier).clear();
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
              ref.read(clientSearchQueryProvider.notifier).updateQuery(value);
            },
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement filters
          },
          icon: Icon(Icons.filter_list, size: responsive.iconSize),
          label: const Text(AppStrings.filter),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, responsive.buttonHeight),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context, List<Client> clients) {
    if (clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun client trouvé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cliquez sur "Ajouter" pour créer votre premier client',
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
      minWidth: 800,
      dataRowHeight: null,
      headingRowColor: MaterialStateProperty.all(AppColors.tableHeader),
      dataRowColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withOpacity(0.1);
        }
        return null;
      }),
      columns: const [
        DataColumn2(
          label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Matricule Fiscal', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Téléphone', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Date création', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
          fixedWidth: 120,
        ),
      ],
      rows: clients.map((client) {
        return DataRow2(
          cells: [
            DataCell(
              SizedBox(
                height: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      client.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            DataCell(Text(client.matriculeFiscal)),
            DataCell(Text(client.phone)),
            DataCell(Text(client.email)),
            DataCell(
              Text(DateFormat('dd/MM/yyyy').format(client.createdAt)),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showClientDialog(context, client: client),
                    icon: Icon(Icons.edit, color: AppColors.primary),
                    tooltip: AppStrings.edit,
                    iconSize: 20,
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => _deleteClient(context, client),
                    icon: Icon(Icons.delete, color: AppColors.error),
                    tooltip: AppStrings.delete,
                    iconSize: 20,
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showClientDialog(BuildContext context, {Client? client}) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(client: client),
    );
  }

  void _deleteClient(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le client "${client.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(clientListProvider.notifier).deleteClient(client.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.clientDeleted),
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

  void _exportClients() async {
    final clients = ref.read(clientListProvider);
    
    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun client à exporter'),
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
      final file = await excelService.exportClients(clients);

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
                Text('${clients.length} clients exportés avec succès.'),
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
}
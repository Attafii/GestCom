import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/pdf_invoice_service.dart';
import '../../../client/application/client_providers.dart';
import '../../application/facturation_providers.dart';
import '../widgets/facturation_form_dialog.dart';
import '../../../../data/models/facturation_model.dart';
import '../../../../data/models/client_model.dart';

class FacturationScreen extends ConsumerStatefulWidget {
  const FacturationScreen({super.key});

  @override
  ConsumerState<FacturationScreen> createState() => _FacturationScreenState();
}

class _FacturationScreenState extends ConsumerState<FacturationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PdfInvoiceService _pdfService = PdfInvoiceService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = ref.watch(filteredInvoicesProvider);
    final statistics = ref.watch(facturationStatisticsProvider);
    final clients = ref.watch(clientListProvider);
    final selectedClient = ref.watch(selectedFacturationClientProvider);
    final selectedStatus = ref.watch(selectedFacturationStatusProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header with statistics
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 32,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Facturation',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showFacturationDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvelle facture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildStatisticsCards(statistics),
              ],
            ),
          ),

          // Filters and search
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    // Search
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher par numéro, BL ou commentaires...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          ref.read(facturationSearchQueryProvider.notifier)
                              .updateQuery(value);
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Client filter
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: selectedClient,
                        decoration: InputDecoration(
                          labelText: 'Filtrer par client',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tous les clients'),
                          ),
                          ...clients.map((client) => DropdownMenuItem<String?>(
                            value: client.id,
                            child: Text(client.name),
                          )),
                        ],
                        onChanged: (value) {
                          ref.read(selectedFacturationClientProvider.notifier)
                              .selectClient(value);
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Status filter
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String?>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tous'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'brouillon',
                            child: Text('Brouillon'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'valide',
                            child: Text('Validée'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'envoye',
                            child: Text('Envoyée'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'paye',
                            child: Text('Payée'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'annule',
                            child: Text('Annulée'),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(selectedFacturationStatusProvider.notifier)
                              .selectStatus(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Data table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.table_chart, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Factures (${filteredInvoices.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Table content
                    Expanded(
                      child: filteredInvoices.isEmpty
                          ? _buildEmptyState()
                          : _buildInvoicesTable(filteredInvoices, clients),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total factures',
            '${stats['totalInvoices'] ?? 0}',
            Icons.receipt_long,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'En attente',
            '${stats['pendingInvoices'] ?? 0}',
            Icons.hourglass_empty,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Payées',
            '${stats['paidInvoices'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Montant total',
            '${(stats['totalAmount'] ?? 0.0).toStringAsFixed(3)} DT',
            Icons.euro,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'BL en attente',
            '${stats['pendingBLs'] ?? 0}',
            Icons.local_shipping,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune facture trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur "Nouvelle facture" pour commencer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesTable(List<Facturation> invoices, List<Client> clients) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1000,
      columns: [
        DataColumn2(
          label: Text('N° Facture'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Date'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Client facturé'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Client livré'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('BL'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Montant'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('Statut'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.M,
        ),
      ],
      rows: invoices.map((invoice) {
        final clientFacture = clients.firstWhere(
          (c) => c.id == invoice.clientFactureId,
          orElse: () => Client(name: 'Client non trouvé', address: '', matriculeFiscal: '', phone: '', email: ''),
        );
        final clientSource = clients.firstWhere(
          (c) => c.id == invoice.clientSourceId,
          orElse: () => Client(name: 'Client non trouvé', address: '', matriculeFiscal: '', phone: '', email: ''),
        );

        return DataRow2(
          cells: [
            DataCell(
              Text(
                invoice.factureNumber,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(
              Text('${invoice.dateFacture.day}/${invoice.dateFacture.month}/${invoice.dateFacture.year}'),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    clientFacture.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (invoice.isThirdPartyBilling)
                    Text(
                      'Facturation à un tiers',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            DataCell(
              Text(clientSource.name),
            ),
            DataCell(
              Text(
                invoice.blReferences.length > 2
                    ? '${invoice.blReferences.take(2).join(', ')}...'
                    : invoice.blReferences.join(', '),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            DataCell(
              Text(
                '${invoice.totalAmount.toStringAsFixed(3)} DT',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(
              _buildStatusChip(invoice.status, invoice.statusText),
            ),
            DataCell(
              _buildActionButtons(invoice),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusChip(String status, String statusText) {
    Color color;
    switch (status) {
      case 'brouillon':
        color = Colors.orange;
        break;
      case 'valide':
        color = Colors.blue;
        break;
      case 'envoye':
        color = Colors.purple;
        break;
      case 'paye':
        color = Colors.green;
        break;
      case 'annule':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Colors.orange[700],
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Facturation invoice) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PDF button
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          onPressed: () => _generatePdf(invoice),
          tooltip: 'Générer PDF',
        ),
        
        // Edit button (only for draft invoices)
        if (invoice.isEditable)
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => _showFacturationDialog(invoice.id),
            tooltip: 'Modifier',
          ),
        
        // Mark as paid button (for validated/sent invoices)
        if (['valide', 'envoye'].contains(invoice.status))
          IconButton(
            icon: const Icon(Icons.payment, size: 18),
            onPressed: () => _markAsPaid(invoice),
            tooltip: 'Marquer comme payée',
          ),
        
        // Cancel button (for non-paid invoices)
        if (!invoice.isPaid && !invoice.isCancelled)
          IconButton(
            icon: const Icon(Icons.cancel, size: 18),
            onPressed: () => _cancelInvoice(invoice),
            tooltip: 'Annuler',
          ),
        
        // Delete button (only for draft invoices)
        if (invoice.isEditable)
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: () => _deleteInvoice(invoice),
            tooltip: 'Supprimer',
          ),
      ],
    );
  }

  void _showFacturationDialog([String? facturationId]) {
    showDialog(
      context: context,
      builder: (context) => FacturationFormDialog(facturationId: facturationId),
    );
  }

  void _generatePdf(Facturation invoice) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final file = await _pdfService.generateInvoicePdf(invoice);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF généré: ${file.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ouvrir',
              onPressed: () => _pdfService.openPdf(invoice.factureNumber),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markAsPaid(Facturation invoice) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: invoice.dateFacture,
      lastDate: DateTime.now(),
      helpText: 'Date de paiement',
    );

    if (date != null) {
      try {
        await ref.read(facturationCrudProvider.notifier)
            .markAsPaid(invoice.id, date);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Facture marquée comme payée'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _cancelInvoice(Facturation invoice) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Annuler la facture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Êtes-vous sûr de vouloir annuler la facture ${invoice.factureNumber} ?'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Raison de l\'annulation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (reason != null) {
      try {
        await ref.read(facturationCrudProvider.notifier)
            .cancelInvoice(invoice.id, reason);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Facture annulée'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteInvoice(Facturation invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la facture'),
        content: Text('Êtes-vous sûr de vouloir supprimer la facture ${invoice.factureNumber} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(facturationCrudProvider.notifier)
            .deleteInvoice(invoice.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Facture supprimée'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
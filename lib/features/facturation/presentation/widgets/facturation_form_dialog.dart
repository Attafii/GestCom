import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../client/application/client_providers.dart';
import '../../../livraison/application/bon_livraison_providers.dart';
import '../../application/facturation_providers.dart';
import '../../../../data/models/bon_livraison_model.dart';
import '../../../../data/models/client_model.dart';

class FacturationFormDialog extends ConsumerStatefulWidget {
  final String? facturationId;
  
  const FacturationFormDialog({
    super.key,
    this.facturationId,
  });

  @override
  ConsumerState<FacturationFormDialog> createState() => _FacturationFormDialogState();
}

class _FacturationFormDialogState extends ConsumerState<FacturationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentairesController = TextEditingController();
  
  String? _selectedClientFacture;
  String? _selectedClientSource;
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedBLs = {};

  @override
  void initState() {
    super.initState();
    
    // Load existing data if editing
    if (widget.facturationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingFacturation();
      });
    }
  }

  void _loadExistingFacturation() {
    final repository = ref.read(facturationRepositoryProvider);
    final facturation = repository.getInvoiceById(widget.facturationId!);
    
    if (facturation != null) {
      setState(() {
        _selectedClientFacture = facturation.clientFactureId;
        _selectedClientSource = facturation.clientSourceId;
        _selectedDate = facturation.dateFacture;
        _selectedBLs.addAll(facturation.blReferences);
        _commentairesController.text = facturation.commentaires ?? '';
      });
    }
  }

  @override
  void dispose() {
    _commentairesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientListProvider);
    final pendingBLs = ref.watch(pendingBLsForInvoicingProvider);
    final filteredBLs = _selectedClientSource != null
        ? pendingBLs.where((bl) => bl.clientId == _selectedClientSource).toList()
        : pendingBLs;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.facturationId != null ? 'Modifier la facture' : 'Nouvelle facture',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: Form fields
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildClientSelection(clients),
                          const SizedBox(height: 24),
                          _buildDateSelection(),
                          const SizedBox(height: 24),
                          _buildCommentairesField(),
                          const SizedBox(height: 24),
                          _buildSelectedBLsSummary(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 24),
                    
                    // Right column: BL selection
                    Expanded(
                      flex: 2,
                      child: _buildBLSelection(filteredBLs),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _canSave() ? _saveFacturation : null,
                  child: Text(widget.facturationId != null ? 'Modifier' : 'Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSelection(List<Client> clients) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clients',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Client facturé
            DropdownButtonFormField<String>(
              value: _selectedClientFacture,
              decoration: const InputDecoration(
                labelText: 'Client facturé *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: clients.map((client) {
                return DropdownMenuItem(
                  value: client.id,
                  child: Text(client.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClientFacture = value;
                  // If same as source, update source too
                  if (_selectedClientSource == null) {
                    _selectedClientSource = value;
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner le client facturé';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Client source (livré)
            DropdownButtonFormField<String>(
              value: _selectedClientSource,
              decoration: const InputDecoration(
                labelText: 'Client livré *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_shipping),
                helperText: 'Client qui a reçu la marchandise',
              ),
              items: clients.map((client) {
                return DropdownMenuItem(
                  value: client.id,
                  child: Text(client.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClientSource = value;
                  // Clear selected BLs when client changes
                  _selectedBLs.clear();
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner le client livré';
                }
                return null;
              },
            ),
            
            // Third-party billing indicator
            if (_selectedClientFacture != null && 
                _selectedClientSource != null && 
                _selectedClientFacture != _selectedClientSource) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Facturation à un tiers',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date de facturation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de facturation *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentairesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commentaires',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentairesController,
              decoration: const InputDecoration(
                labelText: 'Commentaires (optionnel)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedBLsSummary() {
    if (_selectedBLs.isEmpty) {
      return const SizedBox.shrink();
    }

    final repository = ref.read(facturationRepositoryProvider);
    final total = repository.calculateTotalFromBLs(_selectedBLs.toList());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('BL sélectionnés:'),
                Text(
                  '${_selectedBLs.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:'),
                Text(
                  '${total.toStringAsFixed(3)} DT',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBLSelection(List<BonLivraison> bls) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Bons de livraison disponibles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_selectedClientSource == null)
                  Text(
                    'Sélectionnez d\'abord le client livré',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_selectedClientSource != null) ...[
              if (bls.isEmpty)
                Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun BL en attente de facturation',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    columns: [
                      DataColumn2(
                        label: Text('Sélection'),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Text('N° BL'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Date'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Articles'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('Total'),
                        size: ColumnSize.M,
                        numeric: true,
                      ),
                    ],
                    rows: bls.map((bl) {
                      final isSelected = _selectedBLs.contains(bl.id);
                      
                      return DataRow2(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedBLs.add(bl.id);
                            } else {
                              _selectedBLs.remove(bl.id);
                            }
                          });
                        },
                        cells: [
                          DataCell(
                            Checkbox(
                              value: isSelected,
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedBLs.add(bl.id);
                                  } else {
                                    _selectedBLs.remove(bl.id);
                                  }
                                });
                              },
                            ),
                          ),
                          DataCell(
                            Text(
                              bl.blNumber,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          DataCell(
                            Text('${bl.dateLivraison.day}/${bl.dateLivraison.month}/${bl.dateLivraison.year}'),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: bl.articles.take(2).map((article) => 
                                Text(
                                  '${article.articleReference} (${article.quantityLivree})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ).toList()
                                ..addAll(bl.articles.length > 2 ? [
                                  Text(
                                    '... +${bl.articles.length - 2} autres',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ] : []),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${bl.totalPieces} pcs',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ] else
              Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sélectionnez d\'abord le client livré',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _canSave() {
    return _selectedClientFacture != null &&
           _selectedClientSource != null &&
           _selectedBLs.isNotEmpty;
  }

  void _saveFacturation() async {
    if (!_formKey.currentState!.validate() || !_canSave()) {
      return;
    }

    try {
      final formData = FacturationFormData(
        clientFactureId: _selectedClientFacture!,
        clientSourceId: _selectedClientSource!,
        dateFacture: _selectedDate,
        selectedBLs: _selectedBLs.toList(),
        commentaires: _commentairesController.text.trim().isEmpty 
            ? null 
            : _commentairesController.text.trim(),
      );

      if (widget.facturationId != null) {
        await ref.read(facturationCrudProvider.notifier)
            .updateInvoice(widget.facturationId!, formData);
      } else {
        await ref.read(facturationCrudProvider.notifier)
            .createInvoice(formData);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.facturationId != null 
                ? 'Facture modifiée avec succès' 
                : 'Facture créée avec succès'),
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
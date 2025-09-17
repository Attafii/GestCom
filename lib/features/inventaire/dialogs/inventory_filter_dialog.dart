import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/inventory_models.dart';
import '../providers/inventory_providers.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/treatment_model.dart';

class InventoryFilterDialog extends ConsumerStatefulWidget {
  const InventoryFilterDialog({super.key});

  @override
  ConsumerState<InventoryFilterDialog> createState() => _InventoryFilterDialogState();
}

class _InventoryFilterDialogState extends ConsumerState<InventoryFilterDialog> {
  String? selectedClientId;
  String? selectedTreatmentId;
  String? articleReference;
  bool? hasStock;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize with current filter values
    final currentFilter = ref.read(inventoryFilterProvider);
    if (currentFilter != null) {
      selectedClientId = currentFilter.clientId;
      selectedTreatmentId = currentFilter.treatmentId;
      articleReference = currentFilter.articleReference;
      hasStock = currentFilter.hasStock;
      fromDate = currentFilter.fromDate;
      toDate = currentFilter.toDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = Hive.box<Client>('clients').values.toList();
    final treatments = Hive.box<Treatment>('treatments').values.toList();

    return AlertDialog(
      title: const Text('Filtrer l\'inventaire'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Client filter
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Client',
                  border: OutlineInputBorder(),
                ),
                value: selectedClientId,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tous les clients'),
                  ),
                  ...clients.map((client) => DropdownMenuItem<String>(
                    value: client.id,
                    child: Text(client.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedClientId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Treatment filter
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Traitement',
                  border: OutlineInputBorder(),
                ),
                value: selectedTreatmentId,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tous les traitements'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'default',
                    child: Text('Standard (défaut)'),
                  ),
                  ...treatments.map((treatment) => DropdownMenuItem<String>(
                    value: treatment.id,
                    child: Text(treatment.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTreatmentId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Article reference filter
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Référence article',
                  hintText: 'Rechercher par référence...',
                  border: OutlineInputBorder(),
                ),
                initialValue: articleReference,
                onChanged: (value) {
                  articleReference = value.isEmpty ? null : value;
                },
              ),
              const SizedBox(height: 16),

              // Stock status filter
              DropdownButtonFormField<bool?>(
                decoration: const InputDecoration(
                  labelText: 'Statut stock',
                  border: OutlineInputBorder(),
                ),
                value: hasStock,
                items: const [
                  DropdownMenuItem<bool?>(
                    value: null,
                    child: Text('Tous'),
                  ),
                  DropdownMenuItem<bool?>(
                    value: true,
                    child: Text('En stock'),
                  ),
                  DropdownMenuItem<bool?>(
                    value: false,
                    child: Text('Rupture de stock'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    hasStock = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date range filters
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date début',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          fromDate != null
                              ? '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}'
                              : 'Sélectionner',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date fin',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          toDate != null
                              ? '${toDate!.day}/${toDate!.month}/${toDate!.year}'
                              : 'Sélectionner',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Clear date buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: fromDate != null ? () {
                        setState(() {
                          fromDate = null;
                        });
                      } : null,
                      child: const Text('Effacer début'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: toDate != null ? () {
                        setState(() {
                          toDate = null;
                        });
                      } : null,
                      child: const Text('Effacer fin'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Clear all filters
            ref.read(inventoryFilterProvider.notifier).state = null;
            Navigator.of(context).pop();
          },
          child: const Text('Effacer tout'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            // Apply filters
            final filter = InventoryFilter(
              clientId: selectedClientId,
              treatmentId: selectedTreatmentId,
              articleReference: articleReference,
              hasStock: hasStock,
              fromDate: fromDate,
              toDate: toDate,
            );
            
            // Only apply filter if at least one field is set
            if (selectedClientId != null ||
                selectedTreatmentId != null ||
                articleReference != null ||
                hasStock != null ||
                fromDate != null ||
                toDate != null) {
              ref.read(inventoryFilterProvider.notifier).state = filter;
            } else {
              ref.read(inventoryFilterProvider.notifier).state = null;
            }
            
            // Reset to first page
            ref.read(inventoryCurrentPageProvider.notifier).state = 0;
            
            Navigator.of(context).pop();
          },
          child: const Text('Appliquer'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate 
          ? (fromDate ?? DateTime.now())
          : (toDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          // Ensure fromDate is not after toDate
          if (toDate != null && picked.isAfter(toDate!)) {
            toDate = null;
          }
        } else {
          toDate = picked;
          // Ensure toDate is not before fromDate
          if (fromDate != null && picked.isBefore(fromDate!)) {
            fromDate = null;
          }
        }
      });
    }
  }
}
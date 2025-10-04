import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/services/currency_service.dart';

class CompanySettingsScreen extends ConsumerStatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  ConsumerState<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends ConsumerState<CompanySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conversionRateController = TextEditingController();
  String _selectedCurrency = 'EUR';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final currencyService = ref.read(currencyServiceProvider);
    _selectedCurrency = currencyService.getCurrentCurrency();
    _conversionRateController.text = currencyService.getConversionRate().toString();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currencyService = ref.read(currencyServiceProvider);
      final rate = double.parse(_conversionRateController.text);
      
      await currencyService.updateCurrency(_selectedCurrency, rate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres de devise enregistrés avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Refresh providers to update UI
        ref.invalidate(currencyServiceProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyInfo = ref.watch(currencyInfoProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de l\'entreprise'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Currency Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.euro, color: AppColors.primary, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Paramètres de devise',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configurez la devise utilisée pour l\'affichage des prix des traitements',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const Divider(height: 32),
                      
                      // Currency Selection
                      Text(
                        'Devise d\'affichage',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Euro (€)'),
                              subtitle: const Text('Devise par défaut'),
                              value: 'EUR',
                              groupValue: _selectedCurrency,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCurrency = value!;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Dinar Tunisien (DT)'),
                              subtitle: const Text('Avec conversion automatique'),
                              value: 'TND',
                              groupValue: _selectedCurrency,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCurrency = value!;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      
                      // Conversion Rate
                      if (_selectedCurrency == 'TND') ...[
                        const SizedBox(height: 24),
                        Text(
                          'Taux de conversion',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _conversionRateController,
                            decoration: const InputDecoration(
                              labelText: 'Taux EUR vers TND',
                              helperText: '1 € = ? DT',
                              prefixText: '1 € = ',
                              suffixText: ' DT',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Taux requis';
                              }
                              final rate = double.tryParse(value);
                              if (rate == null || rate <= 0) {
                                return 'Taux invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.info.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.info, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Les prix des traitements sont stockés en euros. '
                                  'Ce taux sera appliqué automatiquement pour l\'affichage en dinars.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Current Settings Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paramètres actuels',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Devise', currencyInfo['symbol']),
                            const SizedBox(height: 8),
                            _buildInfoRow('Décimales', '${currencyInfo['decimalPlaces']}'),
                            if (currencyInfo['currency'] == 'TND') ...[
                              const SizedBox(height: 8),
                              _buildInfoRow('Taux de conversion', '1 € = ${currencyInfo['conversionRate']} DT'),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveSettings,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Enregistrement...' : 'Enregistrer les paramètres'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _conversionRateController.dispose();
    super.dispose();
  }
}
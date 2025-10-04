import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/backup_providers.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/utils/responsive_utils.dart';

class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  bool _isCreatingBackup = false;
  bool _isRestoringBackup = false;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);
    final settings = ref.watch(backupSettingsProvider);
    final backupsAsync = ref.watch(availableBackupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: responsive.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, responsive),
            SizedBox(height: responsive.spacing),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Backup settings card
                    _buildBackupSettingsCard(context, responsive, settings),
                    SizedBox(height: responsive.spacing),

                    // Manual backup card
                    _buildManualBackupCard(context, responsive, settings),
                    SizedBox(height: responsive.spacing),

                    // Available backups card
                    _buildAvailableBackupsCard(context, responsive, backupsAsync),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ResponsiveUtils responsive) {
    return Row(
      children: [
        Icon(
          Icons.backup,
          size: responsive.iconSize + 8,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Text(
          'Sauvegarde et Restauration',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: responsive.headerFontSize,
              ),
        ),
      ],
    );
  }

  Widget _buildBackupSettingsCard(
    BuildContext context,
    ResponsiveUtils responsive,
    BackupSettings? settings,
  ) {
    if (settings == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres de sauvegarde automatique',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: responsive.subHeaderFontSize,
                  ),
            ),
            SizedBox(height: responsive.spacing),

            // Auto backup toggle
            SwitchListTile(
              title: const Text('Sauvegarde automatique'),
              subtitle: Text(
                settings.autoBackupEnabled
                    ? 'Les sauvegardes automatiques sont activées'
                    : 'Les sauvegardes automatiques sont désactivées',
                style: TextStyle(fontSize: responsive.bodyFontSize),
              ),
              value: settings.autoBackupEnabled,
              onChanged: (value) async {
                await ref.read(backupSettingsProvider.notifier).updateAutoBackupEnabled(value);
                
                // Restart backup service with new settings
                final backupService = ref.read(backupServiceProvider);
                if (value) {
                  await backupService.startAutomaticBackup(settings.backupIntervalHours);
                } else {
                  backupService.stopAutomaticBackup();
                }
              },
              activeColor: AppColors.primary,
            ),

            SizedBox(height: responsive.smallSpacing),

            // Backup interval selector
            ListTile(
              title: const Text('Fréquence de sauvegarde'),
              subtitle: Text(
                _getIntervalText(settings.backupIntervalHours),
                style: TextStyle(fontSize: responsive.bodyFontSize),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: responsive.iconSize),
              enabled: settings.autoBackupEnabled,
              onTap: settings.autoBackupEnabled
                  ? () => _showIntervalPicker(context, settings)
                  : null,
            ),

            SizedBox(height: responsive.smallSpacing),

            // Last backup time
            if (settings.lastBackupTime != null)
              ListTile(
                leading: Icon(Icons.schedule, color: AppColors.textSecondary),
                title: const Text('Dernière sauvegarde'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm:ss').format(settings.lastBackupTime!),
                  style: TextStyle(fontSize: responsive.bodyFontSize),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualBackupCard(
    BuildContext context,
    ResponsiveUtils responsive,
    BackupSettings? settings,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sauvegarde manuelle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: responsive.subHeaderFontSize,
                  ),
            ),
            SizedBox(height: responsive.smallSpacing),
            Text(
              'Créez une sauvegarde immédiate de toutes vos données.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: responsive.bodyFontSize,
              ),
            ),
            SizedBox(height: responsive.spacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCreatingBackup ? null : _createManualBackup,
                icon: _isCreatingBackup
                    ? SizedBox(
                        width: responsive.iconSize,
                        height: responsive.iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.save, size: responsive.iconSize),
                label: Text(_isCreatingBackup ? 'Création en cours...' : 'Créer une sauvegarde'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, responsive.buttonHeight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableBackupsCard(
    BuildContext context,
    ResponsiveUtils responsive,
    AsyncValue<List<BackupInfo>> backupsAsync,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sauvegardes disponibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: responsive.subHeaderFontSize,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.invalidate(availableBackupsProvider);
                  },
                  icon: Icon(Icons.refresh, size: responsive.iconSize),
                  tooltip: 'Rafraîchir',
                ),
              ],
            ),
            SizedBox(height: responsive.spacing),

            backupsAsync.when(
              data: (backups) {
                if (backups.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(responsive.spacing),
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: responsive.smallSpacing),
                          Text(
                            'Aucune sauvegarde disponible',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: responsive.bodyFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: backups.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final backup = backups[index];
                    return _buildBackupTile(context, responsive, backup);
                  },
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(responsive.spacing),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.all(responsive.spacing),
                  child: Text(
                    'Erreur: $error',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupTile(
    BuildContext context,
    ResponsiveUtils responsive,
    BackupInfo backup,
  ) {
    return ListTile(
      leading: Icon(
        Icons.folder_zip,
        color: AppColors.primary,
        size: responsive.iconSize + 8,
      ),
      title: Text(
        backup.fileName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: responsive.bodyFontSize,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Date: ${backup.formattedTimestamp}',
            style: TextStyle(fontSize: responsive.bodyFontSize - 1),
          ),
          Text(
            'Taille: ${backup.formattedSize} • ${backup.totalItems} éléments',
            style: TextStyle(fontSize: responsive.bodyFontSize - 1),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _isRestoringBackup
                ? null
                : () => _showRestoreConfirmation(context, backup),
            icon: Icon(Icons.restore, size: responsive.iconSize),
            tooltip: 'Restaurer',
            color: AppColors.success,
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, backup),
            icon: Icon(Icons.delete, size: responsive.iconSize),
            tooltip: 'Supprimer',
            color: AppColors.error,
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsive.smallSpacing,
        vertical: 8,
      ),
    );
  }

  String _getIntervalText(int hours) {
    if (hours == 1) return 'Toutes les heures';
    if (hours < 24) return 'Toutes les $hours heures';
    if (hours == 24) return 'Une fois par jour';
    final days = hours ~/ 24;
    return 'Tous les $days jours';
  }

  Future<void> _showIntervalPicker(BuildContext context, BackupSettings settings) async {
    final intervals = [
      {'hours': 1, 'label': 'Toutes les heures'},
      {'hours': 3, 'label': 'Toutes les 3 heures'},
      {'hours': 6, 'label': 'Toutes les 6 heures'},
      {'hours': 12, 'label': 'Toutes les 12 heures'},
      {'hours': 24, 'label': 'Une fois par jour'},
      {'hours': 48, 'label': 'Tous les 2 jours'},
      {'hours': 168, 'label': 'Une fois par semaine'},
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fréquence de sauvegarde'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) {
            final hours = interval['hours'] as int;
            final label = interval['label'] as String;
            return RadioListTile<int>(
              title: Text(label),
              value: hours,
              groupValue: settings.backupIntervalHours,
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(backupSettingsProvider.notifier).updateBackupInterval(value);
                  
                  // Restart backup service with new interval
                  final backupService = ref.read(backupServiceProvider);
                  await backupService.startAutomaticBackup(value);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _createManualBackup() async {
    setState(() => _isCreatingBackup = true);

    try {
      final backupService = ref.read(backupServiceProvider);
      final result = await backupService.createBackup();

      if (!mounted) return;

      if (result.success) {
        // Update last backup time
        await ref.read(backupSettingsProvider.notifier).updateLastBackupTime(DateTime.now());
        
        // Refresh backups list
        ref.invalidate(availableBackupsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sauvegarde créée avec succès: ${result.fileName}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de la sauvegarde: ${result.error}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBackup = false);
      }
    }
  }

  Future<void> _showRestoreConfirmation(BuildContext context, BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer la sauvegarde'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Êtes-vous sûr de vouloir restaurer cette sauvegarde ?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Fichier: ${backup.fileName}'),
            Text('Date: ${backup.formattedTimestamp}'),
            Text('Éléments: ${backup.totalItems}'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ ATTENTION: Cette action remplacera toutes vos données actuelles par celles de la sauvegarde. Cette opération est irréversible.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _restoreBackup(backup);
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    setState(() => _isRestoringBackup = true);

    try {
      final backupService = ref.read(backupServiceProvider);
      final result = await backupService.restoreBackup(backup.filePath);

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sauvegarde restaurée avec succès: ${result.restoredItems} éléments de ${result.restoredBoxes?.length} tables',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );

        // Show dialog to restart app
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Restauration réussie'),
            content: const Text(
              'La sauvegarde a été restaurée avec succès. Il est recommandé de redémarrer l\'application pour appliquer tous les changements.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // In a real app, you would restart the app here
                  // For now, just go back to home
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la restauration: ${result.error}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoringBackup = false);
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la sauvegarde'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette sauvegarde ?\n\n${backup.fileName}\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final backupService = ref.read(backupServiceProvider);
      final success = await backupService.deleteBackup(backup.filePath);

      if (mounted) {
        if (success) {
          ref.invalidate(availableBackupsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sauvegarde supprimée'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erreur lors de la suppression'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

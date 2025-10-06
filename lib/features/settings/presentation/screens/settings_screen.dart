import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import 'backup_settings_screen.dart';
import 'company_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paramètres',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Gérez les paramètres de l\'application',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Settings Cards
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildSettingsCard(
                    context: context,
                    icon: Icons.euro,
                    iconColor: const Color(0xFF6366F1),
                    title: 'Devise et conversion',
                    subtitle: 'Gérer la devise d\'affichage et les taux de conversion',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompanySettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context: context,
                    icon: Icons.backup,
                    iconColor: const Color(0xFF10B981),
                    title: 'Sauvegarde et restauration',
                    subtitle: 'Configurer les sauvegardes automatiques et manuelles',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BackupSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context: context,
                    icon: Icons.notifications,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Notifications',
                    subtitle: 'Gérer les préférences de notifications',
                    onTap: () {
                      // To be implemented
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en cours de développement'),
                        ),
                      );
                    },
                    isComingSoon: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context: context,
                    icon: Icons.language,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'Langue',
                    subtitle: 'Choisir la langue de l\'application',
                    onTap: () {
                      // To be implemented
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en cours de développement'),
                        ),
                      );
                    },
                    isComingSoon: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context: context,
                    icon: Icons.business,
                    iconColor: const Color(0xFFEC4899),
                    title: 'Informations de l\'entreprise',
                    subtitle: 'Gérer les coordonnées et informations légales',
                    onTap: () {
                      // To be implemented
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en cours de développement'),
                        ),
                      );
                    },
                    isComingSoon: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'Bientôt',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

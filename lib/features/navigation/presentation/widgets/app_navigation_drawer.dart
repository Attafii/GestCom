import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../home/presentation/screens/home_screen.dart';

class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({
    super.key,
    required this.isCollapsed,
    required this.isMobile,
  });

  final bool isCollapsed;
  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);
    final effectiveWidth = isCollapsed && !isMobile ? 72.0 : 280.0;

    return Container(
      width: effectiveWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: isCollapsed && !isMobile ? 72 : 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: isCollapsed && !isMobile
                ? const Center(
                    child: Icon(
                      Icons.business,
                      size: 36,
                      color: Colors.white,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.business,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.appName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppStrings.appDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 0,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  isSelected: selectedPage == 0,
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 1,
                  icon: Icons.people,
                  title: AppStrings.menuClients,
                  isSelected: selectedPage == 1,
                ),
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 2,
                  icon: Icons.inventory,
                  title: AppStrings.menuArticles,
                  isSelected: selectedPage == 2,
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 3,
                  icon: Icons.input,
                  title: AppStrings.menuReception,
                  isSelected: selectedPage == 3,
                ),
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 4,
                  icon: Icons.output,
                  title: AppStrings.menuLivraison,
                  isSelected: selectedPage == 4,
                ),
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 5,
                  icon: Icons.receipt,
                  title: AppStrings.menuFacturation,
                  isSelected: selectedPage == 5,
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 6,
                  icon: Icons.warehouse,
                  title: AppStrings.menuInventaire,
                  isSelected: selectedPage == 6,
                ),
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 7,
                  icon: Icons.payment,
                  title: AppStrings.menuEncaissements,
                  isSelected: selectedPage == 7,
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context: context,
                  ref: ref,
                  index: 8,
                  icon: Icons.settings,
                  title: AppStrings.menuParametres,
                  isSelected: selectedPage == 8,
                ),
              ],
            ),
          ),

          // Footer
          if (!isCollapsed || isMobile)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    final menuItem = Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: isCollapsed && !isMobile
          ? IconButton(
              icon: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              onPressed: () {
                ref.read(selectedPageProvider.notifier).state = index;
                if (isMobile && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              tooltip: title,
            )
          : ListTile(
              leading: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                ref.read(selectedPageProvider.notifier).state = index;
                if (isMobile && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
    );

    if (isCollapsed && !isMobile) {
      return Tooltip(
        message: title,
        child: menuItem,
      );
    }

    return menuItem;
  }
}
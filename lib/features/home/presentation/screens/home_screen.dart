import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../client/presentation/screens/client_screen.dart';
import '../../../articles/presentation/screens/article_screen.dart';
import '../../../reception/presentation/screens/reception_screen.dart';
import '../../../livraison/presentation/screens/livraison_screen.dart';
import '../../../facturation/presentation/screens/facturation_screen.dart';
import '../../../inventaire/screens/inventory_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../navigation/presentation/widgets/app_navigation_drawer.dart';

// Navigation provider
final selectedPageProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Drawer
          const AppNavigationDrawer(),
          
          // Vertical divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColors.divider,
          ),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // App bar
                Container(
                  height: 64,
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
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        _getPageTitle(selectedPage),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // User info or settings
                      IconButton(
                        onPressed: () {
                          // TODO: Implement settings
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        tooltip: 'Paramètres',
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                
                // Page content
                Expanded(
                  child: _buildPageContent(selectedPage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return AppStrings.menuClients;
      case 2:
        return AppStrings.menuArticles;
      case 3:
        return AppStrings.menuReception;
      case 4:
        return AppStrings.menuLivraison;
      case 5:
        return AppStrings.menuFacturation;
      case 6:
        return AppStrings.menuInventaire;
      case 7:
        return AppStrings.menuEncaissements;
      case 8:
        return AppStrings.menuParametres;
      default:
        return AppStrings.appName;
    }
  }

  Widget _buildPageContent(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ClientScreen();
      case 2:
        return const ArticleScreen();
      case 3:
        return const ReceptionScreen();
      case 4:
        return const LivraisonScreen();
      case 5:
        return const FacturationScreen();
      case 6:
        return const InventoryScreen();
      case 7:
        return const _PlaceholderPage(title: AppStrings.menuEncaissements);
      case 8:
        return const _PlaceholderPage(title: AppStrings.menuParametres);
      default:
        return const _PlaceholderPage(title: 'Page non trouvée');
    }
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette page est en cours de développement',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
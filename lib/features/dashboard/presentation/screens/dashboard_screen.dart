import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/client_model.dart';
import '../../../../data/models/bon_reception_model.dart';
import '../../../client/application/client_providers.dart';
import '../../../reception/application/bon_reception_providers.dart';
import '../../../articles/application/article_providers.dart';
import '../../application/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStats = ref.watch(dashboardStatisticsProvider);
    final recentActivitiesList = ref.watch(recentActivitiesProvider);
    final topClientsList = ref.watch(topClientsProvider);
    final trends = ref.watch(monthlyTrendsProvider);
    
    // Backward compatibility
    final clients = ref.watch(activeClientsProvider);
    final receptions = ref.watch(recentReceptionsProvider(days: 30));
    final articles = ref.watch(activeArticlesProvider);
    final receptionStats = ref.watch(receptionStatisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 32),

            // Statistics Cards Row
            _buildStatsCards(clients, receptions, articles, receptionStats),
            const SizedBox(height: 24),

            // Charts and Analytics Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Charts
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildPaymentStatusChart(receptionStats),
                      const SizedBox(height: 16),
                      _buildPaymentModeChart(receptionStats),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right Column - Sales Trend
                Expanded(
                  flex: 3,
                  child: _buildSalesTrendChart(receptions),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bottom Row - Tables
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Clients
                Expanded(
                  child: _buildTopClientsTable(clients, receptions),
                ),
                const SizedBox(width: 16),
                // Recent Receptions
                Expanded(
                  child: _buildRecentReceptionsTable(receptions, clients),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.dashboard,
          size: 32,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Text(
          'Tableau de bord',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          'Dernière mise à jour: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(
    List<Client> clients,
    List<BonReception> receptions,
    List articles,
    Map<String, dynamic> receptionStats,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(dashboardStatisticsProvider);
        final currencyService = ref.watch(currencyServiceProvider);
        final currencySymbol = ref.watch(currencySymbolProvider);
        
        final totalCA = stats['totalCA'] as double? ?? 0.0;
        final totalReceptionAmount = stats['totalReceptionAmount'] as double? ?? 0.0;
        final totalPaid = stats['totalPaid'] as double? ?? 0.0;
        final totalUnpaid = stats['totalUnpaid'] as double? ?? 0.0;
        final totalLivraisons = stats['totalLivraisons'] as int? ?? 0;
        final pendingLivraisons = stats['pendingLivraisons'] as int? ?? 0;
        
        // Calculate percentages
        final caPercentage = totalCA > 0 ? 100 : 0;
        final receptionPercentage = totalReceptionAmount > 0 ? 75 : 0;
        final paidPercentage = (totalPaid + totalUnpaid) > 0 
            ? ((totalPaid / (totalPaid + totalUnpaid)) * 100).toInt() 
            : 0;
        final unpaidPercentage = 100 - paidPercentage;
        final livraisonPercentage = totalLivraisons > 0 
            ? ((pendingLivraisons / totalLivraisons) * 100).toInt() 
            : 0;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'CA Factures',
                value: currencyService.formatPrice(totalCA),
                subtitle: '${stats['currentMonthFactures']} factures ce mois',
                icon: Icons.euro,
                color: const Color(0xFF6366F1),
                percentage: caPercentage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Réceptions',
                value: currencyService.formatPrice(totalReceptionAmount),
                subtitle: '${stats['currentMonthReceptions']} ce mois',
                icon: Icons.receipt,
                color: const Color(0xFF8B5CF6),
                percentage: receptionPercentage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Livraisons',
                value: '${totalLivraisons} BL',
                subtitle: '$pendingLivraisons en attente',
                icon: Icons.local_shipping,
                color: const Color(0xFFEC4899),
                percentage: livraisonPercentage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Payé',
                value: currencyService.formatPrice(totalPaid),
                subtitle: '${stats['paidFactures']} factures',
                icon: Icons.payments,
                color: const Color(0xFF10B981),
                percentage: paidPercentage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Impayé',
                value: currencyService.formatPrice(totalUnpaid),
                subtitle: '${stats['unpaidFactures']} factures',
                icon: Icons.money_off,
                color: const Color(0xFFF59E0B),
                percentage: unpaidPercentage,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChart(Map<String, dynamic> receptionStats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CA par état de paiement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: 0.81,
                      strokeWidth: 16,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '81%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      Text(
                        'Impayé',
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
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Espèce', 43, const Color(0xFF10B981)),
              _buildLegendItem('C.bancaire', 23, const Color(0xFF8B5CF6)),
              _buildLegendItem('Chèque', 33, const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeChart(Map<String, dynamic> receptionStats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CA par mode de paiement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  flex: 43,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 24,
                  child: Container(
                    color: const Color(0xFFEC4899),
                  ),
                ),
                Expanded(
                  flex: 33,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Espèce', 43, const Color(0xFF10B981)),
              _buildLegendItem('C.bancaire', 24, const Color(0xFFEC4899)),
              _buildLegendItem('Chèque', 33, const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int percentage, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSalesTrendChart(List<BonReception> receptions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendance de ventes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: _SalesTrendPainter(receptions),
              size: const Size(double.infinity, 280),
            ),
          ),
          const SizedBox(height: 16),
          // Month labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('janv', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('févr', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('mars', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('avr', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('mai', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('juin', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('juil', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('août', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('sept', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('oct', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('nov', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('déc', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopClientsTable(List<Client> clients, List<BonReception> receptions) {
    return Consumer(
      builder: (context, ref, child) {
        final currencyService = ref.watch(currencyServiceProvider);
        
        // Calculate client statistics
        final clientStats = <String, Map<String, dynamic>>{};
        for (final reception in receptions) {
          if (clientStats.containsKey(reception.clientId)) {
            clientStats[reception.clientId]!['amount'] += reception.totalAmount;
            clientStats[reception.clientId]!['count'] += 1;
          } else {
            clientStats[reception.clientId] = {
              'amount': reception.totalAmount,
              'count': 1,
            };
          }
        }

        // Sort clients by amount
        final sortedClientIds = clientStats.keys.toList()
          ..sort((a, b) => (clientStats[b]!['amount'] as double)
              .compareTo(clientStats[a]!['amount'] as double));

        final topClients = sortedClientIds.take(5).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top 5 clients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ...topClients.asMap().entries.map((entry) {
                final index = entry.key;
                final clientId = entry.value;
                final client = clients.firstWhere(
                  (c) => c.id == clientId,
                  orElse: () => Client(name: 'Client inconnu', address: '', matriculeFiscal: '', phone: '', email: ''),
                );
                final stats = clientStats[clientId]!;
                final amount = stats['amount'] as double;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getClientColor(index),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              currencyService.formatPrice(amount),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        amount > 10000 ? 'Impayé' : 'Payé',
                        style: TextStyle(
                          color: amount > 10000 ? Colors.red : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentReceptionsTable(List<BonReception> receptions, List<Client> clients) {
    return Consumer(
      builder: (context, ref, child) {
        final currencyService = ref.watch(currencyServiceProvider);
        final recentReceptions = receptions.take(4).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '4 dernières factures',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Table headers
              Row(
                children: [
                  const Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey))),
                  const Expanded(flex: 3, child: Text('Client', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey))),
                  const Expanded(flex: 2, child: Text('Montant HT', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey))),
                  const Expanded(flex: 1, child: Text('Etat', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey))),
                ],
              ),
              const Divider(),
              ...recentReceptions.map((reception) {
                final client = clients.firstWhere(
                  (c) => c.id == reception.clientId,
                  orElse: () => Client(name: 'Client inconnu', address: '', matriculeFiscal: '', phone: '', email: ''),
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(reception.dateReception),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          client.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyService.formatPrice(reception.totalAmount),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Reçu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Color _getClientColor(int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
    ];
    return colors[index % colors.length];
  }
}

class _SalesTrendPainter extends CustomPainter {
  final List<BonReception> receptions;

  _SalesTrendPainter(this.receptions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Generate mock data points for 12 months
    final dataPoints = [
      0.3, 0.4, 0.6, 0.4, 0.8, 0.5, 0.7, 0.6, 0.9, 0.7, 0.8, 0.9
    ];

    final path = Path();
    final fillPath = Path();
    
    final stepX = size.width / (dataPoints.length - 1);
    
    // Start fill path from bottom
    fillPath.moveTo(0, size.height);
    
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - dataPoints[i]);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Close fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    
    // Draw fill first
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw line
    canvas.drawPath(path, paint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - dataPoints[i]);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
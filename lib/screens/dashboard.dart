import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/visitor_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/state_views.dart';
import '../widgets/visitor_card.dart';
import 'visitor_details.dart';
import 'visitor_form.dart';
import 'visitor_list.dart';
import 'qr_scanner.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Desk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync Visitors',
            onPressed: () {
              context.read<VisitorProvider>().fetchVisitors();
            },
          ),
        ],
      ),
      body: Consumer<VisitorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.visitors.isEmpty) {
            return const LoadingView(message: 'Loading dashboard records...');
          }

          if (provider.error != null && provider.visitors.isEmpty) {
            return EmptyStateWidget(
              title: 'Network Error',
              message: provider.error,
              icon: Icons.wifi_off_rounded,
              actionLabel: 'Retry',
              onAction: () => provider.fetchVisitors(),
            );
          }

          final all = provider.visitors;

          return RefreshIndicator(
            onRefresh: () => provider.fetchVisitors(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Front Desk Header Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.domain_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visitor Desk Operations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Top 3 Stat Cards
                Row(
                  children: [
                    StatCard(
                      label: 'Total Today',
                      count: '${provider.totalVisitorsToday}',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 8),
                    StatCard(
                      label: 'Checked In',
                      count: '${provider.currentlyCheckedIn}',
                      icon: Icons.login_rounded,
                      color: const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 8),
                    StatCard(
                      label: 'Checked Out',
                      count: '${provider.checkedOutToday}',
                      icon: Icons.logout_rounded,
                      color: const Color(0xFFEA580C),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VisitorForm()),
                          );
                        },
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('REGISTER'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QrScanner()),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text('SCAN QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Visitors Header with "View All"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Visitors',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VisitorList()),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (all.isEmpty)
                  const EmptyStateWidget(
                    title: 'No Visitors Registered',
                    message: 'Register a new visitor to start monitoring visits.',
                    icon: Icons.person_off_outlined,
                  )
                else
                  ...all.take(5).map((visitor) {
                    return VisitorCard(
                      visitor: visitor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisitorDetails(visitor: visitor),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

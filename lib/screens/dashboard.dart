import 'package:flutter/material.dart';
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
          // Loading State
          if (provider.isLoading && provider.visitors.isEmpty) {
            return const LoadingView(message: 'Loading dashboard records...');
          }

          // Network Failure State with Retry Button
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
                const SizedBox(height: 4),

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

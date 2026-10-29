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
  final void Function(int tabIndex, String filter)? onNavigateTab;

  const Dashboard({super.key, this.onNavigateTab});

  void _goToVisitors(BuildContext context, String filter) {
    if (onNavigateTab != null) {
      onNavigateTab!(1, filter);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisitorList(initialFilter: filter),
        ),
      );
    }
  }

  void _goToScan(BuildContext context) {
    if (onNavigateTab != null) {
      onNavigateTab!(2, '');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const QrScanner(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visitor Desk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    StatCard(
                      label: 'Total Today',
                      count: '${provider.totalVisitorsToday}',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF0284C7),
                      onTap: () => _goToVisitors(context, 'Today Registered'),
                    ),
                    const SizedBox(width: 8),
                    StatCard(
                      label: 'Checked In',
                      count: '${provider.currentlyCheckedIn}',
                      icon: Icons.login_rounded,
                      color: const Color(0xFF16A34A),
                      onTap: () => _goToVisitors(context, 'Checked In'),
                    ),
                    const SizedBox(width: 8),
                    StatCard(
                      label: 'Checked Out',
                      count: '${provider.checkedOutToday}',
                      icon: Icons.logout_rounded,
                      color: const Color(0xFFEA580C),
                      onTap: () => _goToVisitors(context, 'Checked Out'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VisitorForm(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add_rounded, size: 20),
                          label: const Text(
                            'REGISTER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _goToScan(context),
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                          label: const Text(
                            'SCAN QR',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Visitors',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _goToVisitors(context, 'All'),
                      label: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF0284C7),
                      ),
                      icon: const Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (all.isEmpty)
                  const EmptyStateWidget(
                    title: 'No Visitors Registered',
                    message:
                        'Register a new visitor to start monitoring visits.',
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

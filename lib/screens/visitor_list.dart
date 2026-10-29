import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../widgets/state_views.dart';
import '../widgets/visitor_card.dart';
import 'visitor_details.dart';
import 'visitor_form.dart';

class VisitorList extends StatefulWidget {
  const VisitorList({super.key});

  @override
  State<VisitorList> createState() => _VisitorListState();
}

class _VisitorListState extends State<VisitorList> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(Visitor visitor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visitor'),
        content: Text('Are you sure you want to delete ${visitor.name}\'s pass?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<VisitorProvider>().deleteVisitor(visitor.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visitor deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<VisitorProvider>().fetchVisitors(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VisitorForm()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('New Visitor', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<VisitorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.visitors.isEmpty) {
            return const LoadingView(message: 'Fetching visitor directory...');
          }

          if (provider.error != null && provider.visitors.isEmpty) {
            return EmptyStateWidget(
              title: 'Failed to Load Records',
              message: provider.error,
              icon: Icons.cloud_off_rounded,
              actionLabel: 'Retry',
              onAction: () => provider.fetchVisitors(),
            );
          }

          // Search filtering by Name or Mobile
          final query = _searchCtrl.text.trim().toLowerCase();
          List<Visitor> list = provider.visitors.where((v) {
            final matchesName = v.name.toLowerCase().contains(query);
            final matchesPhone = v.mobile.contains(query);
            return matchesName || matchesPhone;
          }).toList();

          // Status filter
          if (_selectedFilter != 'All') {
            list = list.where((v) => v.status == _selectedFilter).toList();
          }

          return Column(
            children: [
              // Search Input Box
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name or mobile...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['All', 'Registered', 'Checked In', 'Checked Out'].map((status) {
                    final isSelected = _selectedFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedFilter = status);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Visitors List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchVisitors(),
                  child: list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 60),
                            EmptyStateWidget(
                              title: query.isNotEmpty || _selectedFilter != 'All'
                                  ? 'No Matching Visitors'
                                  : 'No Visitors Found',
                              message: query.isNotEmpty
                                  ? 'No visitor matched your search criteria.'
                                  : 'Registered visitors will appear here.',
                              icon: Icons.search_off_rounded,
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final visitor = list[index];
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
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VisitorForm(visitor: visitor),
                                  ),
                                );
                              },
                              onDelete: () => _confirmDelete(visitor),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

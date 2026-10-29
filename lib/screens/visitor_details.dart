import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../widgets/status_chip.dart';
import 'visitor_form.dart';

class VisitorDetails extends StatefulWidget {
  final Visitor visitor;
  const VisitorDetails({super.key, required this.visitor});

  @override
  State<VisitorDetails> createState() => _VisitorDetailsState();
}

class _VisitorDetailsState extends State<VisitorDetails> {
  late String _visitorId;
  late Visitor _visitor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _visitorId = widget.visitor.id;
    _visitor = widget.visitor;
  }

  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  void _handleStatusChange() async {
    setState(() => _isLoading = true);
    final provider = context.read<VisitorProvider>();

    try {
      if (_visitor.status == VisitorStatus.registered.label) {
        final updated = await provider.checkIn(_visitor);
        if (mounted) {
          setState(() => _visitor = updated);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_visitor.name} Checked In successfully!'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      } else if (_visitor.status == VisitorStatus.checkedIn.label) {
        final updated = await provider.checkOut(_visitor);
        if (mounted) {
          setState(() => _visitor = updated);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_visitor.name} Checked Out successfully!'),
              backgroundColor: const Color(0xFF475569),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visitor'),
        content: Text('Are you sure you want to delete ${_visitor.name}\'s pass?'),
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
                await context.read<VisitorProvider>().deleteVisitor(_visitor.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visitor deleted successfully')),
                  );
                  Navigator.pop(context);
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
    // Keep local view synced if provider updates
    final provider = context.watch<VisitorProvider>();
    final matched = provider.visitors.where((v) => v.id == _visitorId);
    if (matched.isNotEmpty) {
      _visitor = matched.first;
    }

    final isCheckedIn = _visitor.status == VisitorStatus.checkedIn.label;
    final isCheckedOut = _visitor.status == VisitorStatus.checkedOut.label;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Pass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Pass',
            onPressed: () async {
              final updated = await Navigator.push<Visitor>(
                context,
                MaterialPageRoute(
                  builder: (_) => VisitorForm(visitor: _visitor),
                ),
              );
              if (updated != null && mounted) {
                setState(() => _visitor = updated);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete Pass',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Digital Pass Card with QR Code
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _visitor.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_visitor.visitorType} • ${_visitor.project}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // QR Code
                  QrImageView(
                    data: _visitor.id,
                    version: QrVersions.auto,
                    size: 160.0,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pass ID: #${_visitor.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  StatusChip(status: _visitor.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Details & Timestamps Card
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Mobile'),
                  subtitle: Text(_visitor.mobile),
                ),
                if (_visitor.email != null && _visitor.email!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(_visitor.email!),
                  ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Purpose of Visit'),
                  subtitle: Text(_visitor.purpose),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.green),
                  title: const Text('Check-In Time'),
                  subtitle: Text(_formatTime(_visitor.checkInTime)),
                ),
                if (_visitor.checkOutTime != null)
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: const Text('Check-Out Time'),
                    subtitle: Text(_formatTime(_visitor.checkOutTime)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Gate Action Button
          if (!isCheckedOut)
            ElevatedButton(
              onPressed: _isLoading ? null : _handleStatusChange,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCheckedIn ? const Color(0xFF0F172A) : const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isCheckedIn ? 'CHECK OUT VISITOR' : 'CHECK IN VISITOR',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'VISIT COMPLETED',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

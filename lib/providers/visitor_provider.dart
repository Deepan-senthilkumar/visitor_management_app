import 'dart:collection';
import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../services/api_service.dart';

class VisitorProvider extends ChangeNotifier {
  final ApiService _api;

  VisitorProvider({ApiService? api}) : _api = api ?? ApiService();

  List<Visitor> _visitors = [];
  bool _isLoading = false;
  String? _error;

  // Unmodifiable view to prevent accidental direct list mutation
  UnmodifiableListView<Visitor> get visitors => UnmodifiableListView(_visitors);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 1. Fetch all visitors with newest first sorting
  Future<void> fetchVisitors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _api.getVisitors();
      // Sort newest registration first
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _visitors = items;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching visitors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Fetch single visitor by ID via API (Spec requirement for QR scan)
  Future<Visitor> getVisitorById(String id) async {
    final visitor = await _api.getVisitorById(id);
    _replaceOrInsert(visitor);
    return visitor;
  }

  // 3. Register visitor
  Future<Visitor> addVisitor(Visitor visitor) async {
    final created = await _api.addVisitor(visitor);
    _visitors.insert(0, created);
    notifyListeners();
    return created;
  }

  // 4. Update existing visitor
  Future<Visitor> updateVisitor(Visitor visitor) async {
    final updated = await _api.updateVisitor(visitor);
    _replaceOrInsert(updated);
    return updated;
  }

  // 5. Check-In with business rule guard
  Future<Visitor> checkIn(Visitor visitor) async {
    if (visitor.status != VisitorStatus.registered.label) {
      throw Exception('Visitor is already ${visitor.status}. Only "Registered" visitors can check in.');
    }

    final updated = visitor.copyWith(
      status: VisitorStatus.checkedIn.label,
      checkInTime: DateTime.now().toUtc().toIso8601String(),
    );

    final saved = await _api.updateVisitor(updated);
    _replaceOrInsert(saved);
    return saved;
  }

  // 6. Check-Out with business rule guard
  Future<Visitor> checkOut(Visitor visitor) async {
    if (visitor.status != VisitorStatus.checkedIn.label) {
      throw Exception('Visitor cannot check out without checking in first.');
    }

    final updated = visitor.copyWith(
      status: VisitorStatus.checkedOut.label,
      checkOutTime: DateTime.now().toUtc().toIso8601String(),
    );

    final saved = await _api.updateVisitor(updated);
    _replaceOrInsert(saved);
    return saved;
  }

  // 7. Delete visitor
  Future<void> deleteVisitor(String id) async {
    await _api.deleteVisitor(id);
    _visitors.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  void _replaceOrInsert(Visitor visitor) {
    final index = _visitors.indexWhere((v) => v.id == visitor.id);
    if (index != -1) {
      _visitors[index] = visitor;
    } else {
      _visitors.insert(0, visitor);
    }
    notifyListeners();
  }

  // --- Dynamic Dashboard Metrics ---
  bool _isToday(String? dateStr, DateTime today) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return dt.year == today.year &&
          dt.month == today.month &&
          dt.day == today.day;
    } catch (_) {
      return false;
    }
  }

  int get totalVisitorsToday {
    final now = DateTime.now();
    return _visitors.where((v) => _isToday(v.createdAt, now)).length;
  }

  int get currentlyCheckedIn {
    return _visitors.where((v) => v.status == VisitorStatus.checkedIn.label).length;
  }

  int get checkedOutToday {
    final now = DateTime.now();
    return _visitors.where((v) =>
        v.status == VisitorStatus.checkedOut.label &&
        v.checkOutTime != null &&
        _isToday(v.checkOutTime, now)).length;
  }
}

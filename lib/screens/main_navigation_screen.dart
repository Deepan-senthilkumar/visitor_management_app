import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'visitor_list.dart';
import 'qr_scanner.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String _visitorFilter = 'All';

  void _navigateToTab(int index, [String filter = 'All']) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _visitorFilter = filter;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      Dashboard(onNavigateTab: _navigateToTab),
      VisitorList(
        key: ValueKey(_visitorFilter),
        initialFilter: _visitorFilter,
      ),
      const QrScanner(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _navigateToTab(index),
        selectedItemColor: const Color(0xFF0284C7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Visitors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'admin_executive_dashboard.dart';
import 'admin_order_management.dart';
import 'admin_production_dashboard.dart';
import 'admin_more_menu.dart';
import '../sales_rep/order_flow/order_flow_screen.dart';

class AdminNavWrapper extends StatefulWidget {
  const AdminNavWrapper({super.key});

  @override
  State<AdminNavWrapper> createState() => _AdminNavWrapperState();
}

class _AdminNavWrapperState extends State<AdminNavWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminExecutiveDashboard(),
    AdminOrderManagement(),
    AdminProductionDashboard(),
    AdminMoreMenu(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderFlowScreen()),
          );
        },
        backgroundColor: const Color(0xFF0F2042),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view, 'Dashboard'),
              _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long, 'Orders'),
              const SizedBox(width: 40), // Spacer for FAB
              _buildNavItem(2, Icons.precision_manufacturing_outlined, Icons.precision_manufacturing, 'Production'),
              _buildNavItem(3, Icons.apps_outlined, Icons.apps, 'More'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

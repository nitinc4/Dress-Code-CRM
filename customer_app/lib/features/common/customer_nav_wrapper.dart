import 'package:flutter/material.dart';
import '../dashboard/customer_dashboard.dart';
import '../orders/customer_orders.dart';
import '../profile/customer_more_screen.dart';

class CustomerNavWrapper extends StatefulWidget {
  const CustomerNavWrapper({super.key});

  @override
  State<CustomerNavWrapper> createState() => _CustomerNavWrapperState();
}

class _CustomerNavWrapperState extends State<CustomerNavWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    final pages = [
      const CustomerDashboard(),
      const CustomerOrders(),
      const CustomerMoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: goldColor,
        unselectedItemColor: const Color(0xFF6B7280),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

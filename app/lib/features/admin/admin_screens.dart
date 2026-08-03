import 'package:flutter/material.dart';

// 1. Admin Dashboard
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

// 2. Customers
class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Customers Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

// 3. Employees
class AdminEmployeesScreen extends StatelessWidget {
  const AdminEmployeesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Employees Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

// 4. Orders
class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('All Orders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

// 5. Ongoing Work
class AdminOngoingWorkScreen extends StatelessWidget {
  const AdminOngoingWorkScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Ongoing Work', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

// 6. Product Catalogue
class AdminCatalogueScreen extends StatelessWidget {
  const AdminCatalogueScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Product Catalogue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

// 7. Inventory
class AdminInventoryScreen extends StatelessWidget {
  const AdminInventoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Warehouse Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

// 8. Settings
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('System Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

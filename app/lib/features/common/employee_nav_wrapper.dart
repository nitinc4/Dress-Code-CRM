import 'package:flutter/material.dart';
import '../employee/employee_dashboard.dart';
import '../employee/employee_attendance_screen.dart';
import '../employee/employee_tasks_screen.dart';
import '../employee/employee_more_screen.dart';
import '../sales_rep/sales_dashboard.dart';
import '../master/master_dashboard.dart';
import '../tailor/tailor_dashboard.dart';
import '../hand_worker/hand_worker_dashboard.dart';
import '../warehouse/warehouse_dashboard.dart';

class EmployeeNavWrapper extends StatefulWidget {
  final String role;
  const EmployeeNavWrapper({super.key, required this.role});

  @override
  State<EmployeeNavWrapper> createState() => _EmployeeNavWrapperState();
}

class _EmployeeNavWrapperState extends State<EmployeeNavWrapper> {
  int _currentIndex = 0;

  Widget _getRoleDashboard() {
    switch (widget.role) {
      case 'sales_rep':
        return const SalesDashboard();
      case 'master':
        return const MasterDashboard();
      case 'tailor':
        return const TailorDashboard();
      case 'hand_worker':
        return const HandWorkerDashboard();
      case 'warehouse_manager':
        return const WarehouseDashboard();
      default:
        return const EmployeeDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    final pages = [
      _getRoleDashboard(),
      const EmployeeAttendanceScreen(),
      const EmployeeTasksScreen(),
      const EmployeeMoreScreen(),
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
            icon: Icon(Icons.access_time_outlined),
            activeIcon: Icon(Icons.access_time),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tasks',
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

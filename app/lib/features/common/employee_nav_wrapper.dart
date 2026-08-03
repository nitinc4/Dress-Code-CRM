import 'package:flutter/material.dart';
import '../employee/employee_dashboard.dart';
import '../employee/employee_attendance_screen.dart';
import '../employee/employee_tasks_screen.dart';
import '../employee/employee_more_screen.dart';

class EmployeeNavWrapper extends StatefulWidget {
  final String role;
  const EmployeeNavWrapper({super.key, required this.role});

  @override
  State<EmployeeNavWrapper> createState() => _EmployeeNavWrapperState();
}

class _EmployeeNavWrapperState extends State<EmployeeNavWrapper> {
  int _currentIndex = 0;

  final pages = const [
    EmployeeDashboard(),
    EmployeeAttendanceScreen(),
    EmployeeTasksScreen(),
    EmployeeMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
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

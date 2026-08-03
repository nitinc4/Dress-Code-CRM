import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/attendance_service.dart';
import '../../core/services/order_service.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  String _userName = 'Employee';
  String _userRole = 'Staff';
  String _userId = '';
  bool _isCheckedIn = false;
  String _checkInTime = '--:--';
  int _myTasksCount = 0;
  int _pendingCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Employee';
      _userRole = prefs.getString('user_role') ?? 'Staff';
      _userId = prefs.getString('user_id') ?? '';
    });

    if (_userId.isNotEmpty) {
      // Live Attendance
      final attendanceList = await AttendanceService.getUserAttendance(_userId);
      if (attendanceList.isNotEmpty) {
        final today = DateTime.now().toIso8601String().split('T')[0];
        final todayLog = attendanceList.firstWhere(
          (item) => item['date'] == today,
          orElse: () => null,
        );
        if (todayLog != null && todayLog['status'] == 'Checked In') {
          final dt = DateTime.parse(todayLog['checkInTime']);
          _isCheckedIn = true;
          _checkInTime = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
        }
      }

      // Live Orders / Tasks
      final orders = await OrderService.getOrders();
      _myTasksCount = orders.length;
      _pendingCount = orders.where((o) => o['status'] == 'pending' || o['status'] == 'In Production').length;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: goldColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Hello, $_userName ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                            const Text('👋', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Role: ${_userRole.toUpperCase()}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: goldColor),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Attendance Live Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Attendance Status', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                              const SizedBox(height: 4),
                              Text(_isCheckedIn ? 'Checked In' : 'Not Checked In', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                              const SizedBox(height: 2),
                              Text(_isCheckedIn ? 'Time: $_checkInTime AM' : 'Tap Attendance tab to Check In', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _isCheckedIn ? const Color(0xFF16A34A) : Colors.redAccent)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isCheckedIn ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(_isCheckedIn ? Icons.check_circle : Icons.cancel, size: 16, color: _isCheckedIn ? const Color(0xFF16A34A) : Colors.redAccent),
                                const SizedBox(width: 6),
                                Text(_isCheckedIn ? 'Active' : 'Offline', style: TextStyle(color: _isCheckedIn ? const Color(0xFF16A34A) : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Live Metrics Grid
                const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: goldColor)))
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.45,
                        children: [
                          _buildMetricCard(context, 'Total Orders', '$_myTasksCount', Icons.assignment_outlined, goldColor),
                          _buildMetricCard(context, 'Pending Work', '$_pendingCount', Icons.pending_actions_outlined, Colors.orangeAccent),
                          _buildMetricCard(context, 'Announcements', '3', Icons.campaign_outlined, Colors.purpleAccent),
                          _buildMetricCard(context, 'Leave Balance', '12 Days', Icons.event_note_outlined, Colors.green),
                        ],
                      ),
                const SizedBox(height: 24),

                // Today's Schedule Card
                const Text('Today\'s Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: goldColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.precision_manufacturing_outlined, color: goldColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Assigned Shift: $_userRole', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            const SizedBox(height: 4),
                            const Text('Factory Floor | 09:00 AM - 06:00 PM', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

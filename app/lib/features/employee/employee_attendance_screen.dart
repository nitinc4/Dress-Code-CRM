import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/attendance_service.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  bool _isCheckedIn = false;
  String _checkInTime = "Not Checked In";
  String _userId = '';
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? '';

    if (_userId.isNotEmpty) {
      final history = await AttendanceService.getUserAttendance(_userId);
      _history = history;
      if (history.isNotEmpty) {
        final today = DateTime.now().toIso8601String().split('T')[0];
        final todayLog = history.firstWhere(
          (item) => item['date'] == today,
          orElse: () => null,
        );
        if (todayLog != null && todayLog['status'] == 'Checked In') {
          _isCheckedIn = true;
          final dt = DateTime.parse(todayLog['checkInTime']);
          _checkInTime = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
        } else {
          _isCheckedIn = false;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAttendance() async {
    if (_userId.isEmpty) return;

    setState(() => _isLoading = true);

    if (!_isCheckedIn) {
      final res = await AttendanceService.checkIn(_userId);
      if (res['success']) {
        await _loadAttendanceData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Checked in successfully!'), backgroundColor: Color(0xFF16A34A)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Check-in failed'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } else {
      final res = await AttendanceService.checkOut(_userId);
      if (res['success']) {
        await _loadAttendanceData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Checked out successfully!'), backgroundColor: Colors.redAccent),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Check-out failed'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    final now = DateTime.now();
    final dateStr = "${now.day} ${now.month}, ${now.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(dateStr, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 24),

                  // Circular Clock Gauge
                  Center(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: _isCheckedIn ? const Color(0xFF16A34A) : goldColor,
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isCheckedIn ? const Color(0xFF16A34A) : goldColor).withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _checkInTime,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: darkText),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isCheckedIn ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isCheckedIn ? 'Checked In' : 'Not Checked In',
                              style: TextStyle(
                                color: _isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            SizedBox(height: 2),
                            Text('Factory - Unit 1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText)),
                            Text('Bangalore, India', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 18, color: goldColor),
                            SizedBox(width: 4),
                            Text('Verified GPS', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Check In / Check Out Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _toggleAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCheckedIn ? Colors.redAccent : goldColor,
                        foregroundColor: _isCheckedIn ? Colors.white : darkText,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 1,
                      ),
                      child: Text(
                        _isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Attendance History Header
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Attendance History',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // History Items from Live Database
                  _history.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No attendance records found yet.', style: TextStyle(color: Color(0xFF6B7280))),
                        )
                      : Column(
                          children: _history.map((item) {
                            return _buildHistoryItem(
                              item['date'] ?? '',
                              item['status'] ?? '',
                              item['checkInTime'] != null ? DateTime.parse(item['checkInTime']).toString().split(' ')[1].substring(0, 5) : '',
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildHistoryItem(String date, String status, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF121212))),
          Text(status == 'Checked In' ? 'Checked In at $time' : status, style: TextStyle(color: status == 'Checked In' ? const Color(0xFF16A34A) : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

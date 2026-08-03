import 'package:flutter/material.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  bool _isCheckedIn = true;
  String _checkInTime = "09:15:30 AM";

  void _toggleAttendance() {
    setState(() {
      _isCheckedIn = !_isCheckedIn;
      if (_isCheckedIn) {
        final now = DateTime.now();
        _checkInTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} AM";
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCheckedIn ? 'Checked in successfully!' : 'Checked out successfully!'),
        backgroundColor: _isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(color: Color(0xFF0F2042), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('19 May 2026, Monday', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
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
                    color: _isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    width: 8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFDC2626)).withOpacity(0.15),
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
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F2042)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isCheckedIn ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isCheckedIn ? 'Checked In' : 'Checked Out',
                        style: TextStyle(
                          color: _isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
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
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Location', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      SizedBox(height: 2),
                      Text('Factory - Unit 1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                      Text('Bangalore, India', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map_outlined, size: 18, color: Color(0xFF2563EB)),
                    label: const Text('View on Map', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
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
                  backgroundColor: _isCheckedIn ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: Text(
                  _isCheckedIn ? 'Check Out' : 'Check In',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Attendance History Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Attendance History',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042)),
              ),
            ),
            const SizedBox(height: 12),

            // History Items
            _buildHistoryItem('18 May 2026', '09:10 AM - 06:05 PM', 'Present'),
            _buildHistoryItem('17 May 2026', '09:05 AM - 06:00 PM', 'Present'),
            _buildHistoryItem('16 May 2026', '09:15 AM - 06:10 PM', 'Present'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String timing, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
          Text(timing, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ],
      ),
    );
  }
}

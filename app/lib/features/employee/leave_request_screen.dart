import 'package:flutter/material.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String _leaveType = 'Casual Leave';
  final _fromDateController = TextEditingController(text: '22 May 2026');
  final _toDateController = TextEditingController(text: '23 May 2026');
  final _reasonController = TextEditingController(text: 'Family Function');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Leave Request', style: TextStyle(color: Color(0xFF0F2042), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Casual Leave Balance', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  Text('12 Days >', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form
            const Text('Leave Type', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _leaveType,
              decoration: const InputDecoration(fillColor: Colors.white, filled: true),
              items: const [
                DropdownMenuItem(value: 'Casual Leave', child: Text('Casual Leave')),
                DropdownMenuItem(value: 'Medical Leave', child: Text('Medical Leave')),
                DropdownMenuItem(value: 'Earned Leave', child: Text('Earned Leave')),
              ],
              onChanged: (val) => setState(() => _leaveType = val!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('From Date', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                      const SizedBox(height: 8),
                      TextField(controller: _fromDateController, decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today, size: 18))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('To Date', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                      const SizedBox(height: 8),
                      TextField(controller: _toDateController, decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today, size: 18))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('No. Days', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: const Text('2 Days', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
            ),
            const SizedBox(height: 16),

            const Text('Reason', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Enter reason for leave...'),
            ),
            const SizedBox(height: 16),

            const Text('Supporting Document (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('Choose File')),
                  const Text('No file chosen', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave request submitted!'), backgroundColor: Color(0xFF16A34A)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

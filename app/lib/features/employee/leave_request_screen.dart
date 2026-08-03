import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/leave_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String _leaveType = 'Casual Leave';
  final _fromDateController = TextEditingController(text: '2026-05-22');
  final _toDateController = TextEditingController(text: '2026-05-23');
  final _reasonController = TextEditingController(text: 'Family Event');
  bool _isSubmitting = false;

  Future<void> _submitLeaveRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to submit leave')));
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await LeaveService.applyLeave(
      userId: userId,
      leaveType: _leaveType,
      fromDate: _fromDateController.text,
      toDate: _toDateController.text,
      noOfDays: 2,
      reason: _reasonController.text,
    );

    setState(() => _isSubmitting = false);

    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted to live backend!'), backgroundColor: Color(0xFF16A34A)),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Submission failed'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Leave Request', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
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
                border: Border.all(color: goldColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Casual Leave Balance', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                  Text('12 Days Available', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form
            const Text('Leave Type', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _leaveType,
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
                      const Text('From Date', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                      const SizedBox(height: 8),
                      TextField(controller: _fromDateController, decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today, size: 18, color: goldColor))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('To Date', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                      const SizedBox(height: 8),
                      TextField(controller: _toDateController, decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today, size: 18, color: goldColor))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Reason', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Enter reason for leave...'),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLeaveRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: darkText,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: darkText, strokeWidth: 2))
                    : const Text('SUBMIT REQUEST', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

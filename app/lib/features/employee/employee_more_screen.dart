import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import 'leave_request_screen.dart';
import 'payslip_screen.dart';
import '../../core/services/auth_service.dart';
import '../auth/role_selection_screen.dart';

class EmployeeMoreScreen extends StatelessWidget {
  const EmployeeMoreScreen({super.key});

  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('More & Profile', style: TextStyle(color: Color(0xFF0F2042), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Card Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                    child: const Icon(Icons.person, size: 36, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Ramesh Kumar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                      SizedBox(height: 2),
                      Text('Stitching Operator', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text('Emp ID: EMP-1025', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Options List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildListTile(context, Icons.person_outline, 'Personal Information', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                  _buildListTile(context, Icons.account_balance_outlined, 'Bank Details', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                  _buildListTile(context, Icons.event_note_outlined, 'Leave Request', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveRequestScreen()));
                  }),
                  _buildListTile(context, Icons.receipt_long_outlined, 'Payslip & Salary Details', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PayslipScreen()));
                  }),
                  _buildListTile(context, Icons.folder_outlined, 'Documents', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documents module')));
                  }),
                  _buildListTile(context, Icons.campaign_outlined, 'Announcements', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No new announcements')));
                  }),
                  _buildListTile(context, Icons.help_outline, 'Helpdesk / Support', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support ticket system')));
                  }),
                  _buildListTile(context, Icons.logout, 'Log Out', () => _logout(context), isDestructive: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? const Color(0xFFDC2626) : const Color(0xFF2563EB)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? const Color(0xFFDC2626) : const Color(0xFF0F2042),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}

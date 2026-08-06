import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';

class CustomerMoreScreen extends StatefulWidget {
  const CustomerMoreScreen({super.key});

  @override
  State<CustomerMoreScreen> createState() => _CustomerMoreScreenState();
}

class _CustomerMoreScreenState extends State<CustomerMoreScreen> {
  String _userName = 'Customer';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Customer';
      _userId = prefs.getString('user_id') ?? '';
    });
  }

  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                    backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
                    child: const Icon(Icons.person, size: 36, color: Color(0xFFD4AF37)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                      const SizedBox(height: 2),
                      const Text('Valued Client', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text('Client ID: CID-${_userId.length > 4 ? _userId.substring(_userId.length - 4).toUpperCase() : '0000'}', style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
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
                    // Navigate to Profile
                  }),
                  _buildListTile(context, Icons.straighten_outlined, 'My Measurements', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Measurements Module')));
                  }),
                  _buildListTile(context, Icons.location_on_outlined, 'Addresses', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Addresses Module')));
                  }),
                  _buildListTile(context, Icons.payment_outlined, 'Payment Methods', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Methods Module')));
                  }),
                  _buildListTile(context, Icons.campaign_outlined, 'Offers & Promotions', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active promotions')));
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
      leading: Icon(icon, color: isDestructive ? const Color(0xFFDC2626) : const Color(0xFFD4AF37)),
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

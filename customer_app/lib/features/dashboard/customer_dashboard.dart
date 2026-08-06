import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String _userName = 'Customer';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Customer';
    });
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Welcome, $_userName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
                          const SizedBox(width: 4),
                          const Text('✨', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Your Bespoke Tailoring Experience', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: goldColor.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_outlined, color: goldColor),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2042), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0F2042).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New Collection is Here', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Explore premium fabrics and modern cuts tailored just for you.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: darkText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('EXPLORE NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildActionCard(Icons.add_shopping_cart, 'New Order', () {})),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionCard(Icons.straighten, 'Measurements', () {})),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionCard(Icons.support_agent, 'Support', () {})),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No recent orders.', style: TextStyle(color: Color(0xFF6B7280))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFD4AF37)),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF121212))),
          ],
        ),
      ),
    );
  }
}

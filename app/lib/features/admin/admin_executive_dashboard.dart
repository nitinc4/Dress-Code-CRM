import 'package:flutter/material.dart';

class AdminExecutiveDashboard extends StatelessWidget {
  const AdminExecutiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Text('Good Morning, Admin ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                          Text('👑', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text('19 May 2026, Monday', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0F2042)),
                        onPressed: () {},
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF0F2042),
                        child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Business Overview Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Business Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                  Text('View All', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal Scrollable Cards
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildOverviewItem('Total Orders', '1,248', Icons.shopping_bag_outlined, const Color(0xFF2563EB)),
                    _buildOverviewItem('In Production', '186', Icons.settings_applications_outlined, const Color(0xFFD97706)),
                    _buildOverviewItem('Pending Orders', '74', Icons.hourglass_empty_outlined, const Color(0xFFDC2626)),
                    _buildOverviewItem('Completed', '988', Icons.task_alt_outlined, const Color(0xFF16A34A)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Today's Highlights
              const Text('Today\'s Highlights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.5,
                children: [
                  _buildHighlightCard('Revenue Today', '₹12,45,000', Icons.payments_outlined, const Color(0xFF16A34A)),
                  _buildHighlightCard('In Production', '166', Icons.precision_manufacturing_outlined, const Color(0xFF2563EB)),
                  _buildHighlightCard('Pending Deliveries', '32', Icons.local_shipping_outlined, const Color(0xFFD97706)),
                  _buildHighlightCard('Low Stock Items', '28', Icons.warning_amber_outlined, const Color(0xFFDC2626)),
                ],
              ),
              const SizedBox(height: 24),

              // Performance Overview
              const Text('Performance Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildGaugeRow('Production Efficiency', '76.8%', 0.768, const Color(0xFF16A34A)),
                    const SizedBox(height: 16),
                    _buildGaugeRow('Employee Attendance', '87.6%', 0.876, const Color(0xFF2563EB)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activities
              const Text('Recent Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
              const SizedBox(height: 12),
              _buildActivityTile('New order #ORD-2026-0125 received', '23 min ago', Icons.shopping_cart_outlined),
              _buildActivityTile('Cutting department finished WO-1254', '1 hour ago', Icons.content_cut_outlined),
              _buildActivityTile('Material Request approved by Admin', '2 hours ago', Icons.check_circle_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String title, String count, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 22, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F2042))),
              const SizedBox(height: 2),
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGaugeRow(String label, String percentText, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F2042))),
            Text(percentText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile(String title, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF0F2042), fontWeight: FontWeight.w500))),
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

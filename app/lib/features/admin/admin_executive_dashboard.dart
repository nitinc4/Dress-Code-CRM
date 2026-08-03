import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';

class AdminExecutiveDashboard extends StatefulWidget {
  const AdminExecutiveDashboard({super.key});

  @override
  State<AdminExecutiveDashboard> createState() => _AdminExecutiveDashboardState();
}

class _AdminExecutiveDashboardState extends State<AdminExecutiveDashboard> {
  int _totalOrders = 0;
  int _inProduction = 0;
  int _pendingOrders = 0;
  int _completedOrders = 0;
  List<dynamic> _recentOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLiveMetrics();
  }

  Future<void> _fetchLiveMetrics() async {
    final orders = await OrderService.getOrders();
    if (mounted) {
      setState(() {
        _totalOrders = orders.length;
        _inProduction = orders.where((o) => o['status'] == 'In Production').length;
        _pendingOrders = orders.where((o) => o['status'] == 'pending').length;
        _completedOrders = orders.where((o) => o['status'] == 'completed').length;
        _recentOrders = orders.take(3).toList();
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
          onRefresh: _fetchLiveMetrics,
          color: goldColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                            Text('Good Morning, Admin ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
                            Text('👑', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Live Executive ERP Feed', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined, color: darkText),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Business Overview Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Business Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                    Text('Live Database', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Live Metric Cards
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: goldColor)))
                    : SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildOverviewItem('Total Orders', '$_totalOrders', Icons.shopping_bag_outlined, goldColor),
                            _buildOverviewItem('In Production', '$_inProduction', Icons.settings_applications_outlined, Colors.orangeAccent),
                            _buildOverviewItem('Pending Orders', '$_pendingOrders', Icons.hourglass_empty_outlined, Colors.redAccent),
                            _buildOverviewItem('Completed', '$_completedOrders', Icons.task_alt_outlined, const Color(0xFF16A34A)),
                          ],
                        ),
                      ),
                const SizedBox(height: 24),

                // Today's Highlights
                const Text('Today\'s Highlights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
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
                    _buildHighlightCard('In Production', '$_inProduction', Icons.precision_manufacturing_outlined, goldColor),
                    _buildHighlightCard('Pending Deliveries', '32', Icons.local_shipping_outlined, Colors.orangeAccent),
                    _buildHighlightCard('Low Stock Items', '28', Icons.warning_amber_outlined, Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 24),

                // Performance Overview
                const Text('Performance Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      _buildGaugeRow('Production Efficiency', '82.4%', 0.824, const Color(0xFF16A34A)),
                      const SizedBox(height: 16),
                      _buildGaugeRow('Employee Attendance', '91.2%', 0.912, goldColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Live Recent Activities
                const Text('Recent Live Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 12),
                _recentOrders.isEmpty
                    ? const Padding(padding: EdgeInsets.all(16), child: Text('No orders recorded in system yet.', style: TextStyle(color: Color(0xFF6B7280))))
                    : Column(
                        children: _recentOrders.map((o) {
                          return _buildActivityTile(
                            'Order for ${o['customerName'] ?? 'Customer'} (${o['status'] ?? 'pending'})',
                            'Just now',
                            Icons.shopping_cart_outlined,
                          );
                        }).toList(),
                      ),
              ],
            ),
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 22, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF121212))),
              const SizedBox(height: 2),
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
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
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF121212))),
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF121212), fontWeight: FontWeight.w500))),
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

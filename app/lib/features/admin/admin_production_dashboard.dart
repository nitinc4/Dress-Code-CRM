import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';

class AdminProductionDashboard extends StatefulWidget {
  const AdminProductionDashboard({super.key});

  @override
  State<AdminProductionDashboard> createState() => _AdminProductionDashboardState();
}

class _AdminProductionDashboardState extends State<AdminProductionDashboard> {
  int _totalOrders = 0;
  int _inProgress = 0;
  int _completed = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductionMetrics();
  }

  Future<void> _fetchProductionMetrics() async {
    final orders = await OrderService.getOrders();
    if (mounted) {
      setState(() {
        _totalOrders = orders.length;
        _inProgress = orders.where((o) => o['status'] == 'In Production' || o['status'] == 'pending').length;
        _completed = orders.where((o) => o['status'] == 'completed').length;
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
      appBar: AppBar(
        title: const Text('Production Dashboard', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : RefreshIndicator(
              onRefresh: _fetchProductionMetrics,
              color: goldColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Summary Cards
                    Row(
                      children: [
                        _buildSummaryTile('Total Orders', '$_totalOrders', goldColor),
                        const SizedBox(width: 10),
                        _buildSummaryTile('In Progress', '$_inProgress', Colors.orangeAccent),
                        const SizedBox(width: 10),
                        _buildSummaryTile('Completed', '$_completed', const Color(0xFF16A34A)),
                        const SizedBox(width: 10),
                        _buildSummaryTile('Delayed', '0', Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Production Efficiency
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Production Efficiency', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                          SizedBox(height: 4),
                          Text('88.4%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: darkText)),
                          SizedBox(height: 2),
                          Text('▲ +5.2% vs Yesterday', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Department Progress
                    const Text('Department Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
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
                          _buildDeptRow('Cutting', '85%', 0.85, goldColor),
                          const SizedBox(height: 14),
                          _buildDeptRow('Stitching', '62%', 0.62, Colors.orangeAccent),
                          const SizedBox(height: 14),
                          _buildDeptRow('Embroidery', '78%', 0.78, Colors.purpleAccent),
                          const SizedBox(height: 14),
                          _buildDeptRow('Finishing', '45%', 0.45, Colors.pinkAccent),
                          const SizedBox(height: 14),
                          _buildDeptRow('Quality Control (QC)', '90%', 0.90, const Color(0xFF16A34A)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryTile(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold), maxLines: 1),
            const SizedBox(height: 6),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptRow(String name, String percentText, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
            Text(percentText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
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
}

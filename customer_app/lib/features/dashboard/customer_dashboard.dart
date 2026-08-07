import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/customer_order_service.dart';
import 'package:intl/intl.dart';
import '../catalog/customer_catalog_screen.dart';
import '../profile/customer_measurements_screen.dart';
import '../support/customer_support_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String _userName = 'Customer';
  List<dynamic> _recentOrders = [];
  bool _isLoadingOrders = true;

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
    
    // Load recent orders
    final orders = await CustomerOrderService.getMyOrders();
    setState(() {
      _recentOrders = orders;
      _isLoadingOrders = false;
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
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerCatalogScreen()));
                      },
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
                  Expanded(child: _buildActionCard(Icons.add_shopping_cart, 'New Order', () {
                    _showNewOrderDialog(context);
                  })),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionCard(Icons.straighten, 'Measurements', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerMeasurementsScreen()));
                  })),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionCard(Icons.support_agent, 'Support', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSupportScreen()));
                  })),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 16),
              if (_isLoadingOrders)
                const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: goldColor)))
              else if (_recentOrders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No recent orders.', style: TextStyle(color: Color(0xFF6B7280))),
                  ),
                )
              else
                _buildRecentOrderCard(_recentOrders.first),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(Map<String, dynamic> order) {
    final date = order['createdAt'] != null ? DateTime.tryParse(order['createdAt']) : null;
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Unknown Date';
    final status = (order['status'] as String? ?? 'pending').replaceAll('_', ' ').toUpperCase();

    Color statusColor;
    if (status.contains('COMPLETED') || status.contains('DELIVERY')) statusColor = Colors.green;
    else if (status.contains('TRIAL')) statusColor = Colors.orange;
    else statusColor = const Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order['_id']?.toString().substring(18).toUpperCase() ?? '0000'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(order['garmentCategory'] ?? 'Bespoke Garment', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
          const SizedBox(height: 4),
          Text('Fabric: ${order['fabricDetails']?['name'] ?? 'Custom Fabric'}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Amount', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  Text('₹${(order['totalCost'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
                  if ((order['pricingBreakdown']?['advancePaymentAmount'] ?? 0) > 0) ...[
                    const SizedBox(height: 6),
                    const Text('Paid Amount', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    Text('₹${(order['pricingBreakdown']['advancePaymentAmount']).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                    const SizedBox(height: 6),
                    const Text('Balance Due', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    Text('₹${(order['pricingBreakdown']['remainingBalance'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ] else if (order['paymentStatus'] == 'pending') ...[
                    const SizedBox(height: 6),
                    const Text('Balance Due', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    Text('₹${(order['totalCost'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Order Date', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  Text(formattedDate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF121212))),
                ],
              )
            ],
          )
        ],
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

  void _showNewOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Store Visit'),
        content: const Text('Bespoke tailoring requires exact body measurements. Would you like to schedule a store visit to get started with a new garment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store visit requested! We will contact you shortly.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Request Callback', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

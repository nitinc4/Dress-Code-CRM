import 'package:flutter/material.dart';
import '../auth/role_selection_screen.dart';
import '../../core/services/auth_service.dart';
import 'order_flow/order_flow_screen.dart';

import '../../core/services/order_service.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  List<dynamic> _trialOrders = [];
  List<dynamic> _trial2Orders = [];
  List<dynamic> _deliveryOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final allOrders = await OrderService.getOrders();
    final trial = allOrders.where((o) => o['status'] == 'trial').toList();
    final trial2 = allOrders.where((o) => o['status'] == 'trial_2').toList();
    final delivery = allOrders.where((o) => o['status'] == 'delivery').toList();
    if (mounted) {
      setState(() {
        _trialOrders = trial;
        _trial2Orders = trial2;
        _deliveryOrders = delivery;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    final res = await OrderService.updateOrderStatus(orderId, status);
    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order status updated to ${status.replaceAll('_', ' ')}!'), backgroundColor: const Color(0xFF16A34A)));
        _fetchOrders();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _markCompleted(String orderId) async {
    final res = await OrderService.updateOrderStatus(orderId, 'completed');
    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Completed!'), backgroundColor: Color(0xFF16A34A)));
        _fetchOrders();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
      }
    }
  }

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
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Desk',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Overview & Actions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black87),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Action Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => const OrderFlowScreen(),
                      transitionsBuilder: (context, a1, a2, child) {
                        return SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(a1),
                          child: child,
                        );
                      },
                    ),
                  ).then((_) => _fetchOrders());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: goldColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 12),
                    Text('NEW ORDER'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Trial Queue
              if (_trialOrders.isNotEmpty) ...[
                const Text('Trial Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 12),
                ..._trialOrders.map((order) {
                  final orderId = order['_id']?.substring(0, 8) ?? 'Unknown';
                  final cName = order['customerName'] ?? 'Customer';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #$orderId - $cName (${order['garmentCategory'] ?? 'Garment'})', style: const TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _updateStatus(order['_id'], 'alterations'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                child: const Text('Alterations'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateStatus(order['_id'], 'trial_2'),
                                style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: darkText),
                                child: const Text('Approve Trial'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
              ],

              // Trial 2 Queue
              if (_trial2Orders.isNotEmpty) ...[
                const Text('Trial 2 Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 12),
                ..._trial2Orders.map((order) {
                  final orderId = order['_id']?.substring(0, 8) ?? 'Unknown';
                  final cName = order['customerName'] ?? 'Customer';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #$orderId - $cName (${order['garmentCategory'] ?? 'Garment'})', style: const TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(order['_id'], 'delivery'),
                            style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: darkText),
                            child: const Text('Ready for Delivery'),
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
              ],

              const Text('Ready for Delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: goldColor))
              else if (_deliveryOrders.isEmpty)
                const Center(child: Text('No orders ready for delivery.', style: TextStyle(color: Colors.black54)))
              else
                ..._deliveryOrders.map((order) {
                  final orderId = order['_id']?.substring(0, 8) ?? 'Unknown';
                  final cName = order['customerName'] ?? 'Customer';
                  final finalBill = order['pricingBreakdown']?['finalBill'] ?? 0.0;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag, color: goldColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order #$orderId - $cName (${order['garmentCategory'] ?? 'Garment'})', style: const TextStyle(fontWeight: FontWeight.bold, color: darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
                              Text('Balance: ₹$finalBill', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _markCompleted(order['_id']),
                          style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: darkText, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                          child: const Text('Deliver'),
                        )
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

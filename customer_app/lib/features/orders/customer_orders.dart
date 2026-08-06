import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/customer_order_service.dart';

class CustomerOrders extends StatefulWidget {
  const CustomerOrders({super.key});

  @override
  State<CustomerOrders> createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = CustomerOrderService.getMyOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = CustomerOrderService.getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: goldColor,
        onRefresh: _refreshOrders,
        child: FutureBuilder<List<dynamic>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: goldColor));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading orders', style: TextStyle(color: Colors.red)));
            }

            final orders = snapshot.data ?? [];
            if (orders.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: goldColor),
                        SizedBox(height: 16),
                        Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
                        SizedBox(height: 8),
                        Text('When you place an order, it will appear here.', style: TextStyle(color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
                final date = order['createdAt'] != null ? DateTime.tryParse(order['createdAt']) : null;
                final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Unknown Date';
                final status = (order['status'] as String? ?? 'pending').replaceAll('_', ' ').toUpperCase();
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order['_id']?.toString().substring(18).toUpperCase() ?? '0000'}', style: const TextStyle(fontWeight: FontWeight.bold, color: goldColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(order['garmentCategory'] ?? 'Bespoke Garment', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
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
                              Text('₹${(order['totalCost'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Order Date', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              Text(formattedDate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkText)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('COMPLETED') || status.contains('DELIVERY')) return Colors.green;
    if (status.contains('TRIAL')) return Colors.orange;
    return const Color(0xFF3B82F6);
  }
}

import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';

class EmployeeTasksScreen extends StatefulWidget {
  const EmployeeTasksScreen({super.key});

  @override
  State<EmployeeTasksScreen> createState() => _EmployeeTasksScreenState();
}

class _EmployeeTasksScreenState extends State<EmployeeTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final list = await OrderService.getOrders();
    if (mounted) {
      setState(() {
        _orders = list;
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
        title: const Text('Tasks & Work Orders', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: goldColor,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: goldColor,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Assigned Work (${_orders.length})'),
            const Tab(text: 'Completed Orders'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : TabBarView(
              controller: _tabController,
              children: [
                // Live Assigned Work List
                RefreshIndicator(
                  onRefresh: _fetchOrders,
                  color: goldColor,
                  child: _orders.isEmpty
                      ? const Center(child: Text('No active work orders assigned.', style: TextStyle(color: Color(0xFF6B7280))))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            final status = order['status'] ?? 'pending';
                            final customerName = order['customerName'] ?? order['customer']?['name'] ?? 'Walk-in Customer';
                            final totalCost = order['totalCost'] ?? order['totalAmount'] ?? 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.assignment, size: 18, color: goldColor),
                                          const SizedBox(width: 8),
                                          Text('ORDER-${index + 101}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                                        child: Text(status.toUpperCase(), style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                                  const SizedBox(height: 4),
                                  Text('Total Bill: \$$totalCost', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                  const SizedBox(height: 14),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Priority: Normal', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                      ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Order Status Updated'), backgroundColor: goldColor),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: goldColor,
                                          foregroundColor: darkText,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Update Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Completed Orders View
                const Center(child: Text('No completed work orders yet.', style: TextStyle(color: Color(0xFF6B7280)))),
              ],
            ),
    );
  }
}

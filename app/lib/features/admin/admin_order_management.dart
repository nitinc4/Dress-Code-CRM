import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';

class AdminOrderManagement extends StatefulWidget {
  const AdminOrderManagement({super.key});

  @override
  State<AdminOrderManagement> createState() => _AdminOrderManagementState();
}

class _AdminOrderManagementState extends State<AdminOrderManagement> {
  String _selectedFilter = 'All Orders';
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

  void _showOrderTimelineModal(BuildContext context, Map<String, dynamic> order) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    final String orderId = order['_id'] != null ? "ORD-${order['_id'].toString().substring(0, 6).toUpperCase()}" : "ORD-NEW";
    final String customerName = order['customerName'] ?? order['customer']?['name'] ?? 'Walk-in Customer';
    final String status = order['status'] ?? 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orderId, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
                      Text('$customerName | Total: \$${order['totalCost'] ?? 0}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(14)),
                    child: Text(status.toUpperCase(), style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Priority: ${(order['priority'] ?? 'Normal').toString().toUpperCase()}', style: const TextStyle(fontSize: 12, color: darkText, fontWeight: FontWeight.bold)),
                  Text('Payment: ${(order['paymentStatus'] ?? 'pending').toString().toUpperCase()}', style: const TextStyle(fontSize: 12, color: goldColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),

              const Text('Production Stage Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildTimelineStep('Order Confirmed', 'System Logged', true, isFirst: true),
                    _buildTimelineStep('Measurement Recorded', 'Customer Specs Added', true),
                    _buildTimelineStep('Fabric Issued', order['fabricDetails']?['color'] ?? 'Standard Material', true),
                    _buildTimelineStep('Cutting Stage', 'Assigned to Master', status == 'In Production'),
                    _buildTimelineStep('Stitching Stage', 'Assigned to Tailor', status == 'In Production', isCurrent: status == 'In Production'),
                    _buildTimelineStep('Quality Control (QC)', 'Pending Inspection', status == 'completed'),
                    _buildTimelineStep('Trial Fitting', 'Pending Customer Trial', status == 'completed'),
                    _buildTimelineStep('Dispatch & Delivery', 'Pending Ready', status == 'completed', isLast: true),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order Management', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Filter pills
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'All Orders', 'New', 'In Production', 'Trial', 'QC', 'Completed'
                ].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      labelStyle: TextStyle(
                        color: isSelected ? darkText : const Color(0xFF6B7280),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      selectedColor: goldColor,
                      backgroundColor: const Color(0xFFFAFAFA),
                      onSelected: (val) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: goldColor))
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    color: goldColor,
                    child: _orders.isEmpty
                        ? const Center(child: Text('No orders found in database.', style: TextStyle(color: Color(0xFF6B7280))))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              final String orderId = order['_id'] != null ? "ORD-${order['_id'].toString().substring(0, 6).toUpperCase()}" : "ORD-${index + 100}";
                              final String client = order['customerName'] ?? order['customer']?['name'] ?? 'Walk-in Customer';
                              final String status = order['status'] ?? 'pending';
                              final String cost = "\$${order['totalCost'] ?? 0}";

                              return _buildOrderItem(context, order, orderId, client, 'Total Cost: $cost', status, goldColor);
                            },
                          ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Map<String, dynamic> orderData, String id, String client, String details, String status, Color goldColor) {
    return GestureDetector(
      onTap: () => _showOrderTimelineModal(context, orderData),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF121212))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                  child: Text(status.toUpperCase(), style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 6),
            Text(client, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
            const SizedBox(height: 2),
            Text(details, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isDone, {bool isCurrent = false, bool isFirst = false, bool isLast = false}) {
    const goldColor = Color(0xFFD4AF37);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? const Color(0xFF16A34A) : (isCurrent ? goldColor : const Color(0xFFCBD5E1)),
              ),
              child: Icon(
                isDone ? Icons.check : (isCurrent ? Icons.circle : Icons.circle_outlined),
                size: 12,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal, color: isCurrent ? goldColor : const Color(0xFF121212), fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }
}

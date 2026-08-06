import 'package:flutter/material.dart';
import '../../core/services/customer_order_service.dart';

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen> {
  bool _isLoading = true;
  double _totalPayments = 0.0;
  double _totalDues = 0.0;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentsAndDues();
  }

  Future<void> _fetchPaymentsAndDues() async {
    final orders = await CustomerOrderService.getMyOrders();
    double payments = 0.0;
    double dues = 0.0;

    for (var order in orders) {
      double orderTotal = (order['totalCost'] ?? 0).toDouble();
      double orderPaid = 0.0;
      
      if (order['pricingBreakdown'] != null) {
        var advance = order['pricingBreakdown']['advancePaymentAmount'];
        if (advance != null) {
          if (advance is String) {
            orderPaid = double.tryParse(advance) ?? 0.0;
          } else {
            orderPaid = advance.toDouble();
          }
        }
      }
      
      double orderDue = orderTotal - orderPaid;
      if (orderDue < 0) orderDue = 0; // prevent negative dues

      payments += orderPaid;
      dues += orderDue;
      
      // Store these locally for the list view
      order['_calculatedPaid'] = orderPaid;
      order['_calculatedDue'] = orderDue;
    }

    setState(() {
      _orders = orders;
      _totalPayments = payments;
      _totalDues = dues;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Payments & Dues', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
                        const SizedBox(height: 8),
                        const Text('An overview of your transactions and pending balances for your bespoke orders.', style: TextStyle(color: Color(0xFF6B7280))),
                        const SizedBox(height: 32),
                        
                        _buildSummaryCard('Total Paid', _totalPayments, Colors.green, Icons.check_circle_outline),
                        const SizedBox(height: 16),
                        _buildSummaryCard('Pending Dues', _totalDues, Colors.redAccent, Icons.pending_actions),
                        
                        const SizedBox(height: 32),
                        if (_totalDues > 0)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Gateway Integration Pending')));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: goldColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Pay Dues Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        const SizedBox(height: 32),
                        const Text('Order Balances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _orders.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text('No orders found.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final order = _orders[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: _buildOrderBalanceCard(order, goldColor, darkText),
                            );
                          },
                          childCount: _orders.length,
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
    );
  }

  Widget _buildOrderBalanceCard(Map<String, dynamic> order, Color goldColor, Color darkText) {
    double total = (order['totalCost'] ?? 0).toDouble();
    double paid = order['_calculatedPaid'] ?? 0.0;
    double due = order['_calculatedDue'] ?? 0.0;
    bool isCleared = due <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order['_id']?.toString().substring(18).toUpperCase() ?? '0000'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF121212))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCleared ? Colors.green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCleared ? 'CLEARED' : 'PENDING',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCleared ? Colors.green : Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
              Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paid:', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
              Text('₹${paid.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Balance Due:', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold)),
              Text('₹${due.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: due > 0 ? Colors.redAccent : darkText)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
            ],
          )
        ],
      ),
    );
  }
}

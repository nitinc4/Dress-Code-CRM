import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';

class HandWorkerDashboard extends StatefulWidget {
  const HandWorkerDashboard({super.key});

  @override
  State<HandWorkerDashboard> createState() => _HandWorkerDashboardState();
}

class _HandWorkerDashboardState extends State<HandWorkerDashboard> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHandworkOrders();
  }

  Future<void> _fetchHandworkOrders() async {
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchHandworkOrders,
          color: goldColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hand-worker Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Hand-worker Desk ✨', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
                        SizedBox(height: 4),
                        Text('Embroidery, Beadwork & Crafting', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: goldColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.handyman, color: goldColor),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Assigned Handwork Orders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Assigned Handwork (${_orders.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                    const Text('Design Specs', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: goldColor)))
                    : _orders.isEmpty
                        ? const Center(child: Text('No handwork tasks assigned currently.', style: TextStyle(color: Color(0xFF6B7280))))
                        : Column(
                            children: _orders.map((order) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(order['customerName'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                                          child: Text((order['priority'] ?? 'Normal').toString().toUpperCase(), style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 11)),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Handwork specs box
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('REQUIRED HANDWORK & LOCATION:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: goldColor)),
                                          const SizedBox(height: 4),
                                          Text(order['design'] ?? order['addons'] ?? 'Custom Embroidery on Neck & Sleeves', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Handwork Marked as Completed!'), backgroundColor: Color(0xFF16A34A)),
                                          );
                                        },
                                        icon: const Icon(Icons.check_circle_outline, size: 18),
                                        label: const Text('MARK HANDWORK COMPLETED'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF16A34A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

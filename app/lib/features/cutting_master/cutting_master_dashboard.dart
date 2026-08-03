import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/order_service.dart';

class CuttingMasterDashboard extends StatefulWidget {
  const CuttingMasterDashboard({super.key});

  @override
  State<CuttingMasterDashboard> createState() => _CuttingMasterDashboardState();
}

class _CuttingMasterDashboardState extends State<CuttingMasterDashboard> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _fetchAssignedWork();
  }

  Future<void> _fetchAssignedWork() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? '';

    final list = await OrderService.getOrders();
    // Filter to cutting status AND assigned to this exact cutting master
    final myOrders = list.where((o) => 
      o['status'] == 'cutting' && 
      o['assignedCuttingMaster'] != null && 
      o['assignedCuttingMaster']['_id'] == _userId
    ).toList();

    if (mounted) {
      setState(() {
        _orders = myOrders;
        _isLoading = false;
      });
    }
  }

  Future<void> _markCompleted(String orderId) async {
    // Advance from cutting to hand_work
    final res = await OrderService.updateOrderStatus(orderId, 'hand_work');
    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Completed! Order sent to Hand-work.'), backgroundColor: Color(0xFF16A34A)));
        _fetchAssignedWork();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
      }
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
          onRefresh: _fetchAssignedWork,
          color: goldColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Cutting Master ✂️', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
                        SizedBox(height: 4),
                        Text('Fabric Cutting & Patterning', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: goldColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.content_cut, color: goldColor),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Assigned Orders (${_orders.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                    const Text('Live Specs', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: goldColor)))
                    : _orders.isEmpty
                        ? const Center(child: Text('No cutting orders assigned right now.', style: TextStyle(color: Color(0xFF6B7280))))
                        : Column(
                            children: _orders.map((order) {
                              final measurements = order['measurements'] as Map<String, dynamic>? ?? {};

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
                                        Expanded(
                                          child: Text(
                                            'Order #${order['_id']?.substring(0,6)} - ${order['customerName']} (${order['garmentCategory'] ?? 'Garment'})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                                          child: Text((order['priority'] ?? 'Normal').toString().toUpperCase(), style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 11)),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Fabric: ${order['fabricDetails']?['color'] ?? 'Custom Material'} (${order['garmentCategory'] ?? 'Garment'})', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                                    const SizedBox(height: 12),

                                    // Measurements Box
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('MEASUREMENTS:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: goldColor)),
                                          const SizedBox(height: 4),
                                          Text('Shoulder: ${measurements['shoulder'] ?? 16}"  |  Chest: ${measurements['chest'] ?? 38}"  |  Length: ${measurements['length'] ?? 40}"', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _markCompleted(order['_id']),
                                        icon: const Icon(Icons.check_circle_outline, size: 18),
                                        label: const Text('MARK CUTTING COMPLETED'),
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

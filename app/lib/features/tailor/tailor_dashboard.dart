import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/order_service.dart';

class TailorDashboard extends StatefulWidget {
  const TailorDashboard({super.key});

  @override
  State<TailorDashboard> createState() => _TailorDashboardState();
}

class _TailorDashboardState extends State<TailorDashboard> {
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
    // Filter to stitching or alterations status AND assigned to this exact tailor
    final myOrders = list.where((o) => 
      (o['status'] == 'stitching' || o['status'] == 'alterations') && 
      o['assignedTailor'] != null && 
      o['assignedTailor']['_id'] == _userId
    ).toList();

    if (mounted) {
      setState(() {
        _orders = myOrders;
        _isLoading = false;
      });
    }
  }

  Future<void> _markCompleted(String orderId, String currentStatus) async {
    final nextStatus = currentStatus == 'stitching' ? 'trial' : 'trial_2';
    final res = await OrderService.updateOrderStatus(orderId, nextStatus);
    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked as Completed! Order sent to $nextStatus.'), backgroundColor: const Color(0xFF16A34A)));
        _fetchAssignedWork();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
      }
    }
  }

  void _showFabricRequestModal(BuildContext context, Map<String, dynamic> order) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);
    final textController = TextEditingController(text: 'Need 1.5 meters extra cotton fabric for alterations');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Extra Fabric from Warehouse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 8),
              Text('Order: ${order['customerName'] ?? 'Customer'}', style: const TextStyle(color: Color(0xFF6B7280))),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Fabric Details & Length Requested'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final res = await OrderService.requestFabric(order['_id'], textController.text.trim());
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    if (res['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fabric Request sent to Warehouse Manager!'), backgroundColor: Color(0xFF16A34A)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['message'] ?? 'Failed to send request'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: darkText),
                  child: const Text('SUBMIT REQUEST', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Text('Tailor Desk 🧵', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
                        SizedBox(height: 4),
                        Text('Stitching & Alteration Orders', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: goldColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.cut, color: goldColor),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Assigned Orders (${_orders.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  ],
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: goldColor)))
                    : _orders.isEmpty
                        ? const Center(child: Text('No stitching orders assigned right now.', style: TextStyle(color: Color(0xFF6B7280))))
                        : Column(
                            children: _orders.map((order) {
                              final measurements = order['measurements'] as Map<String, dynamic>? ?? {};
                              final status = order['status'] ?? 'pending';

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
                                    Text('Status: ${status.toUpperCase()}', style: const TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 4),
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

                                    // Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _showFabricRequestModal(context, order),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: darkText,
                                              side: const BorderSide(color: goldColor),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: const Text('Request Fabric', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _markCompleted(order['_id'], status),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF16A34A),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: const Text('Mark Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
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

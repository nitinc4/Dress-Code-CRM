import 'package:flutter/material.dart';
import '../../core/services/inventory_service.dart';
import '../../core/services/order_service.dart';

class WarehouseDashboard extends StatefulWidget {
  const WarehouseDashboard({super.key});

  @override
  State<WarehouseDashboard> createState() => _WarehouseDashboardState();
}

class _WarehouseDashboardState extends State<WarehouseDashboard> {
  List<dynamic> _inventory = [];
  List<dynamic> _dispensingOrders = [];
  List<dynamic> _extraRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final list = await InventoryService.getInventory();
    final allOrders = await OrderService.getOrders();
    final pendingFabric = allOrders.where((o) => o['status'] == 'fabric_dispensing').toList();
    final extraReqs = allOrders.where((o) => o['fabricRequest'] != null && o['fabricRequest'].toString().trim().isNotEmpty).toList();
    if (mounted) {
      setState(() {
        _inventory = list;
        _dispensingOrders = pendingFabric;
        _extraRequests = extraReqs;
        _isLoading = false;
      });
    }
  }

  Future<void> _dispenseFabric(String orderId) async {
    final res = await OrderService.updateOrderStatus(orderId, 'cutting');
    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fabric Dispensed! Order sent to Cutting.'), backgroundColor: Color(0xFF16A34A)));
        _fetchData();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _fulfillExtraRequest(String orderId) async {
    final res = await OrderService.requestFabric(orderId, '');
    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extra Fabric Request fulfilled!'), backgroundColor: Color(0xFF16A34A)));
        _fetchData();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed to fulfill'), backgroundColor: Colors.red));
      }
    }
  }

  void _showScanBarcodeModal(BuildContext context, String action) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_scanner, size: 60, color: goldColor),
              const SizedBox(height: 16),
              Text('Simulating Barcode Scan for $action', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 8),
              const Text('Scanning barcode CT-0526 (Cotton Fabric Roll)...', style: TextStyle(color: Color(0xFF6B7280))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Barcode Scanned & Stock updated for $action!'), backgroundColor: const Color(0xFF16A34A)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: darkText),
                  child: const Text('CONFIRM SCAN & UPDATE STOCK', style: TextStyle(fontWeight: FontWeight.bold)),
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
          onRefresh: _fetchData,
          color: goldColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warehouse Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Warehouse Manager 📦', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
                        SizedBox(height: 4),
                        Text('Inventory Stock & Barcode Dispensing', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: goldColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.warehouse, color: goldColor),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Barcode Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showScanBarcodeModal(context, 'Incoming Shipment'),
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text('Receive Stock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          foregroundColor: darkText,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showScanBarcodeModal(context, 'Fabric Dispense'),
                        icon: const Icon(Icons.cut, size: 18),
                        label: const Text('Dispense Fabric'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkText,
                          side: const BorderSide(color: goldColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fabric Dispensing Orders
                if (_dispensingOrders.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fabric Dispensing Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                      const SizedBox(height: 12),
                      ..._dispensingOrders.map((order) {
                        final orderId = order['_id']?.substring(0, 8) ?? 'Unknown';
                        final fabricName = order['fabricDetails']?['name'] ?? 'Fabric';
                        final meters = order['fabricDetails']?['meters'] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mark_chat_unread_outlined, color: Color(0xFFD97706)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Order #$orderId: Dispense $meters meters of $fabricName', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 13)),
                              ),
                              ElevatedButton(
                                onPressed: () => _dispenseFabric(order['_id']),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                child: const Text('Fulfill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Extra Fabric Requests from Tailors
                if (_extraRequests.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tailor Extra Fabric Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                      const SizedBox(height: 12),
                      ..._extraRequests.map((order) {
                        final orderId = order['_id']?.substring(0, 8) ?? 'Unknown';
                        final requestDetails = order['fabricRequest'] ?? 'Fabric Request';
                        final customerName = order['customerName'] ?? 'Customer';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2), // Soft red
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.assignment_late_outlined, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order #$orderId - $customerName', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(requestDetails, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _fulfillExtraRequest(order['_id']),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                child: const Text('Fulfill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Live Stock Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Inventory Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  ],
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: goldColor)))
                    : _inventory.isEmpty
                        ? const Center(child: Text('No inventory items in stock.', style: TextStyle(color: Color(0xFF6B7280))))
                        : Column(
                            children: _inventory.map((item) {
                              final name = item['name'] ?? 'Material Item';
                              final quantity = item['quantity'] ?? 0;
                              final unit = item['unit'] ?? 'Meters';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                                        const SizedBox(height: 2),
                                        Text('Unit: $unit', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                                      ],
                                    ),
                                    Text('$quantity $unit', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: goldColor)),
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

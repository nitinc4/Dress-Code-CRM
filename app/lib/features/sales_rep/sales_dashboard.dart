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
  List<dynamic> _allOrders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOption = 'Order Date (Newest)';

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
        _allOrders = allOrders;
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredAndSortedOrders {
    List<dynamic> filtered = _allOrders.where((order) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final name = (order['customerName'] ?? '').toString().toLowerCase();
      final phone = (order['customerPhone'] ?? '').toString().toLowerCase();
      final garment = (order['garmentCategory'] ?? '').toString().toLowerCase();
      final id = (order['_id'] ?? '').toString().toLowerCase();
      return name.contains(q) || phone.contains(q) || garment.contains(q) || id.contains(q);
    }).toList();

    filtered.sort((a, b) {
      if (_sortOption == 'Order Date (Newest)') {
        return (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString());
      } else if (_sortOption == 'Order Date (Oldest)') {
        return (a['createdAt'] ?? '').toString().compareTo((b['createdAt'] ?? '').toString());
      } else if (_sortOption == 'Event Date') {
        return (a['eventDate'] ?? '9999').toString().compareTo((b['eventDate'] ?? '9999').toString());
      } else if (_sortOption == 'Status (Pending First)') {
        // Let's sort by paymentStatus -> if not defined, check pricingBreakdown for dues
        final statusA = (a['paymentStatus'] ?? '').toString().toLowerCase();
        final statusB = (b['paymentStatus'] ?? '').toString().toLowerCase();
        if (statusA == 'pending' && statusB != 'pending') return -1;
        if (statusB == 'pending' && statusA != 'pending') return 1;
        return 0; 
      } else if (_sortOption == 'Client Name (A-Z)') {
        return (a['customerName'] ?? '').toString().toLowerCase().compareTo((b['customerName'] ?? '').toString().toLowerCase());
      }
      return 0;
    });
    
    return filtered;
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
              
              const SizedBox(height: 40),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 32),

              // Order History Section
              const Text('Order History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 16),
              
              // Search & Sort Controls
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name, phone, garment...',
                        prefixIcon: const Icon(Icons.search, color: goldColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: goldColor, width: 2)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortOption,
                          isExpanded: true,
                          icon: const Icon(Icons.sort, color: goldColor),
                          style: const TextStyle(fontSize: 13, color: darkText),
                          items: const [
                            DropdownMenuItem(value: 'Order Date (Newest)', child: Text('Newest')),
                            DropdownMenuItem(value: 'Order Date (Oldest)', child: Text('Oldest')),
                            DropdownMenuItem(value: 'Event Date', child: Text('Event Date')),
                            DropdownMenuItem(value: 'Status (Pending First)', child: Text('Pending First')),
                            DropdownMenuItem(value: 'Client Name (A-Z)', child: Text('Name A-Z')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _sortOption = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Order History List
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: goldColor))
              else if (_filteredAndSortedOrders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No orders found.', style: TextStyle(color: Colors.black54)),
                  ),
                )
              else
                ..._filteredAndSortedOrders.map((order) {
                  final orderId = order['_id']?.substring(0, 8) ?? 'Unknown';
                  final cName = order['customerName'] ?? 'Customer';
                  final cPhone = order['customerPhone'] ?? 'N/A';
                  final garment = order['garmentCategory'] ?? 'Garment';
                  final statusRaw = order['status'] ?? 'unknown';
                  final paymentStatus = (order['paymentStatus'] ?? 'pending').toString().toUpperCase();
                  
                  final dateStr = order['createdAt'] ?? '';
                  final date = dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
                  
                  final eventStr = order['eventDate'] ?? '';
                  final eventDate = eventStr.length >= 10 ? eventStr.substring(0, 10) : 'N/A';

                  // Determine badge color
                  Color badgeColor = Colors.grey;
                  if (statusRaw == 'completed' || paymentStatus == 'CLEARED') badgeColor = Colors.green;
                  else if (statusRaw == 'delivery' || statusRaw == 'trial' || statusRaw == 'trial_2') badgeColor = Colors.blue;
                  else if (statusRaw == 'sales' || paymentStatus == 'PENDING') badgeColor = Colors.orange;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(date, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${statusRaw.toString().replaceAll('_', ' ').toUpperCase()} • $paymentStatus',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('$cName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
                        Text(cPhone, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Garment', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                const SizedBox(height: 2),
                                Text(garment, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: darkText)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Event Date', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                const SizedBox(height: 2),
                                Text(eventDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: darkText)),
                              ],
                            ),
                          ],
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

import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';

class MasterDashboard extends StatefulWidget {
  const MasterDashboard({super.key});

  @override
  State<MasterDashboard> createState() => _MasterDashboardState();
}

class _MasterDashboardState extends State<MasterDashboard> {
  List<dynamic> _orders = [];
  List<dynamic> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ordersList = await OrderService.getOrders();
    final usersList = await AuthService.getAllUsers();
    
    // Sort orders by priority: urgent -> high -> normal
    ordersList.sort((a, b) {
      final pA = (a['priority'] ?? 'normal').toString().toLowerCase();
      final pB = (b['priority'] ?? 'normal').toString().toLowerCase();
      if (pA == 'urgent') return -1;
      if (pB == 'urgent') return 1;
      if (pA == 'high') return -1;
      if (pB == 'high') return 1;
      return 0;
    });

    if (mounted) {
      setState(() {
        _orders = ordersList;
        _employees = usersList;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    final res = await OrderService.updateOrderStatus(orderId, status);
    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order advanced to $status!'), backgroundColor: const Color(0xFF16A34A)));
        _loadData();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
      }
    }
  }

  void _showAssignModal(BuildContext context, Map<String, dynamic> order, String roleTarget, String apiField) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    String? selectedWorkerId;
    final targetEmployees = _employees.where((e) => e['role'] == roleTarget).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign ${roleTarget.toUpperCase()} for Order: ${order['customerName'] ?? 'Customer'}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(fillColor: Colors.white, filled: true),
                    hint: const Text('Select Employee'),
                    items: targetEmployees.map((emp) {
                      return DropdownMenuItem<String>(
                        value: emp['_id'] as String,
                        child: Text('${emp['name']} (${emp['role']})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedWorkerId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedWorkerId == null
                          ? null
                          : () async {
                              final res = await OrderService.assignOrder(order['_id'], apiField, selectedWorkerId!);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              if (res['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Assigned successfully!'), backgroundColor: Color(0xFF16A34A)),
                                );
                                _loadData();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: darkText,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CONFIRM ASSIGNMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    final tailors = _employees.where((e) => e['role'] == 'tailor' || e['role'] == 'hand_worker').toList();
    final activeOrders = _orders.where((o) => !['completed', 'sales', 'fabric_dispensing', 'delivery'].contains(o['status'])).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
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
                        Text('Master Desk ✂️', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
                        SizedBox(height: 4),
                        Text('Order Queue & Staff Assignment', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: goldColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.design_services, color: goldColor),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Active Production', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                    Text('Sorted by Priority', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: goldColor)))
                    : activeOrders.isEmpty
                        ? const Center(child: Text('No active production orders.', style: TextStyle(color: Color(0xFF6B7280))))
                        : Column(
                            children: activeOrders.map((order) {
                              final priority = (order['priority'] ?? 'normal').toString();
                              final isUrgent = priority == 'urgent';
                              final isHigh = priority == 'high';
                              final status = order['status'] ?? 'pending';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isUrgent ? Colors.redAccent : (isHigh ? Colors.orangeAccent : const Color(0xFFE5E7EB)),
                                    width: isUrgent ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Order #${order['_id']?.substring(0,6)} - ${order['customerName']}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isUrgent ? const Color(0xFFFEE2E2) : (isHigh ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            priority.toUpperCase(),
                                            style: TextStyle(
                                              color: isUrgent ? Colors.redAccent : (isHigh ? Colors.orangeAccent : const Color(0xFF6B7280)),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Status: ${status.toUpperCase().replaceAll('_', ' ')}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: goldColor)),
                                    const SizedBox(height: 14),

                                    // Display assignments
                                    if (order['assignedTailor'] != null)
                                      Text('Tailor: ${order['assignedTailor']['name']}', style: const TextStyle(fontSize: 13)),
                                    if (order['assignedHandworker'] != null)
                                      Text('Handworker: ${order['assignedHandworker']['name']}', style: const TextStyle(fontSize: 13)),
                                    
                                    const SizedBox(height: 10),

                                    // Master Actions
                                    if (status == 'cutting') ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _showAssignModal(context, order, 'tailor', 'assignedTailor'),
                                              child: const Text('Assign Tailor'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _showAssignModal(context, order, 'hand_worker', 'assignedHandworker'),
                                              child: const Text('Assign HW'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: (order['assignedTailor'] != null && order['assignedHandworker'] != null) 
                                              ? () => _updateStatus(order['_id'], 'hand_work')
                                              : null,
                                          style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: darkText),
                                          child: const Text('Complete Cutting -> Hand-work'),
                                        ),
                                      )
                                    ] else if (status == 'trial') ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _updateStatus(order['_id'], 'alterations'),
                                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
                                      ),
                                    ] else if (status == 'trial_2') ...[
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => _updateStatus(order['_id'], 'delivery'),
                                          style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: darkText),
                                          child: const Text('Ready for Delivery'),
                                        ),
                                      )
                                    ] else if (['hand_work', 'stitching', 'alterations'].contains(status)) ...[
                                      // Reassign button if worker is absent
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            String targetRole = (status == 'hand_work') ? 'hand_worker' : 'tailor';
                                            String targetField = (status == 'hand_work') ? 'assignedHandworker' : 'assignedTailor';
                                            _showAssignModal(context, order, targetRole, targetField);
                                          },
                                          child: const Text('Reassign Worker (Temporary Override)'),
                                        ),
                                      )
                                    ]
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

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

  void _showAssignModal(BuildContext context, Map<String, dynamic> order) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    String? selectedWorker;

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
                    'Assign Order: ${order['customerName'] ?? 'Customer'}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Priority: ${(order['priority'] ?? 'Normal').toString().toUpperCase()}',
                    style: TextStyle(color: (order['priority'] == 'urgent') ? Colors.redAccent : goldColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Worker / Tailor / Hand-worker:', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(fillColor: Colors.white, filled: true),
                    items: _employees.map((emp) {
                      return DropdownMenuItem<String>(
                        value: emp['name'] as String,
                        child: Text('${emp['name']} (${emp['role']})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedWorker = val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedWorker == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Assigned to $selectedWorker successfully!'),
                                  backgroundColor: const Color(0xFF16A34A),
                                ),
                              );
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
                // Header
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

                // Staff Status Summary
                Container(
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
                          const Text('Staff Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                          Text('${tailors.length} Workers Active', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStaffBadge('Active Tailors', '${tailors.length}', const Color(0xFF16A34A)),
                          const SizedBox(width: 12),
                          _buildStaffBadge('On Leave', '1', Colors.orangeAccent),
                          const SizedBox(width: 12),
                          _buildStaffBadge('Reassigned', '0', Colors.blueAccent),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Priority Order Queue
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Priority Order Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                    Text('Sorted by Priority', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: goldColor)))
                    : _orders.isEmpty
                        ? const Center(child: Text('No orders in queue to assign.', style: TextStyle(color: Color(0xFF6B7280))))
                        : Column(
                            children: _orders.map((order) {
                              final priority = (order['priority'] ?? 'normal').toString();
                              final isUrgent = priority == 'urgent';
                              final isHigh = priority == 'high';

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
                                          order['customerName'] ?? 'Customer',
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
                                    Text('Category: ${order['garmentCategory'] ?? 'Suit/Garment'}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                    Text('Design Specs: ${order['design'] ?? order['addons'] ?? 'Standard'}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                    const SizedBox(height: 14),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showAssignModal(context, order),
                                        icon: const Icon(Icons.assignment_ind, size: 18),
                                        label: const Text('ASSIGN WORKER / REASSIGN'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: goldColor,
                                          foregroundColor: darkText,
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

  Widget _buildStaffBadge(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}

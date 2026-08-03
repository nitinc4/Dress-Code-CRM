import 'package:flutter/material.dart';

class AdminOrderManagement extends StatefulWidget {
  const AdminOrderManagement({super.key});

  @override
  State<AdminOrderManagement> createState() => _AdminOrderManagementState();
}

class _AdminOrderManagementState extends State<AdminOrderManagement> {
  String _selectedFilter = 'All Orders';

  void _showOrderTimelineModal(BuildContext context, String orderId) {
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
                      Text(orderId, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                      const Text('ABC Fashion Pvt Ltd | 500 Pcs', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14)),
                    child: const Text('In Production', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Order Date: 19 May 2026', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  Text('Delivery: 29 May 2026', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  Text('Priority: HIGH', style: TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),

              const Text('Production Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildTimelineStep('Order Confirmed', '19 May 2026, 09:30 AM', true, isFirst: true),
                    _buildTimelineStep('Measurement Taken', '19 May 2026, 11:15 AM', true),
                    _buildTimelineStep('Fabric Issued', '19 May 2026, 02:30 PM', true),
                    _buildTimelineStep('Cutting Complete', '20 May 2026, 09:00 AM', true),
                    _buildTimelineStep('Stitching (In Progress)', '20 May 2026, Active', false, isCurrent: true),
                    _buildTimelineStep('Quality Control (QC)', 'Pending', false),
                    _buildTimelineStep('Trial Fitting', 'Pending', false),
                    _buildTimelineStep('Packing', 'Pending', false),
                    _buildTimelineStep('Dispatch & Delivery', 'Pending', false, isLast: true),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Order Management', style: TextStyle(color: Color(0xFF0F2042), fontWeight: FontWeight.bold)),
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
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      selectedColor: const Color(0xFF0F2042),
                      backgroundColor: const Color(0xFFF1F5F9),
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildOrderItem(context, 'ORD-2026-0125', 'ABC Fashion Pvt Ltd', '500 Pcs • Men\'s Formal Shirt', 'In Production', const Color(0xFF2563EB), const Color(0xFFEFF6FF), '19 May 2026'),
                _buildOrderItem(context, 'ORD-2026-0124', 'XYZ Garments', '300 Pcs • 18 May 2026', 'Trial Pending', const Color(0xFFD97706), const Color(0xFFFEF3C7), '18 May 2026'),
                _buildOrderItem(context, 'ORD-2026-0123', 'Style Hub', '200 Pcs • 18 May 2026', 'QC Pending', const Color(0xFF7C3AED), const Color(0xFFF3E8FF), '18 May 2026'),
                _buildOrderItem(context, 'ORD-2026-0122', 'Trendy Wear', '400 Pcs • 17 May 2026', 'Ready for Delivery', const Color(0xFF16A34A), const Color(0xFFDCFCE7), '17 May 2026'),
                _buildOrderItem(context, 'ORD-2026-0120', 'Cool Styles', '150 Pcs • 16 May 2026', 'Canceled', const Color(0xFFDC2626), const Color(0xFFFEE2E2), '16 May 2026'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, String id, String client, String details, String status, Color statusColor, Color bgColor, String date) {
    return GestureDetector(
      onTap: () => _showOrderTimelineModal(context, id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F2042))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 6),
            Text(client, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
            const SizedBox(height: 2),
            Text(details, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isDone, {bool isCurrent = false, bool isFirst = false, bool isLast = false}) {
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
                color: isDone ? const Color(0xFF16A34A) : (isCurrent ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
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
                color: isDone ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal, color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF0F2042), fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }
}

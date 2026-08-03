import 'package:flutter/material.dart';

class EmployeeTasksScreen extends StatefulWidget {
  const EmployeeTasksScreen({super.key});

  @override
  State<EmployeeTasksScreen> createState() => _EmployeeTasksScreenState();
}

class _EmployeeTasksScreenState extends State<EmployeeTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _completedPcs = 65;
  final int _targetPcs = 120;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showUpdateProgressModal(BuildContext context) {
    int tempProgress = _completedPcs;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Update Work Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('WO-2026-1254 - Men\'s Formal Shirt', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  Text('Completed Quantity: $tempProgress / $_targetPcs Pcs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Slider(
                    value: tempProgress.toDouble(),
                    min: 0,
                    max: _targetPcs.toDouble(),
                    divisions: _targetPcs,
                    activeColor: const Color(0xFF2563EB),
                    label: '$tempProgress Pcs',
                    onChanged: (val) {
                      setModalState(() {
                        tempProgress = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _completedPcs = tempProgress;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Progress updated successfully!'), backgroundColor: Color(0xFF16A34A)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final double percent = (_completedPcs / _targetPcs).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Tasks & Work Orders', style: TextStyle(color: Color(0xFF0F2042), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Pending (2)'),
            Tab(text: 'Work Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Tasks List
          ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              // Card 1
              _buildTaskCard(
                context: context,
                id: 'WO-2026-1254',
                status: 'In Progress',
                statusColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                product: 'Men\'s Formal Shirt',
                department: 'Stitching - Line A',
                target: _targetPcs,
                completed: _completedPcs,
                percent: percent,
                due: '19 May 06:00 PM',
                showUpdateBtn: true,
              ),

              // Card 2
              _buildTaskCard(
                context: context,
                id: 'WO-2026-1255',
                status: 'Pending',
                statusColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
                product: 'Logo Embroidery',
                department: 'Target: 80 Pcs',
                target: 80,
                completed: 0,
                percent: 0.0,
                due: '19 May 08:00 PM',
                showUpdateBtn: false,
              ),

              // Card 3
              _buildTaskCard(
                context: context,
                id: 'WO-2026-1251',
                status: 'Completed',
                statusColor: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
                product: 'Stitching - Line B',
                department: '100 Pcs',
                target: 100,
                completed: 100,
                percent: 1.0,
                due: 'Completed',
                showUpdateBtn: false,
              ),
            ],
          ),

          // All Work Orders View
          const Center(child: Text('All Work Orders History', style: TextStyle(color: Color(0xFF64748B)))),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required String id,
    required String status,
    required Color statusColor,
    required Color bgColor,
    required String product,
    required String department,
    required int target,
    required int completed,
    required double percent,
    required String due,
    required bool showUpdateBtn,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F2042))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(product, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
          const SizedBox(height: 4),
          Text('Department: $department', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 14),

          // Quantity Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Completed: $completed / $target Pcs', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
              Text('${(percent * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due: $due', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              if (showUpdateBtn)
                ElevatedButton(
                  onPressed: () => _showUpdateProgressModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Update Progress', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                )
            ],
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdminProductionDashboard extends StatelessWidget {
  const AdminProductionDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Production Dashboard', style: TextStyle(color: Color(0xFF0F2042), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Cards
            Row(
              children: [
                _buildSummaryTile('Total Orders', '186', const Color(0xFF2563EB)),
                const SizedBox(width: 10),
                _buildSummaryTile('In Progress', '134', const Color(0xFFD97706)),
                const SizedBox(width: 10),
                _buildSummaryTile('Completed', '48', const Color(0xFF16A34A)),
                const SizedBox(width: 10),
                _buildSummaryTile('Delayed', '12', const Color(0xFFDC2626)),
              ],
            ),
            const SizedBox(height: 20),

            // Production Efficiency
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Production Efficiency', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  SizedBox(height: 4),
                  Text('76.8%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F2042))),
                  SizedBox(height: 2),
                  Text('▲ +4.6% vs Yesterday', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Department Progress
            const Text('Department Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDeptRow('Cutting', '85%', 0.85, const Color(0xFF2563EB)),
                  const SizedBox(height: 14),
                  _buildDeptRow('Stitching', '62%', 0.62, const Color(0xFFD97706)),
                  const SizedBox(height: 14),
                  _buildDeptRow('Embroidery', '78%', 0.78, const Color(0xFF7C3AED)),
                  const SizedBox(height: 14),
                  _buildDeptRow('Finishing', '45%', 0.45, const Color(0xFFEC4899)),
                  const SizedBox(height: 14),
                  _buildDeptRow('Quality Control (QC)', '30%', 0.30, const Color(0xFF0284C7)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delayed Orders Alert Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_outlined, color: Color(0xFFDC2626), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('12 Orders Delayed in Stitching & Finishing', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Icon(Icons.chevron_right, color: Color(0xFFDC2626)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold), maxLines: 1),
            const SizedBox(height: 6),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptRow(String name, String percentText, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
            Text(percentText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

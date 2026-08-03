import 'package:flutter/material.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Payslip & Salary', style: TextStyle(color: Color(0xFF0F2042), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF0F2042), borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.chevron_left, color: Colors.white),
                  Text('May 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Net Salary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Net Salary', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('₹ 18,650', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F2042))),
                  const SizedBox(height: 4),
                  const Text('Paid on 31 May 2026', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),

                  // Earnings
                  const Text('Earnings', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042), fontSize: 15)),
                  const SizedBox(height: 8),
                  _buildRow('Basic Salary', '₹ 15,000'),
                  _buildRow('DA', '₹ 2,500'),
                  _buildRow('OT Amount', '₹ 1,800'),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Total Earnings', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                      Text('₹ 19,300', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
                    ],
                  ),

                  const Divider(height: 24),

                  // Deductions
                  const Text('Deductions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042), fontSize: 15)),
                  const SizedBox(height: 8),
                  _buildRow('PF', '₹ 1,800'),
                  _buildRow('ESI', '₹ 450'),
                  _buildRow('Professional Tax', '₹ 200'),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Total Deductions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                      Text('₹ 2,450', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                    ],
                  ),

                  const Divider(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Net Pay', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F2042))),
                      Text('₹ 18,650', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF16A34A))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading Payslip PDF...'), backgroundColor: Color(0xFF2563EB)),
                  );
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text('Download Payslip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          Text(amount, style: const TextStyle(color: Color(0xFF0F2042), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

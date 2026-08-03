import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';

class AdminMoreMenu extends StatelessWidget {
  const AdminMoreMenu({super.key});

  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'title': 'Inventory', 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFF2563EB)},
      {'title': 'Sales', 'icon': Icons.trending_up_outlined, 'color': const Color(0xFF16A34A)},
      {'title': 'Purchase', 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFFD97706)},
      {'title': 'Finance', 'icon': Icons.account_balance_wallet_outlined, 'color': const Color(0xFF7C3AED)},
      {'title': 'Approvals', 'icon': Icons.verified_outlined, 'color': const Color(0xFF0284C7)},
      {'title': 'Reports', 'icon': Icons.bar_chart_outlined, 'color': const Color(0xFFEC4899)},
      {'title': 'HR & Staff', 'icon': Icons.people_outline, 'color': const Color(0xFF059669)},
      {'title': 'Branches', 'icon': Icons.storefront_outlined, 'color': const Color(0xFFEA580C)},
      {'title': 'Fabric Rolls', 'icon': Icons.texture_outlined, 'color': const Color(0xFF4F46E5)},
      {'title': 'Settings', 'icon': Icons.settings_outlined, 'color': const Color(0xFF64748B)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('ERP Management Suite', style: TextStyle(color: Color(0xFF0F2042), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.0,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${item['title']} module...')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'] as IconData, size: 28, color: item['color'] as Color),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F2042)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

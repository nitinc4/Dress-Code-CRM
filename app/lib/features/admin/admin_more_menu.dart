import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../auth/role_selection_screen.dart';
import 'admin_screens.dart';

class AdminMoreMenu extends StatelessWidget {
  const AdminMoreMenu({super.key});

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

    final menuItems = [
      {'title': 'Product Catalogue', 'icon': Icons.inventory_2_outlined, 'page': const AdminCatalogueScreen()},
      {'title': 'Sales', 'icon': Icons.trending_up_outlined, 'page': const AdminSalesScreen()},
      {'title': 'Purchase', 'icon': Icons.shopping_bag_outlined, 'page': const AdminPurchaseScreen()},
      {'title': 'Finance', 'icon': Icons.account_balance_wallet_outlined, 'page': const AdminFinanceScreen()},
      {'title': 'Approvals', 'icon': Icons.verified_outlined, 'page': const AdminApprovalsScreen()},
      {'title': 'Reports', 'icon': Icons.bar_chart_outlined, 'page': const AdminReportsScreen()},
      {'title': 'HR & Staff', 'icon': Icons.people_outline, 'page': const AdminHRStaffScreen()},
      {'title': 'Fabric Rolls', 'icon': Icons.texture_outlined, 'page': const AdminFabricRollsScreen()},
      {'title': 'Settings', 'icon': Icons.settings_outlined, 'page': const AdminSettingsScreen()},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ERP Management Suite', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item['page'] as Widget),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'] as IconData, size: 28, color: goldColor),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkText),
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
                label: const Text('LOG OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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

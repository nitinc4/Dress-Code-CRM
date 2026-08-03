import 'package:flutter/material.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = [
      {'name': 'Admin', 'icon': Icons.admin_panel_settings, 'roleId': 'admin'},
      {'name': 'Sales', 'icon': Icons.point_of_sale, 'roleId': 'sales_rep'},
      {'name': 'Master', 'icon': Icons.design_services, 'roleId': 'master'},
      {'name': 'Cutting Master', 'icon': Icons.content_cut, 'roleId': 'cutting_master'},
      {'name': 'Tailor', 'icon': Icons.cut, 'roleId': 'tailor'},
      {'name': 'Hand-worker', 'icon': Icons.handyman, 'roleId': 'hand_worker'},
      {'name': 'Warehouse', 'icon': Icons.warehouse, 'roleId': 'warehouse_manager'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Image.asset('assets/images/Logo.jpg', height: 40),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'DressCode.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                'Select\nYour Role',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: Theme.of(context).primaryColor, // Gold
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Access your personalized workspace.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(
                              roleName: role['name'] as String,
                              roleId: role['roleId'] as String,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(role['icon'] as IconData, size: 42, color: Theme.of(context).primaryColor),
                            const SizedBox(height: 16),
                            Text(
                              role['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

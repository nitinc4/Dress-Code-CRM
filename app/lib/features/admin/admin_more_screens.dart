import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/leave_service.dart';
import '../../core/services/inventory_service.dart';
import '../../core/services/attendance_service.dart';

const goldColor = Color(0xFFD4AF37);
const darkText = Color(0xFF121212);

// ==========================================
// 7. Sales Screen
// ==========================================
class AdminSalesScreen extends StatefulWidget {
  const AdminSalesScreen({super.key});
  @override
  State<AdminSalesScreen> createState() => _AdminSalesScreenState();
}
class _AdminSalesScreenState extends State<AdminSalesScreen> {
  bool isLoading = true;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await OrderService.getOrders();
    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalSales = orders.length;
    double totalRevenue = orders.fold(0.0, (sum, item) => sum + ((item['totalCost'] ?? 0) as num).toDouble());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Sales Overview', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: goldColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard('Total Orders', totalSales.toString(), Icons.shopping_cart_outlined),
                const SizedBox(height: 16),
                _buildSummaryCard('Total Revenue', '₹${totalRevenue.toStringAsFixed(2)}', Icons.currency_rupee_outlined),
                const SizedBox(height: 24),
                const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 12),
                ...orders.take(10).map((o) => Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(o['customerName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${o['garmentCategory'] ?? ''} - ${o['status'] ?? 'pending'}'),
                    trailing: Text('₹${o['totalCost'] ?? 0}', style: const TextStyle(color: goldColor, fontWeight: FontWeight.bold)),
                  ),
                )),
              ],
            ),
          ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: goldColor.withOpacity(0.1), radius: 24, child: Icon(icon, color: goldColor)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
          ])
        ],
      ),
    );
  }
}

// ==========================================
// 8. Purchase Screen
// ==========================================
class AdminPurchaseScreen extends StatelessWidget {
  const AdminPurchaseScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Purchase Orders', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Purchase Module Coming Soon', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 9. Finance Screen
// ==========================================
class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});
  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}
class _AdminFinanceScreenState extends State<AdminFinanceScreen> {
  bool isLoading = true;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await OrderService.getOrders();
    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalRevenue = orders.fold(0.0, (sum, item) => sum + ((item['totalCost'] ?? 0) as num).toDouble());
    double pendingPayments = orders.where((o) => o['paymentStatus'] != 'completed').fold(0.0, (sum, item) => sum + ((item['totalCost'] ?? 0) as num).toDouble());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Finance Overview', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: goldColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFinanceCard('Total Received', '₹${(totalRevenue - pendingPayments).toStringAsFixed(2)}', Colors.green),
                const SizedBox(height: 16),
                _buildFinanceCard('Pending Payments', '₹${pendingPayments.toStringAsFixed(2)}', Colors.orange),
                const SizedBox(height: 24),
                const Text('Pending Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 12),
                ...orders.where((o) => o['paymentStatus'] != 'completed').take(10).map((o) => Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(o['customerName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Status: ${o['paymentStatus'] ?? 'pending'}'),
                    trailing: Text('₹${o['totalCost'] ?? 0}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                )),
              ],
            ),
          ),
    );
  }

  Widget _buildFinanceCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ==========================================
// 10. Approvals Screen
// ==========================================
class AdminApprovalsScreen extends StatefulWidget {
  const AdminApprovalsScreen({super.key});
  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}
class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> {
  bool isLoading = true;
  List<dynamic> leaves = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await LeaveService.getAllLeaves();
    setState(() {
      leaves = data.where((l) => l['status'] == 'Pending').toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Pending Approvals', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: goldColor))
        : leaves.isEmpty 
          ? const Center(child: Text('No pending approvals', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                final leave = leaves[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${leave['userId']?['name'] ?? 'Unknown Employee'} - ${leave['leaveType']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Duration: ${leave['fromDate']} to ${leave['toDate']} (${leave['noOfDays']} days)'),
                        const SizedBox(height: 4),
                        Text('Reason: ${leave['reason']}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () {}, child: const Text('Reject', style: TextStyle(color: Colors.red))),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () {},
                              child: const Text('Approve', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// 11. Reports Screen
// ==========================================
class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Business Reports', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Reports Module Coming Soon', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 12. HR & Staff Screen
// ==========================================
class AdminHRStaffScreen extends StatefulWidget {
  const AdminHRStaffScreen({super.key});
  @override
  State<AdminHRStaffScreen> createState() => _AdminHRStaffScreenState();
}
class _AdminHRStaffScreenState extends State<AdminHRStaffScreen> {
  bool isLoading = true;
  List<dynamic> users = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await AuthService.getAllUsers();
    setState(() {
      users = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final role = (user['role'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase()) || role.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('HR & Staff', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: goldColor))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search employees...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      elevation: 0,
                      color: Colors.grey[50],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: goldColor, child: Text(user['name']?.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white))),
                        title: Text(user['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user['role'] ?? 'employee'),
                        trailing: Text(user['status'] ?? 'active', style: TextStyle(color: user['status'] == 'active' ? Colors.green : Colors.grey)),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminEmployeeDetailsScreen(user: user)));
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}

// ==========================================
// Employee Details Screen
// ==========================================
class AdminEmployeeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminEmployeeDetailsScreen({super.key, required this.user});

  @override
  State<AdminEmployeeDetailsScreen> createState() => _AdminEmployeeDetailsScreenState();
}

class _AdminEmployeeDetailsScreenState extends State<AdminEmployeeDetailsScreen> {
  bool isLoading = true;
  List<dynamic> attendance = [];
  List<dynamic> leaves = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Future<void> _fetchEmployeeData() async {
    final String userId = widget.user['_id'] ?? widget.user['id'];
    final attData = await AttendanceService.getUserAttendance(userId);
    final leaveData = await LeaveService.getUserLeaves(userId);
    
    if (mounted) {
      setState(() {
        attendance = attData;
        leaves = leaveData;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final bank = user['bankingDetails'] ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(user['name'] ?? 'Employee Details', style: const TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: isLoading
        ? const Center(child: CircularProgressIndicator(color: goldColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Info
                Row(
                  children: [
                    CircleAvatar(radius: 40, backgroundColor: goldColor, child: Text(user['name']?.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white, fontSize: 32))),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name'] ?? 'Unknown', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Role: ${user['role'] ?? 'employee'}', style: const TextStyle(color: Colors.grey)),
                        Text('Phone: ${user['phone'] ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Bank Details
                const Text('Banking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bank: ${bank['bankName'] ?? 'N/A'}'),
                      const SizedBox(height: 4),
                      Text('Account Name: ${bank['accountName'] ?? 'N/A'}'),
                      const SizedBox(height: 4),
                      Text('Account No: ${bank['accountNumber'] ?? 'N/A'}'),
                      const SizedBox(height: 4),
                      Text('IFSC: ${bank['ifsc'] ?? 'N/A'}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Leaves
                const Text('Recent Leaves', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (leaves.isEmpty) const Text('No leave history', style: TextStyle(color: Colors.grey)),
                ...leaves.map((l) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${l['leaveType']} - ${l['status']}', style: TextStyle(fontWeight: FontWeight.bold, color: l['status'] == 'Approved' ? Colors.green : Colors.orange)),
                    subtitle: Text('${l['fromDate']} to ${l['toDate']} (${l['noOfDays']} days)'),
                  ),
                )),
                const SizedBox(height: 24),

                // Attendance
                const Text('Recent Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (attendance.isEmpty) const Text('No attendance history', style: TextStyle(color: Colors.grey)),
                ...attendance.take(5).map((a) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(a['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('In: ${_formatTime(a['checkInTime'])} | Out: ${_formatTime(a['checkOutTime'])}'),
                    trailing: Text(a['status'] ?? '', style: const TextStyle(color: goldColor, fontWeight: FontWeight.bold)),
                  ),
                )),
              ],
            ),
          ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '--:--';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }
}

// ==========================================
// 13. Fabric Rolls Screen
// ==========================================
class AdminFabricRollsScreen extends StatefulWidget {
  const AdminFabricRollsScreen({super.key});
  @override
  State<AdminFabricRollsScreen> createState() => _AdminFabricRollsScreenState();
}
class _AdminFabricRollsScreenState extends State<AdminFabricRollsScreen> {
  bool isLoading = true;
  List<dynamic> inventory = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await InventoryService.getInventory();
    setState(() {
      inventory = data.where((item) => item['category'] == 'fabric roll').toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Fabric Rolls Inventory', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: goldColor))
        : inventory.isEmpty
          ? const Center(child: Text('No inventory items found', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                final item = inventory[index];
                return Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.texture_outlined, color: goldColor),
                    title: Text(item['itemName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Category: ${item['category'] ?? '-'}'),
                    trailing: Text('${item['quantity']} ${item['unit'] ?? ''}', style: const TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// 14. Settings Screen
// ==========================================
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('System Settings', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsTile(Icons.person_outline, 'Profile Settings', 'Update your information'),
          _buildSettingsTile(Icons.notifications_none, 'Notifications', 'Manage alert preferences'),
          _buildSettingsTile(Icons.language, 'Language', 'English (US)'),
          _buildSettingsTile(Icons.security, 'Security', 'Password & Authentication'),
          _buildSettingsTile(Icons.help_outline, 'Help & Support', 'Contact support team'),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: darkText),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}

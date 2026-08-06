import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../auth/role_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscController = TextEditingController();

  String _userId = '';
  String _userRole = 'Staff';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_id') ?? '';
    final role = prefs.getString('user_role') ?? 'Staff';
    final name = prefs.getString('user_name') ?? 'Employee';

    setState(() {
      _userId = uid;
      _userRole = role;
      _nameController.text = name;
    });

    if (uid.isNotEmpty) {
      final userProfile = await AuthService.getUserProfile(uid);
      if (userProfile != null && mounted) {
        setState(() {
          _nameController.text = userProfile['name'] ?? name;
          _emailController.text = userProfile['email'] ?? '';
          if (userProfile['bankingDetails'] != null) {
            final bank = userProfile['bankingDetails'];
            _accountNameController.text = bank['accountName'] ?? '';
            _accountNumberController.text = bank['accountNumber'] ?? '';
            _bankNameController.text = bank['bankName'] ?? '';
            _ifscController.text = bank['ifsc'] ?? '';
          }
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_userId.isEmpty) return;

    setState(() => _isLoading = true);

    final result = await AuthService.updateProfile(_userId, {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'bankingDetails': {
        'accountName': _accountNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'ifsc': _ifscController.text.trim(),
      }
    });

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile & Banking details saved to database!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to update profile'), backgroundColor: Colors.redAccent),
      );
    }
  }

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: goldColor.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, size: 50, color: goldColor),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: goldColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: darkText),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _userRole.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: goldColor, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 32),

            const Text('Personal Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              style: const TextStyle(color: darkText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: darkText),
            ),
            const SizedBox(height: 32),

            const Text('Banking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 16),
            TextField(
              controller: _accountNameController,
              decoration: const InputDecoration(labelText: 'Account Holder Name', prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
              style: const TextStyle(color: darkText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountNumberController,
              decoration: const InputDecoration(labelText: 'Account Number', prefixIcon: Icon(Icons.numbers)),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: darkText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bankNameController,
              decoration: const InputDecoration(labelText: 'Bank Name', prefixIcon: Icon(Icons.account_balance_outlined)),
              style: const TextStyle(color: darkText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ifscController,
              decoration: const InputDecoration(labelText: 'IFSC Code', prefixIcon: Icon(Icons.code)),
              style: const TextStyle(color: darkText),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: darkText,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: darkText, strokeWidth: 2))
                    : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

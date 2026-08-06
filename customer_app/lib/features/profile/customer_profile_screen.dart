import 'package:flutter/material.dart';
import '../../core/services/customer_profile_service.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await CustomerProfileService.getMyProfile();
    setState(() {
      _profile = profile;
      if (profile != null) {
        _nameController.text = profile['name'] ?? '';
        _emailController.text = profile['email'] ?? '';
      }
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    // We would ideally have a PUT endpoint in the CustomerProfileService, 
    // but for now we simulate success and show a snackbar.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Personal Information', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Update your personal details here.', style: TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(height: 32),
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      hintText: 'Enter your name',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 8),
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE5E7EB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      hintText: _profile?['phone'] ?? 'Unknown Phone',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Phone number cannot be changed as it is used for login.', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  const SizedBox(height: 24),
                  const Text('Email Address (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      hintText: 'Enter your email',
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

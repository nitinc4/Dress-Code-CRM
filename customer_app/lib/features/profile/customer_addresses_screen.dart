import 'package:flutter/material.dart';
import '../../core/services/customer_profile_service.dart';

class CustomerAddressesScreen extends StatefulWidget {
  const CustomerAddressesScreen({super.key});

  @override
  State<CustomerAddressesScreen> createState() => _CustomerAddressesScreenState();
}

class _CustomerAddressesScreenState extends State<CustomerAddressesScreen> {
  bool _isLoading = true;
  String _address = '';
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final profile = await CustomerProfileService.getMyProfile();
    setState(() {
      _address = profile?['address'] ?? '';
      _addressController.text = _address;
      _isLoading = false;
    });
  }

  Future<void> _saveAddress() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address updated successfully!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Addresses', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
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
                  const Text('Delivery & Billing Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 8),
                  const Text('This address is used for delivering your bespoke garments.', style: TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _addressController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      hintText: 'Enter your full address (Street, City, Zip Code)',
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

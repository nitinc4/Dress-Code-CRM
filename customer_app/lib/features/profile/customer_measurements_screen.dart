import 'package:flutter/material.dart';
import '../../core/services/customer_profile_service.dart';

class CustomerMeasurementsScreen extends StatefulWidget {
  const CustomerMeasurementsScreen({super.key});

  @override
  State<CustomerMeasurementsScreen> createState() => _CustomerMeasurementsScreenState();
}

class _CustomerMeasurementsScreenState extends State<CustomerMeasurementsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _measurements;

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
  }

  Future<void> _fetchMeasurements() async {
    final profile = await CustomerProfileService.getMyProfile();
    setState(() {
      _measurements = profile?['measurements'] ?? {};
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('My Measurements', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : _measurements == null || _measurements!.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.straighten_outlined, size: 64, color: goldColor),
                      SizedBox(height: 16),
                      Text('No Measurements on File', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
                      SizedBox(height: 8),
                      Text('Please visit the store to get measured.', style: TextStyle(color: Color(0xFF6B7280))),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text('Saved Bespoke Measurements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                    const SizedBox(height: 8),
                    const Text('These are the measurements taken during your last fitting. To request changes, please contact support.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: _measurements!.entries.map((e) => _buildMeasurementRow(e.key, e.value)).toList(),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMeasurementRow(String label, dynamic value) {
    // Make the label more readable (e.g., 'chestSize' -> 'Chest Size')
    final formattedLabel = label.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
    final finalLabel = formattedLabel[0].toUpperCase() + formattedLabel.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(finalLabel, style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          Text('$value in', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
        ],
      ),
    );
  }
}

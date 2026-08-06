import 'package:flutter/material.dart';

class CustomerOffersScreen extends StatelessWidget {
  const CustomerOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Offers & Promotions', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: goldColor),
            SizedBox(height: 16),
            Text('No Active Promotions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
            SizedBox(height: 8),
            Text('Check back later for seasonal discounts.', style: TextStyle(color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

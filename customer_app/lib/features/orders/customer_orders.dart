import 'package:flutter/material.dart';

class CustomerOrders extends StatelessWidget {
  const CustomerOrders({super.key});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: goldColor),
            SizedBox(height: 16),
            Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
            SizedBox(height: 8),
            Text('When you place an order, it will appear here.', style: TextStyle(color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

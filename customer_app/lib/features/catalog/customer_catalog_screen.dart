import 'package:flutter/material.dart';
import '../../core/services/product_service.dart';

class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({super.key});

  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> {
  bool _isLoading = true;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final products = await ProductService.getProducts();
    setState(() {
      _products = products;
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
        title: const Text('Bespoke Catalog', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : _products.isEmpty
              ? const Center(
                  child: Text('No products available at the moment.', style: TextStyle(color: Color(0xFF6B7280))),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return _buildProductCard(product, goldColor, darkText);
                  },
                ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Color goldColor, Color darkText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0F2042),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(Icons.checkroom, size: 64, color: goldColor.withOpacity(0.5)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? 'Garment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 8),
                Text(product['description'] ?? 'Premium bespoke tailoring.', style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Starting at ₹${product['basePrice'] ?? 0}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: goldColor)),
                    ElevatedButton(
                      onPressed: () {
                        _showInterestDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2042),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('I\'m Interested'),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showInterestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Store Visit'),
        content: const Text('Bespoke tailoring requires exact body measurements. Would you like to schedule a store visit to get started with this garment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store visit requested! We will contact you shortly.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Request Callback', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

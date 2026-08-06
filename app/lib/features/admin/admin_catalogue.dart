import 'package:flutter/material.dart';

import '../../core/services/product_service.dart';

class AdminCatalogueScreen extends StatefulWidget {
  const AdminCatalogueScreen({super.key});
  @override
  State<AdminCatalogueScreen> createState() => _AdminCatalogueScreenState();
}

class _AdminCatalogueScreenState extends State<AdminCatalogueScreen> {
  bool isLoading = true;
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ProductService.getProducts();
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    final garments = products.where((p) => p['category'] != 'fabric').toList();
    final fabrics = products.where((p) => p['category'] == 'fabric').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Catalogue', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator(color: goldColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (garments.isNotEmpty) ...[
                  const Text('Garments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 12),
                  ...garments.map((g) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.checkroom, color: goldColor),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                                const SizedBox(height: 2),
                                Text(g['description'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                Text('₹${g['price'] ?? 0}', style: const TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
                
                if (fabrics.isNotEmpty) ...[
                  const Text('Fabrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 12),
                  ...fabrics.map((f) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.texture, color: goldColor),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                                Text('Rate: ₹${f['price'] ?? 0}', style: const TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(f['description'] ?? '', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';

class AdminCatalogueScreen extends StatelessWidget {
  const AdminCatalogueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    final garments = [
      {'name': 'Men\'s 3-Piece Formal Suit', 'hours': '10 Labor Hours', 'image': 'assets/images/mens_suit.png'},
      {'name': 'Royal Wedding Sherwani', 'hours': '14 Labor Hours', 'image': 'assets/images/mens_sherwani.png'},
      {'name': 'Silk Kurta Pajama', 'hours': '4 Labor Hours', 'image': 'assets/images/mens_kurta.png'},
    ];

    final fabrics = [
      {'name': 'Italian Wool Twill', 'rate': '₹45 / meter', 'finishes': 'Matte, Satin Finish', 'patterns': 'Solid, Houndstooth', 'image': 'assets/images/fabric_sample.png'},
      {'name': 'Raw Silk Brocade', 'rate': '₹65 / meter', 'finishes': 'Glossy, Textured', 'patterns': 'Royal Jacquard', 'image': 'assets/images/fabric_sample.png'},
      {'name': 'Egyptian Cotton Canvas', 'rate': '₹28 / meter', 'finishes': 'Crisp Matte', 'patterns': 'Plain Weave', 'image': 'assets/images/fabric_sample.png'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Men\'s Product Catalogue', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Men\'s Garment Types (Labor Hours)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(g['image']!, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                          const SizedBox(height: 2),
                          Text(g['hours']!, style: const TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            const Text('Fabrics & Finishes (Per Meter Pricing)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(f['image']!, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                          Text('Rate: ${f['rate']}', style: const TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Finishes: ${f['finishes']} | Patterns: ${f['patterns']}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

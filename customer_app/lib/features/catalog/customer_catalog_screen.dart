import 'package:flutter/material.dart';
import '../../core/services/product_service.dart';
import 'customer_garment_config_screen.dart';

class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({super.key});

  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> {
  bool _isLoading = true;
  List<dynamic> _allProducts = [];
  List<dynamic> _garments = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final products = await ProductService.getProducts();
    setState(() {
      _allProducts = products;
      _garments = products.where((p) => p['category'] == 'mens_wear' || p['category'] == 'womens_wear').toList();
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
          : _garments.isEmpty
              ? const Center(
                  child: Text('No garments available at the moment.', style: TextStyle(color: Color(0xFF6B7280))),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: _garments.length,
                  itemBuilder: (context, index) {
                    final garment = _garments[index];
                    return _buildProductCard(garment, goldColor, darkText, index);
                  },
                ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Color goldColor, Color darkText, int index) {
    final suitImages = [
      'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800&q=80',
      'https://images.unsplash.com/photo-1593030761757-71fae46fa84d?w=800&q=80',
      'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=800&q=80',
      'https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?w=800&q=80',
      'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&q=80',
      'https://images.unsplash.com/photo-1548883354-7622d03aca27?w=800&q=80',
    ];
    final dressImages = [
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&q=80',
      'https://images.unsplash.com/photo-1566160983994-01be18241512?w=800&q=80',
      'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800&q=80',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&q=80',
    ];

    final isWomens = product['category'] == 'womens_wear';
    final imageList = isWomens ? dressImages : suitImages;
    final fallbackUrl = imageList[index % imageList.length];
    final imageUrl = (product['image'] != null && product['image'].toString().startsWith('http'))
        ? product['image']
        : fallbackUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerGarmentConfigScreen(garment: product, allProducts: _allProducts, imageUrl: imageUrl)));
      },
      child: Container(
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
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2042),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name'] ?? 'Garment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(product['description'] ?? 'Premium bespoke tailoring.', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${product['price'] ?? 0}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldColor)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


}

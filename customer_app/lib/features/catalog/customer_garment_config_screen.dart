import 'package:flutter/material.dart';

class CustomerGarmentConfigScreen extends StatefulWidget {
  final Map<String, dynamic> garment;
  final List<dynamic> allProducts;
  final String imageUrl;

  const CustomerGarmentConfigScreen({
    super.key,
    required this.garment,
    required this.allProducts,
    required this.imageUrl,
  });

  @override
  State<CustomerGarmentConfigScreen> createState() => _CustomerGarmentConfigScreenState();
}

class _CustomerGarmentConfigScreenState extends State<CustomerGarmentConfigScreen> {
  List<dynamic> _fabrics = [];
  List<dynamic> _addons = [];

  Map<String, dynamic>? _selectedFabric;
  final List<Map<String, dynamic>> _selectedAddons = [];

  @override
  void initState() {
    super.initState();
    _fabrics = widget.allProducts.where((p) => p['category'] == 'fabric').toList();
    _addons = widget.allProducts.where((p) => p['category'] == 'addon').toList();
    
    if (_fabrics.isNotEmpty) {
      _selectedFabric = _fabrics.first;
    }
  }

  double get _totalPrice {
    double base = (widget.garment['price'] ?? 0).toDouble();
    if (_selectedFabric != null) {
      // Simple assumption: fabric price is per meter, assume 3 meters needed.
      double meters = (widget.garment['metersNeeded'] ?? 3.0).toDouble();
      base += (_selectedFabric!['price'] ?? 0).toDouble() * meters;
    }
    for (var addon in _selectedAddons) {
      base += (addon['price'] ?? 0).toDouble();
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.garment['name'] ?? 'Bespoke Garment', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkText)),
                            const SizedBox(height: 8),
                            Text(widget.garment['description'] ?? 'Premium tailoring tailored to your exact measurements.', style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: goldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('₹${widget.garment['price'] ?? 0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: goldColor)),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('1. Select Material', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 16),
                  _fabrics.isEmpty
                      ? const Text('No fabrics available.', style: TextStyle(color: Colors.grey))
                      : SizedBox(
                          height: 155,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _fabrics.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final fabric = _fabrics[index];
                              final isSelected = _selectedFabric == fabric;
                              
                              final fabricImages = [
                                'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=400&q=80',
                                'https://images.unsplash.com/photo-1605389657753-48817da376ab?w=400&q=80',
                                'https://images.unsplash.com/photo-1584313887258-00ccabf6e246?w=400&q=80',
                                'https://images.unsplash.com/photo-1590680650953-ebbd188f54c9?w=400&q=80',
                                'https://images.unsplash.com/photo-1528458876861-544fd1761a91?w=400&q=80',
                                'https://images.unsplash.com/photo-1544816155-12df9643f363?w=400&q=80',
                              ];
                              
                              final fabricImage = (fabric['image'] != null && fabric['image'].toString().startsWith('http')) 
                                  ? fabric['image'] 
                                  : fabricImages[index % fabricImages.length];

                              return GestureDetector(
                                onTap: () => setState(() => _selectedFabric = fabric),
                                child: Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? goldColor : const Color(0xFFE2E8F0), 
                                      width: isSelected ? 2.5 : 1
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected ? goldColor.withOpacity(0.15) : Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                            child: Image.network(
                                              fabricImage,
                                              height: 85,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) => Container(
                                                height: 85,
                                                color: const Color(0xFF0F2042),
                                                child: const Icon(Icons.texture, color: goldColor),
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: const BoxDecoration(
                                                  color: goldColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.check, size: 12, color: Colors.white),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fabric['name'] ?? 'Fabric',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                color: darkText,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '+₹${fabric['price'] ?? 0}/m',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: goldColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  
                  const SizedBox(height: 32),
                  const Text('2. Select Add-ons (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 16),
                  _addons.isEmpty
                      ? const Text('No add-ons available.', style: TextStyle(color: Colors.grey))
                      : Column(
                          children: _addons.map((addon) {
                            final isSelected = _selectedAddons.contains(addon);
                            return CheckboxListTile(
                              title: Text(addon['name'] ?? 'Addon', style: const TextStyle(fontWeight: FontWeight.w600, color: darkText)),
                              subtitle: Text('+₹${addon['price'] ?? 0}', style: const TextStyle(color: goldColor)),
                              value: isSelected,
                              activeColor: goldColor,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedAddons.add(addon);
                                  } else {
                                    _selectedAddons.remove(addon);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                  
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Total', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                Text('₹${_totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _showAppointmentDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Request Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  void _showAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Configuration'),
        content: const Text('Your customized garment has been configured! A tailor will review your selections and contact you to schedule a fitting appointment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to catalog
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuration saved! We will contact you shortly.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Confirm & Book', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_provider.dart';
import '../../../core/services/customer_service.dart';

class OrderFlowScreen extends StatefulWidget {
  const OrderFlowScreen({super.key});

  @override
  State<OrderFlowScreen> createState() => _OrderFlowScreenState();
}

class _OrderFlowScreenState extends State<OrderFlowScreen> {
  int _currentStep = 0;
  bool _isSearchingCustomer = false;
  String? _customerStatusBadge;

  // Placeholder Data Catalogs (Men's Wear Specs)
  final List<Map<String, dynamic>> _fabrics = [
    {
      'name': 'Italian Wool Twill',
      'pricePerMeter': 45.0,
      'image': 'assets/images/fabric_sample.png',
      'finishes': ['Matte Smooth', 'Soft Satin Finish', 'Brushed Warm'],
      'colors': ['Navy Blue', 'Charcoal Grey', 'Midnight Black'],
      'patterns': ['Solid Twill', 'Houndstooth', 'Pinstripe'],
    },
    {
      'name': 'Raw Silk Brocade',
      'pricePerMeter': 65.0,
      'image': 'assets/images/fabric_sample.png',
      'finishes': ['Glossy Luster', 'Textured Jacquard'],
      'colors': ['Beige Gold', 'Royal Maroon', 'Emerald Green'],
      'patterns': ['Royal Jacquard Motif', 'Self Paisley', 'Floral Weave'],
    },
    {
      'name': 'Egyptian Cotton Canvas',
      'pricePerMeter': 28.0,
      'image': 'assets/images/fabric_sample.png',
      'finishes': ['Crisp Matte', 'Breathable Soft'],
      'colors': ['Off-White', 'Sky Blue', 'Pastel Peach'],
      'patterns': ['Plain Weave', 'Micro Check', 'Textured Oxford'],
    },
  ];

  final List<Map<String, dynamic>> _garments = [
    {
      'name': 'Men\'s 3-Piece Tuxedo / Suit',
      'laborHours': 10.0,
      'metersNeeded': 3.5,
      'image': 'assets/images/mens_suit.png',
      'description': 'Jacket, Vest, & Trousers (10 Tailor Labor Hours)',
    },
    {
      'name': 'Royal Wedding Sherwani',
      'laborHours': 14.0,
      'metersNeeded': 4.0,
      'image': 'assets/images/mens_sherwani.png',
      'description': 'Long Coat & Churidar (14 Tailor Labor Hours)',
    },
    {
      'name': 'Silk Kurta Pajama',
      'laborHours': 4.0,
      'metersNeeded': 2.5,
      'image': 'assets/images/mens_kurta.png',
      'description': 'Traditional Kurta & Trousers (4 Tailor Labor Hours)',
    },
  ];

  final List<Map<String, dynamic>> _addons = [
    {
      'name': 'Handmade Gold Zardozi Embroidery',
      'addonHours': 6.0,
      'description': 'Collar & Cuff Heavy Gold Threadwork (6 Crafting Hours @ ₹20/hr = ₹120)',
    },
    {
      'name': 'Satin Lapel Piping & Custom Buttons',
      'addonHours': 2.0,
      'description': 'Satin Edge Trimming & Brass Buttons (2 Crafting Hours @ ₹20/hr = ₹40)',
    },
    {
      'name': 'Velvet Patchwork & Crest Emblem',
      'addonHours': 4.0,
      'description': 'Embroidered Chest Crest & Velvet Highlights (4 Crafting Hours @ ₹20/hr = ₹80)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkText = Color(0xFF121212);

    return ChangeNotifierProvider(
      create: (_) => OrderProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: darkText),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Men\'s Order Intake & Pricing',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<OrderProvider>(
                  builder: (context, provider, child) {
                    // Set defaults if null
                    provider.selectedFabric ??= _fabrics[0];
                    provider.selectedGarment ??= _garments[0];
                    provider.selectedAddon ??= _addons[0];

                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: goldColor,
                          surface: Colors.white,
                          onSurface: darkText,
                        ),
                      ),
                      child: Stepper(
                        type: StepperType.vertical,
                        physics: const BouncingScrollPhysics(),
                        currentStep: _currentStep,
                        onStepContinue: () async {
                          if (_currentStep < 4) {
                            setState(() => _currentStep += 1);
                          } else {
                            final result = await provider.submitOrder();
                            if (!context.mounted) return;
                            if (result['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order & Bill generated successfully!', style: TextStyle(color: darkText)),
                                  backgroundColor: goldColor,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              final msg = result['message'] ?? 'Unknown Error';
                              debugPrint('[ORDER_FLOW_SCREEN] Order Generation Failed: $msg');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to generate order: $msg'),
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep -= 1);
                          }
                        },
                        controlsBuilder: (BuildContext context, ControlsDetails details) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: details.onStepContinue,
                                    style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: darkText),
                                    child: Text(_currentStep == 4 ? 'GENERATE BILL & SUBMIT' : 'CONTINUE'),
                                  ),
                                ),
                                if (_currentStep > 0) ...[
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: details.onStepCancel,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: darkText,
                                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('BACK'),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          );
                        },
                        steps: [
                          // STEP 1: CUSTOMER (AUTOMATIC DB LOOKUP)
                          Step(
                            title: const Text('Customer Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number (10 digits)',
                                    prefixIcon: Icon(Icons.phone_outlined, color: goldColor),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  onChanged: (val) async {
                                    provider.customerPhone = val;
                                    if (val.length == 10) {
                                      setState(() {
                                        _isSearchingCustomer = true;
                                        _customerStatusBadge = 'Searching Database...';
                                      });
                                      final existing = await CustomerService.findCustomerByPhone(val);
                                      if (!mounted) return;
                                      setState(() {
                                        _isSearchingCustomer = false;
                                        if (existing != null) {
                                          provider.isExistingCustomer = true;
                                          provider.customerName = existing['name'] ?? '';
                                          provider.customerAddress = existing['address'] ?? '';
                                          if (existing['measurements'] != null) {
                                            provider.measurements['shoulder'] = (existing['measurements']['shoulder'] as num?)?.toDouble() ?? 17.5;
                                            provider.measurements['chest'] = (existing['measurements']['chest'] as num?)?.toDouble() ?? 40.0;
                                          }
                                          _customerStatusBadge = '✓ Existing Customer: ${existing['name']} (Details & Measurements Loaded)';
                                        } else {
                                          provider.isExistingCustomer = false;
                                          _customerStatusBadge = '+ New Customer Found (Enter details below)';
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        _customerStatusBadge = null;
                                      });
                                    }
                                  },
                                ),
                                if (_isSearchingCustomer)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: LinearProgressIndicator(color: goldColor),
                                  ),
                                if (_customerStatusBadge != null)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: provider.isExistingCustomer ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: provider.isExistingCustomer ? const Color(0xFF16A34A) : const Color(0xFF2563EB)),
                                    ),
                                    child: Text(
                                      _customerStatusBadge!,
                                      style: TextStyle(
                                        color: provider.isExistingCustomer ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                if (!provider.isExistingCustomer) ...[
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    initialValue: provider.customerName,
                                    decoration: const InputDecoration(labelText: 'Full Customer Name'),
                                    onChanged: (val) => provider.customerName = val,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    initialValue: provider.customerAddress,
                                    decoration: const InputDecoration(labelText: 'Delivery Address'),
                                    onChanged: (val) => provider.customerAddress = val,
                                  ),
                                ]
                              ],
                            ),
                            isActive: _currentStep >= 0,
                            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                          ),

                          // STEP 2: EVENT
                          Step(
                            title: const Text('Event Date & Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        provider.eventDate = date;
                                        provider.calculatePriority();
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          provider.eventDate == null
                                              ? 'Select Event Date'
                                              : 'Event Date: ${provider.eventDate.toString().split(' ')[0]}',
                                          style: TextStyle(color: provider.eventDate == null ? const Color(0xFF6B7280) : darkText, fontSize: 14),
                                        ),
                                        const Icon(Icons.calendar_today, color: goldColor),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Customer Budget (₹)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => provider.budget = double.tryParse(val) ?? 0,
                                ),
                                if (provider.eventDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      'Calculated Priority: ${provider.orderPriority.toUpperCase()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: provider.orderPriority == 'urgent' ? Colors.redAccent : goldColor,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            isActive: _currentStep >= 1,
                            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                          ),

                          // STEP 3: FABRIC & GARMENT CATALOGUE (WITH PICTURES & SPECS)
                          Step(
                            title: const Text('Fabric & Garment Selection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Garment Category Selection
                                const Text('1. Select Garment Type (Determines Labor Hours):', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 8),
                                ..._garments.map((g) {
                                  final isSelected = provider.selectedGarment?['name'] == g['name'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        provider.selectedGarment = g;
                                        provider.fabricMeters = (g['metersNeeded'] as num).toDouble();
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? goldColor.withValues(alpha: 0.15) : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: isSelected ? goldColor : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.asset(g['image'], width: 50, height: 50, fit: BoxFit.cover),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(g['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                                                Text(g['description'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 16),

                                // Fabric Selection
                                const Text('2. Select Fabric (Determines Cost Per Meter):', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 8),
                                ..._fabrics.map((f) {
                                  final isSelected = provider.selectedFabric?['name'] == f['name'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        provider.selectedFabric = f;
                                        provider.fabricFinish = (f['finishes'] as List<String>)[0];
                                        provider.fabricColor = (f['colors'] as List<String>)[0];
                                        provider.fabricPattern = (f['patterns'] as List<String>)[0];
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? goldColor.withValues(alpha: 0.15) : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: isSelected ? goldColor : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.asset(f['image'], width: 50, height: 50, fit: BoxFit.cover),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(f['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                                                Text('₹${f['pricePerMeter']} / meter', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: goldColor)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: provider.fabricColor,
                                        decoration: const InputDecoration(labelText: 'Color'),
                                        items: ((provider.selectedFabric?['colors'] as List<String>?) ?? ['Navy Blue']).map((c) {
                                          return DropdownMenuItem(value: c, child: Text(c));
                                        }).toList(),
                                        onChanged: (val) => setState(() => provider.fabricColor = val!),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: provider.fabricFinish,
                                        decoration: const InputDecoration(labelText: 'Finish'),
                                        items: ((provider.selectedFabric?['finishes'] as List<String>?) ?? ['Matte']).map((fn) {
                                          return DropdownMenuItem(value: fn, child: Text(fn));
                                        }).toList(),
                                        onChanged: (val) => setState(() => provider.fabricFinish = val!),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isActive: _currentStep >= 2,
                            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                          ),

                          // STEP 4: MEASUREMENTS & ADDONS (FIXED HOURLY PRICE)
                          Step(
                            title: const Text('Addons & Body Measurements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Select Addon / Design (Addon Hours @ ₹20/hr):', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 8),
                                ..._addons.map((a) {
                                  final isSelected = provider.selectedAddon?['name'] == a['name'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        provider.selectedAddon = a;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? goldColor.withValues(alpha: 0.15) : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: isSelected ? goldColor : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(a['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                                          const SizedBox(height: 2),
                                          Text(a['description'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 16),
                                const Text('Body Measurements (Inches):', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: '17.5',
                                        decoration: const InputDecoration(labelText: 'Shoulder'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) => provider.measurements['shoulder'] = double.tryParse(val) ?? 17.5,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: '40.0',
                                        decoration: const InputDecoration(labelText: 'Chest'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) => provider.measurements['chest'] = double.tryParse(val) ?? 40.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isActive: _currentStep >= 3,
                            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                          ),

                          // STEP 5: AUTOMATIC PRICE BREAKDOWN & BILL GENERATION
                          Step(
                            title: const Text('Calculated Pricing & Bill Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildPriceRow('Fabric Cost (${provider.fabricMeters}m @ ₹${provider.selectedFabric?['pricePerMeter'] ?? 45}/m)', '₹${provider.fabricCost.toStringAsFixed(2)}'),
                                      const SizedBox(height: 8),
                                      _buildPriceRow('Garment Labor (${provider.selectedGarment?['laborHours'] ?? 10} hrs @ ₹${provider.laborHourlyRate}/hr)', '₹${provider.garmentLaborCost.toStringAsFixed(2)}'),
                                      const SizedBox(height: 8),
                                      _buildPriceRow('Addon Crafting (${provider.selectedAddon?['addonHours'] ?? 6} hrs @ ₹${provider.addonHourlyRate}/hr)', '₹${provider.addonCost.toStringAsFixed(2)}'),
                                      const Divider(height: 24),
                                      _buildPriceRow('Total Calculated Cost', '₹${provider.totalCalculatedCost.toStringAsFixed(2)}', isBold: true),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Sales Discount (₹)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      provider.discount = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<String>(
                                  value: provider.paymentStatus,
                                  decoration: const InputDecoration(labelText: 'Payment Option'),
                                  items: const [
                                    DropdownMenuItem(value: 'pending', child: Text('Full Payment')),
                                    DropdownMenuItem(value: 'partial', child: Text('Partial Advance Payment')),
                                    DropdownMenuItem(value: 'pay_later', child: Text('Tap Pay Later (15 Days Credit)')),
                                  ],
                                  onChanged: (val) => setState(() => provider.paymentStatus = val!),
                                ),
                                const SizedBox(height: 24),

                                // Final Bill Box
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: darkText,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('FINAL BILL AMOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                      Text('₹${provider.finalBill.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: goldColor)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            isActive: _currentStep >= 4,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: isBold ? Colors.black : const Color(0xFF6B7280), fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
        Text(value, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isBold ? const Color(0xFFD4AF37) : Colors.black)),
      ],
    );
  }
}

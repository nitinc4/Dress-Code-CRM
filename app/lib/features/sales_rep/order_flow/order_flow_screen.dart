import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_provider.dart';
import '../../../core/services/customer_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/order_service.dart';

class OrderFlowScreen extends StatefulWidget {
  const OrderFlowScreen({super.key});

  @override
  State<OrderFlowScreen> createState() => _OrderFlowScreenState();
}

class _OrderFlowScreenState extends State<OrderFlowScreen> {
  int _currentStep = 0;
  
  // Order processing state
  bool _isProcessing = false;
  
  // Existing customer tracking
  bool _isSearchingCustomer = false;
  String? _customerStatusBadge;
  List<dynamic> _customerPastOrders = [];
  bool _isLoadingPastOrders = false;

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

  List<Map<String, dynamic>> _garments = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ProductService.getProductsByCategory('mens_wear');
    if (mounted) {
      setState(() {
        _garments = products.map((p) => {
          'name': p['name'],
          'laborHours': (p['laborHours'] ?? 10).toDouble(),
          'metersNeeded': (p['metersNeeded'] ?? 3.5).toDouble(),
          'image': p['image'] ?? 'assets/images/mens_suit.png',
          'description': p['description'] ?? '',
          'requiredMeasurements': p['requiredMeasurements'] ?? [],
        }).toList();
        _isLoadingProducts = false;
      });
    }
  }

  final List<Map<String, dynamic>> _addons = [
    {
      'name': 'None / No Addons',
      'addonHours': 0.0,
      'description': 'Standard finish, no extra custom crafting required (0 Hours)',
    },
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
                    if (_isLoadingProducts) {
                      return const Center(child: CircularProgressIndicator(color: goldColor));
                    }

                    // Set defaults if null
                    provider.selectedFabric ??= _fabrics[0];
                    provider.selectedGarment ??= _garments.isNotEmpty ? _garments[0] : null;
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
                        type: StepperType.horizontal,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        currentStep: _currentStep,
                        onStepContinue: () async {
                          if (_currentStep == 3) {
                            // Save measurements to database
                            final customerData = {
                              'phone': provider.customerPhone,
                              'name': provider.customerName.isNotEmpty ? provider.customerName : 'Valued Customer',
                              'address': provider.customerAddress,
                              'measurements': provider.measurements,
                            };
                            if (provider.customerId != null) {
                              await CustomerService.updateCustomer(provider.customerId!, customerData);
                            } else {
                              final res = await CustomerService.createCustomer(customerData);
                              if (res['success'] == true && res['data'] != null) {
                                provider.customerId = res['data']['_id'];
                                provider.isExistingCustomer = true;
                              }
                            }
                            setState(() => _currentStep += 1);
                          } else if (_currentStep < 4) {
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
                            title: const SizedBox.shrink(),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('1. Customer Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 24),
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
                                          provider.customerId = existing['_id'];
                                          provider.customerName = existing['name'] ?? '';
                                          provider.customerAddress = existing['address'] ?? '';
                                          if (existing['measurements'] != null) {
                                            (existing['measurements'] as Map<String, dynamic>).forEach((key, value) {
                                              provider.measurements[key] = (value as num).toDouble();
                                            });
                                          }
                                          _customerStatusBadge = '✓ Existing Customer: ${existing['name']} (Details & Measurements Loaded)';
                                          _isLoadingPastOrders = true;
                                        } else {
                                          provider.isExistingCustomer = false;
                                          _customerPastOrders = [];
                                          _customerStatusBadge = '+ New Customer Enter details below';
                                        }
                                      });
                                      
                                      if (existing != null) {
                                        final pastOrders = await OrderService.getOrdersByCustomer(val);
                                        if (mounted) {
                                          setState(() {
                                            _customerPastOrders = pastOrders;
                                            _isLoadingPastOrders = false;
                                          });
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        _customerStatusBadge = null;
                                        _customerPastOrders = [];
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
                                  
                                if (provider.isExistingCustomer && _isLoadingPastOrders)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Center(child: CircularProgressIndicator(color: goldColor)),
                                  ),
                                  
                                if (provider.isExistingCustomer && !_isLoadingPastOrders && _customerPastOrders.isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      const Text('Past Order History', style: TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 16)),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 140,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _customerPastOrders.length,
                                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                                          itemBuilder: (context, index) {
                                            final order = _customerPastOrders[index];
                                            final totalCost = (order['totalCost'] ?? 0).toDouble();
                                            final paymentStatus = order['paymentStatus']?.toString().toUpperCase() ?? 'PENDING';
                                            final garment = order['garmentCategory'] ?? 'Garment';
                                            final dateStr = order['createdAt'] ?? '';
                                            final date = dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
                                            
                                            // Extract Sales Person (Assigned Master)
                                            String salesPerson = 'N/A';
                                            if (order['assignedMaster'] != null && order['assignedMaster'] is Map) {
                                              salesPerson = order['assignedMaster']['name'] ?? 'N/A';
                                            } else if (order['originalTailor'] != null && order['originalTailor'] is Map) {
                                              salesPerson = order['originalTailor']['name'] ?? 'N/A';
                                            }
                                            
                                            // Determine paid status based on breakdown
                                            double orderPaid = 0.0;
                                            if (order['pricingBreakdown'] != null) {
                                              var advance = order['pricingBreakdown']['advancePaymentAmount'];
                                              if (advance != null) {
                                                orderPaid = advance is String ? (double.tryParse(advance) ?? 0.0) : advance.toDouble();
                                              }
                                            }
                                            double orderDue = totalCost - orderPaid;
                                            bool isCleared = orderDue <= 0 && paymentStatus != 'PENDING';

                                            return Container(
                                              width: 220,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(date, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: isCleared ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          isCleared ? 'CLEARED' : (orderPaid > 0 ? 'PARTIAL' : 'PENDING'),
                                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCleared ? Colors.green : Colors.orange),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(garment, style: const TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.person, size: 12, color: Color(0xFF6B7280)),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(salesPerson, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  const Divider(height: 1),
                                                  const Spacer(),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const Text('Total:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                                      Text('₹${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const Text('Paid:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                                      Text('₹${orderPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),

                                if (provider.customerPhone.length == 10) ...[
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    key: ValueKey('name_${provider.customerId ?? provider.customerPhone}'),
                                    initialValue: provider.customerName,
                                    decoration: const InputDecoration(labelText: 'Full Customer Name'),
                                    onChanged: (val) => provider.customerName = val,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    key: ValueKey('address_${provider.customerId ?? provider.customerPhone}'),
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
                            title: const SizedBox.shrink(),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('2. Event Date & Budget', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 24),
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
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: DropdownButtonFormField<String>(
                                      value: provider.orderPriority,
                                      decoration: const InputDecoration(
                                        labelText: 'Order Priority (Auto-calculated, but editable)',
                                        prefixIcon: Icon(Icons.flag, color: goldColor),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'normal', child: Text('Normal')),
                                        DropdownMenuItem(value: 'high', child: Text('High', style: TextStyle(color: Colors.orange))),
                                        DropdownMenuItem(value: 'urgent', child: Text('Urgent', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            provider.orderPriority = val;
                                          });
                                        }
                                      },
                                    ),
                                  )
                              ],
                            ),
                            isActive: _currentStep >= 1,
                            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                          ),

                          // STEP 3: FABRIC & GARMENT CATALOGUE (WITH PICTURES & SPECS)
                          Step(
                            title: const SizedBox.shrink(),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('3. Fabric & Garment Selection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 24),
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
                            title: const SizedBox.shrink(),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('4. Addons & Body Measurements', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 24),
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
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: (provider.selectedGarment?['requiredMeasurements'] as List<dynamic>?)?.map((m) {
                                    final measurementName = m.toString();
                                    return SizedBox(
                                      width: (MediaQuery.of(context).size.width - 70) / 2, // Half width minus padding
                                      child: TextFormField(
                                        key: ValueKey('${provider.customerId ?? 'new'}_$measurementName'),
                                        initialValue: provider.measurements[measurementName]?.toString() ?? '',
                                        decoration: InputDecoration(labelText: measurementName),
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) => provider.measurements[measurementName] = double.tryParse(val) ?? 0.0,
                                      ),
                                    );
                                  }).toList() ?? [],
                                ),
                              ],
                            ),
                            isActive: _currentStep >= 3,
                            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                          ),

                          // STEP 5: AUTOMATIC PRICE BREAKDOWN & BILL GENERATION
                          Step(
                            title: const SizedBox.shrink(),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('5. Calculated Pricing & Bill', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                                const SizedBox(height: 24),
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
                                const SizedBox(height: 16),
                                if (provider.paymentStatus == 'partial') ...[
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: goldColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Advance Amount Received (₹)',
                                            prefixIcon: Icon(Icons.currency_rupee, color: goldColor),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (val) {
                                            setState(() {
                                              provider.advancePaymentAmount = double.tryParse(val) ?? 0.0;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Scan to Pay'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        height: 200,
                                                        color: Colors.grey[200],
                                                        child: const Center(child: Icon(Icons.qr_code, size: 150, color: darkText)),
                                                      ),
                                                      const SizedBox(height: 16),
                                                      Text('Amount: ₹${provider.advancePaymentAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.qr_code_scanner),
                                            label: const Text('Generate Payment QR'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: darkText,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Final Bill Box
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: darkText,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('FINAL BILL AMOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                          Text('₹${provider.finalBill.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: goldColor)),
                                        ],
                                      ),
                                      if (provider.paymentStatus == 'partial') ...[
                                        const Divider(color: Colors.white24, height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Advance Paid', style: TextStyle(fontSize: 14, color: Colors.white70)),
                                            Text('- ₹${provider.advancePaymentAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.white)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('REMAINING BALANCE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                            Text('₹${provider.remainingBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                          ],
                                        ),
                                      ],
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

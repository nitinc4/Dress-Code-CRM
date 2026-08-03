import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_provider.dart';

class OrderFlowScreen extends StatefulWidget {
  const OrderFlowScreen({super.key});

  @override
  State<OrderFlowScreen> createState() => _OrderFlowScreenState();
}

class _OrderFlowScreenState extends State<OrderFlowScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'New Order',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<OrderProvider>(
                  builder: (context, provider, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Theme.of(context).primaryColor, // Gold color for active steps
                          background: Colors.white,
                          onSurface: Colors.black87,
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
                            bool success = await provider.submitOrder();
                            if (!context.mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Order placed successfully!', style: TextStyle(color: Colors.white)),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to place order.')),
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
                            padding: const EdgeInsets.only(top: 32.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: details.onStepContinue,
                                    child: Text(_currentStep == 4 ? 'SUBMIT ORDER' : 'CONTINUE'),
                                  ),
                                ),
                                if (_currentStep > 0) ...[
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: details.onStepCancel,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                        side: BorderSide(color: Colors.black.withOpacity(0.1)),
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          Step(
                            title: const Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            content: Column(
                              children: [
                                SwitchListTile(
                                  title: const Text('Existing Customer?', style: TextStyle(color: Colors.black87)),
                                  value: provider.isExistingCustomer,
                                  activeColor: Theme.of(context).primaryColor,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) => setState(() => provider.isExistingCustomer = val),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Phone Number'),
                                  onChanged: (val) => provider.customerPhone = val,
                                  keyboardType: TextInputType.phone,
                                ),
                                if (!provider.isExistingCustomer) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    decoration: const InputDecoration(labelText: 'Full Name'),
                                    onChanged: (val) => provider.customerName = val,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    decoration: const InputDecoration(labelText: 'Address'),
                                    onChanged: (val) => provider.customerAddress = val,
                                  ),
                                ]
                              ],
                            ),
                            isActive: _currentStep >= 0,
                            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                          ),
                          Step(
                            title: const Text('Event Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Theme.of(context).primaryColor,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.black87,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (date != null) {
                                      setState(() {
                                        provider.eventDate = date;
                                        provider.calculatePriority();
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          provider.eventDate == null
                                              ? 'Select Event Date'
                                              : 'Date: ${provider.eventDate.toString().split(' ')[0]}',
                                          style: TextStyle(
                                            color: provider.eventDate == null ? Colors.black54 : Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Budget (\$)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => provider.budget = double.tryParse(val) ?? 0,
                                ),
                                if (provider.eventDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(
                                      'Calculated Priority: ${provider.orderPriority.toUpperCase()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: provider.orderPriority == 'urgent' ? Colors.redAccent : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            isActive: _currentStep >= 1,
                            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                          ),
                          Step(
                            title: const Text('Fabric & Design', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            content: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Garment Category (e.g. Suit, Kurta)'),
                                  onChanged: (val) => provider.garmentCategory = val,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Fabric Color / Material'),
                                  onChanged: (val) => provider.fabricColor = val,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Design / Embroidery Specs'),
                                  onChanged: (val) => provider.embroideryDesign = val,
                                ),
                              ],
                            ),
                            isActive: _currentStep >= 2,
                            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                          ),
                          Step(
                            title: const Text('Measurements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            content: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Shoulder (inches)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => provider.measurements['shoulder'] = double.tryParse(val) ?? 0,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Chest (inches)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => provider.measurements['chest'] = double.tryParse(val) ?? 0,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Special Instructions / Add-ons'),
                                  onChanged: (val) => provider.addons = val,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                            isActive: _currentStep >= 3,
                            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                          ),
                          Step(
                            title: const Text('Billing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Total Cost (\$)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() => provider.totalCost = double.tryParse(val) ?? 0);
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Discount (\$)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() => provider.discount = double.tryParse(val) ?? 0);
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: provider.paymentStatus,
                                  decoration: const InputDecoration(labelText: 'Payment Status'),
                                  dropdownColor: Colors.white,
                                  iconEnabledColor: Theme.of(context).primaryColor,
                                  items: const [
                                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                    DropdownMenuItem(value: 'partial', child: Text('Partial')),
                                    DropdownMenuItem(value: 'full', child: Text('Full')),
                                    DropdownMenuItem(value: 'pay_later', child: Text('Pay Later (15 days)')),
                                  ],
                                  onChanged: (val) => setState(() => provider.paymentStatus = val!),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('FINAL BILL', style: TextStyle(fontSize: 18, color: Colors.white70)),
                                      Text(
                                        '\$${provider.totalCost - provider.discount}',
                                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
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
}

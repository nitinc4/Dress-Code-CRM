import 'package:flutter/foundation.dart';
import '../../../core/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  // Step 1: Customer
  String customerName = '';
  String customerPhone = '';
  String customerAddress = '';
  bool isExistingCustomer = false;

  // Step 2: Event Details
  DateTime? eventDate;
  double budget = 0.0;
  String orderPriority = 'normal';

  // Step 3: Fabric & Design
  String fabricColor = '';
  String fabricPattern = '';
  String fabricQuality = '';
  String garmentCategory = '';
  String embroideryDesign = '';

  // Step 4: Measurements & Addons
  Map<String, double> measurements = {};
  String addons = '';

  // Step 5: Billing
  double totalCost = 0.0;
  double discount = 0.0;
  String paymentStatus = 'pending'; // 'full', 'partial', 'pay_later'

  void calculatePriority() {
    if (eventDate == null) return;
    final daysUntilEvent = eventDate!.difference(DateTime.now()).inDays;
    if (daysUntilEvent <= 3) {
      orderPriority = 'urgent';
    } else if (daysUntilEvent <= 7) {
      orderPriority = 'high';
    } else {
      orderPriority = 'normal';
    }
    notifyListeners();
  }

  Future<bool> submitOrder() async {
    final orderData = {
      // Typically, we would map to actual Customer ID and Product IDs here.
      // For this wizard prototype, we send the aggregated data.
      'customerName': customerName,
      'customerPhone': customerPhone,
      'eventDate': eventDate?.toIso8601String(),
      'priority': orderPriority,
      'fabricDetails': {
        'color': fabricColor,
        'pattern': fabricPattern,
        'quality': fabricQuality,
      },
      'garmentCategory': garmentCategory,
      'design': embroideryDesign,
      'measurements': measurements,
      'addons': addons,
      'totalCost': totalCost,
      'discount': discount,
      'paymentStatus': paymentStatus,
    };
    
    // Using existing createOrder API format 
    // (Note: Backend may need schema updates to accept all these flat fields, 
    // or this provider should assemble the exact schema we created).
    final result = await OrderService.createOrder(orderData);
    return result['success'] == true;
  }
}

import 'package:flutter/foundation.dart';
import '../../../core/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  // Step 1: Customer
  String customerName = '';
  String customerPhone = '';
  String customerAddress = '';
  bool isExistingCustomer = false;
  String? customerId;

  // Step 2: Event Details
  DateTime? eventDate;
  double budget = 0.0;
  String orderPriority = 'normal';

  // Step 3: Fabric & Garment Selection (Men's Catalog)
  Map<String, dynamic>? selectedFabric;
  String fabricColor = 'Navy Blue';
  String fabricPattern = 'Solid Twill';
  String fabricFinish = 'Matte Smooth';
  double fabricMeters = 3.5;

  Map<String, dynamic>? selectedGarment;
  Map<String, dynamic>? selectedAddon;

  // Step 4: Measurements & Addons
  Map<String, double> measurements = {
    'shoulder': 17.5,
    'chest': 40.0,
    'waist': 34.0,
    'length': 30.0,
  };
  String customNotes = '';

  // Step 5: Pricing Calculation Model
  double laborHourlyRate = 15.0; // $15 / hr
  double addonHourlyRate = 20.0; // $20 / hr

  double discount = 0.0;
  String paymentStatus = 'pending';
  double advancePaymentAmount = 0.0;

  // Calculated getters based on user specs formula:
  // 1. Fabric Cost = pricePerMeter * meters
  double get fabricCost {
    final rate = (selectedFabric?['pricePerMeter'] as num?)?.toDouble() ?? 45.0;
    return rate * fabricMeters;
  }

  // 2. Garment Labor Cost = baseHours * laborHourlyRate
  double get garmentLaborCost {
    final hours = (selectedGarment?['laborHours'] as num?)?.toDouble() ?? 8.0;
    return hours * laborHourlyRate;
  }

  // 3. Addon Cost = addonHours * addonHourlyRate
  double get addonCost {
    final hours = (selectedAddon?['addonHours'] as num?)?.toDouble() ?? 3.0;
    return hours * addonHourlyRate;
  }

  // 4. Total Cost = Fabric Cost + Garment Labor Cost + Addon Cost
  double get totalCalculatedCost {
    return fabricCost + garmentLaborCost + addonCost;
  }

  double get finalBill {
    return (totalCalculatedCost - discount).clamp(0.0, double.infinity);
  }

  double get remainingBalance {
    return (finalBill - advancePaymentAmount).clamp(0.0, double.infinity);
  }

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

  Future<Map<String, dynamic>> submitOrder() async {
    final orderData = {
      'customerName': customerName.isNotEmpty ? customerName : 'Valued Customer',
      'customerPhone': customerPhone.isNotEmpty ? customerPhone : '9999999999',
      'customerAddress': customerAddress.isNotEmpty ? customerAddress : 'Main Store',
      'eventDate': eventDate?.toIso8601String(),
      'priority': orderPriority,
      'fabricDetails': {
        'name': selectedFabric?['name'] ?? 'Italian Wool Twill',
        'color': fabricColor,
        'pattern': fabricPattern,
        'finish': fabricFinish,
        'meters': fabricMeters,
        'pricePerMeter': selectedFabric?['pricePerMeter'] ?? 45.0,
      },
      'garmentCategory': selectedGarment?['name'] ?? 'Men\'s 3-Piece Suit',
      'design': selectedAddon?['name'] ?? 'Gold Zardozi Embroidery',
      'pricingBreakdown': {
        'fabricCost': fabricCost,
        'garmentLaborCost': garmentLaborCost,
        'addonCost': addonCost,
        'totalCalculated': totalCalculatedCost,
        'discount': discount,
        'finalBill': finalBill,
        'advancePaymentAmount': advancePaymentAmount,
        'remainingBalance': remainingBalance,
      },
      'measurements': measurements,
      'addons': customNotes,
      'totalCost': finalBill,
      'discount': discount,
      'paymentStatus': paymentStatus,
      'status': 'fabric_dispensing',
    };

    debugPrint('[ORDER_PROVIDER] Submitting order payload: $orderData');
    final result = await OrderService.createOrder(orderData);
    debugPrint('[ORDER_PROVIDER] createOrder Result: $result');
    return result;
  }
}

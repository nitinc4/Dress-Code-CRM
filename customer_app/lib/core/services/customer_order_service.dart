import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class CustomerOrderService {
  static Future<List<dynamic>> getMyOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('user_phone') ?? '';
      
      if (phone.isEmpty) return [];

      final response = await ApiClient.get('/orders/customer/$phone');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching customer orders: $e');
      return [];
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

class OrderService {
  static Future<List<dynamic>> getOrders() async {
    try {
      final response = await ApiClient.get('/orders');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('[ORDER_SERVICE] Error getOrders: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      debugPrint('[ORDER_SERVICE] Sending POST /orders payload: ${jsonEncode(orderData)}');
      final response = await ApiClient.post('/orders', orderData);
      debugPrint('[ORDER_SERVICE] Response Code: ${response.statusCode}');
      debugPrint('[ORDER_SERVICE] Response Body: ${response.body}');

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': responseBody};
      } else {
        final errorMsg = responseBody['error'] ?? responseBody['message'] ?? 'Status Code ${response.statusCode}';
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      debugPrint('[ORDER_SERVICE] Exception in createOrder: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    try {
      final response = await ApiClient.put('/orders/$id', {'status': status});
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to update order status'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> assignOrder(String id, String roleField, String employeeId) async {
    try {
      final response = await ApiClient.put('/orders/$id', {roleField: employeeId});
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to assign order'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

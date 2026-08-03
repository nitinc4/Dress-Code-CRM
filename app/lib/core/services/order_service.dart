import 'dart:convert';
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
      print(e);
      return [];
    }
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await ApiClient.post('/orders', orderData);
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to place order'};
    } catch (e) {
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
      // roleField should be one of: assignedMaster, assignedTailor, assignedHandworker
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

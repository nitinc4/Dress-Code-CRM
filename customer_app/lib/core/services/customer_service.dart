import 'dart:convert';
import '../network/api_client.dart';

class CustomerService {
  static Future<List<dynamic>> getCustomers() async {
    try {
      final response = await ApiClient.get('/customers');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> findCustomerByPhone(String phone) async {
    try {
      final response = await ApiClient.get('/customers/find/$phone');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await ApiClient.post('/customers', customerData);
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['error'] ?? 'Failed to create customer'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> updateData) async {
    try {
      final response = await ApiClient.put('/customers/$id', updateData);
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to update customer'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

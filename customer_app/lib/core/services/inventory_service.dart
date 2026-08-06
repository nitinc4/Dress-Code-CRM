import 'dart:convert';
import '../network/api_client.dart';

class InventoryService {
  static Future<List<dynamic>> getInventory() async {
    try {
      final response = await ApiClient.get('/inventory');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<Map<String, dynamic>> createInventoryItem(Map<String, dynamic> itemData) async {
    try {
      final response = await ApiClient.post('/inventory', itemData);
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to add item'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateStock(String id, int quantity) async {
    try {
      final response = await ApiClient.put('/inventory/$id', {'quantity': quantity});
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to update stock'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

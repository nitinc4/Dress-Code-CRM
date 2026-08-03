import 'dart:convert';
import '../network/api_client.dart';

class ProductService {
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await ApiClient.get('/products');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await ApiClient.post('/products', productData);
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to create product'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

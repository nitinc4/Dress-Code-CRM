import 'dart:convert';
import '../network/api_client.dart';

class ProductService {
  static Future<List<dynamic>> getProductsByCategory(String category) async {
    try {
      final response = await ApiClient.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> allProducts = jsonDecode(response.body);
        return allProducts.where((p) => p['category'] == category).toList();
      }
      return [];
    } catch (e) {
      print('[PRODUCT_SERVICE] Error fetching products: $e');
      return [];
    }
  }
}

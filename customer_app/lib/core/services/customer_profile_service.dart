import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class CustomerProfileService {
  static Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('user_phone') ?? '';
      
      if (phone.isEmpty) return null;

      final response = await ApiClient.get('/customers/find/$phone');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching customer profile: $e');
      return null;
    }
  }
}

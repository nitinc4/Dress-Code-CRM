import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> checkPhone(String phone) async {
    try {
      final response = await ApiClient.post('/auth/check-phone', {'phone': phone});
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to check phone'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> registerCustomer(String name, String phone, String password) async {
    try {
      final response = await ApiClient.post('/auth/register-customer', {
        'name': name,
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_role', data['user']['role']);
        await prefs.setString('user_id', data['user']['id']);
        await prefs.setString('user_name', data['user']['name'] ?? 'Customer');
        await prefs.setString('user_phone', phone);
        
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await ApiClient.post('/auth/login', {
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_role', data['user']['role']);
        await prefs.setString('user_id', data['user']['id']);
        await prefs.setString('user_name', data['user']['name'] ?? 'Customer');
        await prefs.setString('user_phone', phone);
        
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> updateData) async {
    try {
      final response = await ApiClient.put('/auth/profile/$userId', updateData);
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to update profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('is_guest');
  }

  static Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await ApiClient.get('/auth');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await ApiClient.get('/auth/$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

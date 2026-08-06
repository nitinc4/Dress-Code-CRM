import 'dart:convert';
import '../network/api_client.dart';

class AttendanceService {
  static Future<Map<String, dynamic>> checkIn(String userId, {String? location}) async {
    try {
      final response = await ApiClient.post('/attendance/check-in', {
        'userId': userId,
        'location': location ?? 'Factory - Unit 1, Bangalore, India',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Check-in failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkOut(String userId) async {
    try {
      final response = await ApiClient.post('/attendance/check-out', {
        'userId': userId,
      });
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Check-out failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getUserAttendance(String userId) async {
    try {
      final response = await ApiClient.get('/attendance/user/$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

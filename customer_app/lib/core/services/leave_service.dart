import 'dart:convert';
import '../network/api_client.dart';

class LeaveService {
  static Future<Map<String, dynamic>> applyLeave({
    required String userId,
    required String leaveType,
    required String fromDate,
    required String toDate,
    required int noOfDays,
    required String reason,
  }) async {
    try {
      final response = await ApiClient.post('/leave/apply', {
        'userId': userId,
        'leaveType': leaveType,
        'fromDate': fromDate,
        'toDate': toDate,
        'noOfDays': noOfDays,
        'reason': reason,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to apply leave'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getUserLeaves(String userId) async {
    try {
      final response = await ApiClient.get('/leave/user/$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getAllLeaves() async {
    try {
      final response = await ApiClient.get('/leave/all');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

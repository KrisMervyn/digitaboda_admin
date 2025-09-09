import 'dart:convert';
import 'package:http/http.dart' as http;

class EnumeratorService {
  static const String baseUrl = 'http://192.168.1.19:8000/api';
  
  // Store enumerator credentials for authentication
  static String? _enumeratorUsername;
  static String? _enumeratorPassword;

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enumerator/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _enumeratorUsername = username;
        _enumeratorPassword = password;
        
        final responseData = jsonDecode(response.body);
        print('🔍 Service: Raw response = $responseData');
        
        // Extract the actual enumerator data from Django response
        final enumeratorData = responseData['data'] ?? responseData;
        print('📊 Service: Extracted enumerator data = $enumeratorData');
        
        return {
          'success': true,
          'data': enumeratorData,  // Return just the enumerator data, not the whole response
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static String? _getAuthHeader() {
    if (_enumeratorUsername == null || _enumeratorPassword == null) {
      return null;
    }
    
    String credentials = '$_enumeratorUsername:$_enumeratorPassword';
    String encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final authHeader = _getAuthHeader();
      if (authHeader == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/enumerator/dashboard/stats/'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load dashboard stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getAssignedRiders() async {
    try {
      final authHeader = _getAuthHeader();
      if (authHeader == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/enumerator/assigned-riders/'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load assigned riders',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getPendingRiders() async {
    try {
      final authHeader = _getAuthHeader();
      if (authHeader == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/enumerator/pending-riders/'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load pending riders',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> approveRider(int riderId, {String notes = ''}) async {
    try {
      final authHeader = _getAuthHeader();
      if (authHeader == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/enumerator/rider/$riderId/approve/'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to approve rider',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> rejectRider(int riderId, String reason) async {
    try {
      final authHeader = _getAuthHeader();
      if (authHeader == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/enumerator/rider/$riderId/reject/'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reason': reason,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to reject rider',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static void logout() {
    _enumeratorUsername = null;
    _enumeratorPassword = null;
  }
}
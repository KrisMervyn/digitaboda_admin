import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class EnumeratorService {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  // Store enumerator credentials for authentication
  static String? _enumeratorUsername;
  static String? _enumeratorPassword;

  static Future<Map<String, dynamic>> login({
    String? username,
    String? enumeratorId,
    required String password,
  }) async {
    try {
      // Prepare request body
      Map<String, dynamic> requestBody = {'password': password};
      if (enumeratorId != null) {
        requestBody['enumeratorId'] = enumeratorId;
      } else if (username != null) {
        requestBody['username'] = username;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/enumerator/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('🔍 Service: Raw response = $responseData');
        
        // Extract the actual enumerator data from Django response
        final enumeratorData = responseData['data'] ?? responseData;
        
        // Store the enumerator ID for future API calls (backend expects EN-XXXX format for auth)
        _enumeratorUsername = enumeratorData['unique_id'] ?? enumeratorData['uniqueId'] ?? (enumeratorId ?? username!);
        _enumeratorPassword = password;
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

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final authHeader = _getAuthHeader();
      if (authHeader == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/enumerator/change-password/'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Update stored password for future requests
        _enumeratorPassword = newPassword;
        
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Training-related methods
  static Future<Map<String, dynamic>> getTrainingStudents() async {
    try {
      final authHeader = _getAuthHeader();
      if (authHeader == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/training/trainer/students/?trainer_id=$_enumeratorUsername'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load training students',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getAvailableModules() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/training/modules/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load training modules',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> markStudentAttendance({
    required String studentPhone,
    required int sessionId,
    required String status,
    required String sessionDate,
    String? notes,
  }) async {
    try {
      final authHeader = _getAuthHeader();
      if (authHeader == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/training/trainer/mark-attendance/'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'trainer_id': _enumeratorUsername,
          'student_phone': studentPhone,
          'session_id': sessionId,
          'status': status,
          'session_date': sessionDate,
          'notes': notes ?? '',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to mark attendance',
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
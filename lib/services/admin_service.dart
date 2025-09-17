import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl = 'http://192.168.1.19:8000/api';
  
  // Store admin credentials for authentication
  static String? _adminUsername;
  static String? _adminPassword;
  static String? _authToken;

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('🚀 Attempting admin login to: $baseUrl/auth/admin/login/');
      print('📱 Username: $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/admin/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        _adminUsername = username;
        _adminPassword = password;
        
        // Store the auth token from login response
        final responseData = jsonDecode(response.body);
        _authToken = responseData['token'];
        
        print('✅ Login successful!');
        print('🔑 Token stored: ${_authToken?.substring(0, 10)}...');
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        print('❌ Login failed with status: ${response.statusCode}');
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('💥 Exception during login: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Map<String, String> _getAuthHeaders() {
    if (_authToken == null) {
      throw Exception('Admin not authenticated - no token available');
    }
    
    return {
      'Authorization': 'Token $_authToken',
      'Content-Type': 'application/json',
    };
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard/stats/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to get stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getPendingRiders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/pending-riders/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to get pending riders',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getPendingRidersByEnumerator() async {
    try {
      print('📞 Fetching pending riders by enumerator...');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/pending-riders-by-enumerator/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched pending riders by enumerator: ${data['data']['total_pending']} total');
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get pending riders by enumerator';
        print('❌ Error fetching pending riders by enumerator: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getPendingRidersByEnumerator: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getRiderDetails(int riderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/rider/$riderId/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to get rider details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> approveRider(int riderId, {String notes = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/rider/$riderId/approve/'),
        headers: _getAuthHeaders(),
        body: jsonEncode({
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to approve rider',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> rejectRider(int riderId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/rider/$riderId/reject/'),
        headers: _getAuthHeaders(),
        body: jsonEncode({
          'reason': reason,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to reject rider',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  // Enumerator management methods
  static Future<Map<String, dynamic>> getAllEnumerators() async {
    try {
      print('🔍 Fetching enumerators from: $baseUrl/admin/enumerators/');
      print('🔑 Using auth headers: ${_getAuthHeaders()}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/enumerators/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error'] ?? errorBody['detail'] ?? 'Failed to get enumerators',
        };
      }
    } catch (e) {
      print('❌ Error fetching enumerators: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getEnumeratorDetails(String enumeratorId) async {
    try {
      print('🔍 Fetching enumerator details for: $enumeratorId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/enumerator/$enumeratorId/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error'] ?? errorBody['detail'] ?? 'Failed to get enumerator details',
        };
      }
    } catch (e) {
      print('❌ Error fetching enumerator details: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> createEnumerator(Map<String, dynamic> enumeratorData) async {
    try {
      print('🆕 Creating enumerator with data: $enumeratorData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/admin/enumerator/create/'),
        headers: _getAuthHeaders(),
        body: jsonEncode(enumeratorData),
      ).timeout(const Duration(seconds: 10));

      print('📡 Create response status: ${response.statusCode}');
      print('📄 Create response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error'] ?? errorBody['detail'] ?? 'Failed to create enumerator',
        };
      }
    } catch (e) {
      print('❌ Error creating enumerator: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> updateEnumerator(String enumeratorId, Map<String, dynamic> updates) async {
    try {
      print('✏️ Updating enumerator $enumeratorId with: $updates');
      
      final response = await http.put(
        Uri.parse('$baseUrl/admin/enumerator/$enumeratorId/update/'),
        headers: _getAuthHeaders(),
        body: jsonEncode(updates),
      ).timeout(const Duration(seconds: 10));

      print('📡 Update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error'] ?? errorBody['detail'] ?? 'Failed to update enumerator',
        };
      }
    } catch (e) {
      print('❌ Error updating enumerator: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteEnumerator(String enumeratorId) async {
    try {
      print('🗑️ Deleting enumerator: $enumeratorId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/enumerator/$enumeratorId/delete/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('📡 Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Enumerator deleted successfully',
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error'] ?? errorBody['detail'] ?? 'Failed to delete enumerator',
        };
      }
    } catch (e) {
      print('❌ Error deleting enumerator: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> searchEnumerators(String query) async {
    try {
      print('🔍 Searching enumerators with query: $query');
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/enumerators/search/?q=${Uri.encodeComponent(query)}'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('📡 Search response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error'] ?? errorBody['detail'] ?? 'Search failed',
        };
      }
    } catch (e) {
      print('❌ Error searching enumerators: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static void logout() {
    _adminUsername = null;
    _adminPassword = null;
  }

  static bool get isAuthenticated {
    return _adminUsername != null && _adminPassword != null;
  }
}
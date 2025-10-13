import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class PhotoVerificationService {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  // Store authentication token
  static String? _authToken;

  /// Login enumerator and get authentication token
  static Future<Map<String, dynamic>> loginEnumerator({
    required String phoneNumber,
    required String enumeratorId,
    required String password,
  }) async {
    print('🔐 Logging in enumerator: $phoneNumber');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/enumerator/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'enumerator_id': enumeratorId,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Login response: ${response.statusCode}');
      print('📄 Login body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        return {
          'success': true,
          'data': data,
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet.',
      };
    }
  }

  /// Login admin and get authentication token
  static Future<Map<String, dynamic>> loginAdmin({
    required String username,
    required String password,
  }) async {
    print('🔐 Logging in admin: $username');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/admin/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Admin login response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        return {
          'success': true,
          'data': data,
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Admin login error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet.',
      };
    }
  }

  /// Get riders pending photo verification
  static Future<Map<String, dynamic>> getPendingPhotoVerifications() async {
    if (_authToken == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/enumerator/pending-photo-verification/'),
        headers: {
          'Authorization': 'Token $_authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📸 Pending verifications response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 401) {
        _authToken = null; // Clear invalid token
        return {
          'success': false,
          'error': 'Authentication expired. Please login again.',
          'need_login': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load pending verifications',
        };
      }
    } catch (e) {
      print('❌ Pending verifications error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet.',
      };
    }
  }

  /// Run photo verification for a rider
  static Future<Map<String, dynamic>> verifyRiderPhotos(int riderId) async {
    if (_authToken == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    print('📸 Verifying photos for rider: $riderId');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/riders/$riderId/verify-photos/'),
        headers: {
          'Authorization': 'Token $_authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30)); // Longer timeout for AI processing

      print('📸 Verification response: ${response.statusCode}');
      print('📄 Verification body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 401) {
        _authToken = null;
        return {
          'success': false,
          'error': 'Authentication expired. Please login again.',
          'need_login': true,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Photo verification failed',
        };
      }
    } catch (e) {
      print('❌ Verification error: $e');
      return {
        'success': false,
        'error': 'Connection failed during verification. Please try again.',
      };
    }
  }

  /// Get photo verification report for a rider
  static Future<Map<String, dynamic>> getPhotoVerificationReport(int riderId) async {
    if (_authToken == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/riders/$riderId/photo-verification-report/'),
        headers: {
          'Authorization': 'Token $_authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 401) {
        _authToken = null;
        return {
          'success': false,
          'error': 'Authentication expired. Please login again.',
          'need_login': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get verification report',
        };
      }
    } catch (e) {
      print('❌ Report error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet.',
      };
    }
  }

  /// Manually approve/reject photo verification
  static Future<Map<String, dynamic>> approvePhotoVerification({
    required int riderId,
    required String action, // 'approve', 'reject', 'flag'
    String notes = '',
  }) async {
    if (_authToken == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    print('📸 ${action.toUpperCase()} photos for rider: $riderId');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/riders/$riderId/approve-photos/'),
        headers: {
          'Authorization': 'Token $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': action,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📸 Approval response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 401) {
        _authToken = null;
        return {
          'success': false,
          'error': 'Authentication expired. Please login again.',
          'need_login': true,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to $action verification',
        };
      }
    } catch (e) {
      print('❌ Approval error: $e');
      return {
        'success': false,
        'error': 'Connection failed during approval. Please try again.',
      };
    }
  }

  /// Get photo verification statistics (Admin only)
  static Future<Map<String, dynamic>> getPhotoVerificationStats() async {
    if (_authToken == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/photo-verification-stats/'),
        headers: {
          'Authorization': 'Token $_authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 401) {
        _authToken = null;
        return {
          'success': false,
          'error': 'Authentication expired. Please login again.',
          'need_login': true,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Admin access required for statistics',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load statistics',
        };
      }
    } catch (e) {
      print('❌ Stats error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet.',
      };
    }
  }

  /// Verify token is still valid
  static Future<bool> verifyToken() async {
    if (_authToken == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify-token/'),
        headers: {
          'Authorization': 'Token $_authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Token verification error: $e');
      return false;
    }
  }

  /// Logout user
  static Future<void> logout() async {
    if (_authToken != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/logout/'),
          headers: {
            'Authorization': 'Token $_authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        print('❌ Logout error: $e');
      }
    }
    _authToken = null;
  }

  /// Get current auth token
  static String? get authToken => _authToken;
  
  /// Set auth token (for testing or manual login)
  static void setAuthToken(String? token) {
    _authToken = token;
  }
}

/// Models for photo verification data
class PendingRider {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String uniqueId;
  final String photoVerificationStatus;
  final double? faceMatchScore;
  final String status;
  final DateTime createdAt;
  final bool hasProfilePhoto;
  final bool hasIdPhoto;
  final EnumeratorInfo? assignedEnumerator;

  PendingRider({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.uniqueId,
    required this.photoVerificationStatus,
    this.faceMatchScore,
    required this.status,
    required this.createdAt,
    required this.hasProfilePhoto,
    required this.hasIdPhoto,
    this.assignedEnumerator,
  });

  factory PendingRider.fromJson(Map<String, dynamic> json) {
    final hasPhotos = json['has_photos'] ?? {};
    
    return PendingRider(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      uniqueId: json['unique_id'] ?? '',
      photoVerificationStatus: json['photo_verification_status'] ?? 'PENDING',
      faceMatchScore: json['face_match_score']?.toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      hasProfilePhoto: hasPhotos['profile_photo'] ?? false,
      hasIdPhoto: hasPhotos['id_document_photo'] ?? false,
      assignedEnumerator: json['assigned_enumerator'] != null
          ? EnumeratorInfo.fromJson(json['assigned_enumerator'])
          : null,
    );
  }

  bool get hasAllPhotos => hasProfilePhoto && hasIdPhoto;
  
  String get statusText {
    switch (photoVerificationStatus.toUpperCase()) {
      case 'VERIFIED': return 'Verified ✅';
      case 'REJECTED': return 'Rejected ❌';
      case 'FLAGGED': return 'Flagged 🚩';
      case 'PENDING': return 'Pending ⏳';
      default: return 'Unknown';
    }
  }
}

class EnumeratorInfo {
  final int id;
  final String uniqueId;
  final String name;

  EnumeratorInfo({
    required this.id,
    required this.uniqueId,
    required this.name,
  });

  factory EnumeratorInfo.fromJson(Map<String, dynamic> json) {
    return EnumeratorInfo(
      id: json['id'] ?? 0,
      uniqueId: json['unique_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class PhotoVerificationStats {
  final int totalRiders;
  final int ridersWithPhotos;
  final double photoCoveragePercentage;
  final Map<String, int> verificationStatus;
  final double averageFaceMatchScore;

  PhotoVerificationStats({
    required this.totalRiders,
    required this.ridersWithPhotos,
    required this.photoCoveragePercentage,
    required this.verificationStatus,
    required this.averageFaceMatchScore,
  });

  factory PhotoVerificationStats.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] ?? {};
    final status = Map<String, int>.from(json['verification_status'] ?? {});
    final performance = json['performance'] ?? {};

    return PhotoVerificationStats(
      totalRiders: overview['total_riders'] ?? 0,
      ridersWithPhotos: overview['riders_with_photos'] ?? 0,
      photoCoveragePercentage: overview['photo_coverage_percentage']?.toDouble() ?? 0.0,
      verificationStatus: status,
      averageFaceMatchScore: performance['average_face_match_score']?.toDouble() ?? 0.0,
    );
  }

  int get pendingCount => verificationStatus['PENDING'] ?? 0;
  int get verifiedCount => verificationStatus['VERIFIED'] ?? 0;
  int get rejectedCount => verificationStatus['REJECTED'] ?? 0;
  int get flaggedCount => verificationStatus['FLAGGED'] ?? 0;
}
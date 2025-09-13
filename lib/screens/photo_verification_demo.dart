import 'package:flutter/material.dart';
import '../services/photo_verification_service.dart';
import 'photo_verification_screen.dart';
import 'photo_verification_dashboard.dart';

class PhotoVerificationDemo extends StatefulWidget {
  const PhotoVerificationDemo({Key? key}) : super(key: key);

  @override
  State<PhotoVerificationDemo> createState() => _PhotoVerificationDemoState();
}

class _PhotoVerificationDemoState extends State<PhotoVerificationDemo> {
  String? _authToken;
  String? _userType;
  String? _username;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Photo Verification Admin Demo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🛡️ Admin Photo Verification System',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage and oversee AI-powered photo verification',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            if (_authToken == null) ...[
              _buildLoginSection(),
            ] else ...[
              _buildLoggedInSection(),
            ],
            
            const SizedBox(height: 20),
            _buildQuickTestSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👨‍💼 Enumerator Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginEnumerator,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Logging in...'),
                          ],
                        )
                      : const Text('Login as Test Enumerator'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Phone: +256700000003 | ID: EN-2025-0003 | Password: password123',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔑 Admin Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Login as Admin'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Username: admin | Password: admin123',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInSection() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _userType == 'admin' ? Icons.admin_panel_settings : Icons.person_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logged in as $_userType',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'User: $_username',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '🔧 Verification Tools',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _openVerificationScreen,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Manage Photo Verifications'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                if (_userType == 'admin')
                  ElevatedButton.icon(
                    onPressed: _openDashboard,
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Admin Dashboard & Statistics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Quick Test (No Login Required)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Test with pre-configured admin access',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _quickTestVerification,
                    icon: const Icon(Icons.search),
                    label: const Text('Verification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _quickTestDashboard,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginEnumerator() async {
    setState(() => _isLoading = true);

    try {
      final result = await PhotoVerificationService.loginEnumerator(
        phoneNumber: '+256700000003',
        enumeratorId: 'EN-2025-0003',
        password: 'password123',
      );

      if (result['success'] == true) {
        setState(() {
          _authToken = result['token'];
          _userType = 'enumerator';
          _username = result['data']['username'] ?? 'Test Enumerator';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enumerator login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        _showErrorDialog(result['error'] ?? 'Enumerator login failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Connection error: $e');
    }
  }

  Future<void> _loginAdmin() async {
    setState(() => _isLoading = true);

    try {
      final result = await PhotoVerificationService.loginAdmin(
        username: 'admin',
        password: 'admin123',
      );

      if (result['success'] == true) {
        setState(() {
          _authToken = result['token'];
          _userType = 'admin';
          _username = result['data']['username'] ?? 'admin';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        _showErrorDialog(result['error'] ?? 'Admin login failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Connection error: $e');
    }
  }

  void _logout() {
    PhotoVerificationService.logout();
    setState(() {
      _authToken = null;
      _userType = null;
      _username = null;
    });
  }

  void _openVerificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoVerificationScreen(),
      ),
    );
  }

  void _openDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoVerificationDashboard(),
      ),
    );
  }

  void _quickTestVerification() {
    PhotoVerificationService.setAuthToken('9747b478ad547e33cd4a4cbb95f10580cbc5a47e');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoVerificationScreen(),
      ),
    );
  }

  void _quickTestDashboard() {
    PhotoVerificationService.setAuthToken('9747b478ad547e33cd4a4cbb95f10580cbc5a47e');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoVerificationDashboard(),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
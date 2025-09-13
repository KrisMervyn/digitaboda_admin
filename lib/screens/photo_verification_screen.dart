import 'package:flutter/material.dart';
import '../services/photo_verification_service.dart';

class PhotoVerificationScreen extends StatefulWidget {
  const PhotoVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PhotoVerificationScreen> createState() => _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  List<PendingRider> _pendingRiders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingVerifications();
  }

  Future<void> _loadPendingVerifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await PhotoVerificationService.getPendingPhotoVerifications();

      if (result['success'] == true) {
        final data = result['data'];
        final riders = (data['riders'] as List)
            .map((json) => PendingRider.fromJson(json))
            .toList();

        setState(() {
          _pendingRiders = riders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load pending verifications';
          _isLoading = false;
        });

        if (result['need_login'] == true) {
          _showLoginRequiredDialog();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyRiderPhotos(PendingRider rider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verifying Photos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Running AI verification...'),
            Text('This may take a few seconds'),
          ],
        ),
      ),
    );

    try {
      final result = await PhotoVerificationService.verifyRiderPhotos(rider.id);
      
      Navigator.of(context).pop(); // Close loading dialog

      if (result['success'] == true) {
        final data = result['data'];
        _showVerificationResultDialog(rider, data);
        _loadPendingVerifications(); // Refresh list
      } else {
        _showErrorDialog(result['error'] ?? 'Verification failed');
        
        if (result['need_login'] == true) {
          _showLoginRequiredDialog();
        }
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('Connection error during verification');
    }
  }

  void _showVerificationResultDialog(PendingRider rider, Map<String, dynamic> data) {
    final status = data['status'] ?? 'UNKNOWN';
    final overallScore = (data['overall_score'] ?? 0.0).toDouble();
    final summary = data['summary'] ?? {};

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toString().toUpperCase()) {
      case 'VERIFIED':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        statusText = 'Verified ✅';
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejected ❌';
        break;
      case 'FLAGGED':
        statusColor = Colors.orange;
        statusIcon = Icons.flag;
        statusText = 'Flagged for Review 🚩';
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.help;
        statusText = 'Unknown Status';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 8),
            Text('Verification Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rider: ${rider.fullName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: $statusText',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('Overall Score: ${(overallScore * 100).toInt()}%'),
            const SizedBox(height: 12),
            const Text('Checks:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildCheckItem('Profile Authentic', summary['profile_authentic'] ?? false),
            _buildCheckItem('ID Authentic', summary['id_authentic'] ?? false),
            _buildCheckItem('Faces Match', summary['faces_match'] ?? false),
            _buildCheckItem('ID Extracted', summary['id_extracted'] ?? false),
            if (summary['cross_verified'] != null)
              _buildCheckItem('ID Cross-Verified', summary['cross_verified'] ?? false),
          ],
        ),
        actions: [
          if (status == 'FLAGGED') ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showApprovalDialog(rider);
              },
              child: const Text('Review'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            color: passed ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showApprovalDialog(PendingRider rider) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Review ${rider.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Manual Review Decision:'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any additional notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _approveRider(rider, 'reject', notesController.text);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _approveRider(rider, 'flag', notesController.text);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Keep Flagged'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _approveRider(rider, 'approve', notesController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRider(PendingRider rider, String action, String notes) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('${action.toUpperCase()}ing...'),
        content: const CircularProgressIndicator(),
      ),
    );

    try {
      final result = await PhotoVerificationService.approvePhotoVerification(
        riderId: rider.id,
        action: action,
        notes: notes,
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${rider.fullName} ${action}d successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingVerifications(); // Refresh list
      } else {
        _showErrorDialog(result['error'] ?? 'Failed to $action rider');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog('Connection error during $action');
    }
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

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Verification'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingVerifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _pendingRiders.isEmpty
                  ? _buildEmptyWidget()
                  : _buildRidersList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPendingVerifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            Text(
              'All Caught Up! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No riders pending photo verification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRidersList() {
    return RefreshIndicator(
      onRefresh: _loadPendingVerifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _pendingRiders.length,
        itemBuilder: (context, index) {
          final rider = _pendingRiders[index];
          return _buildRiderCard(rider);
        },
      ),
    );
  }

  Widget _buildRiderCard(PendingRider rider) {
    Color statusColor;
    IconData statusIcon;

    switch (rider.photoVerificationStatus.toUpperCase()) {
      case 'VERIFIED':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'FLAGGED':
        statusColor = Colors.orange;
        statusIcon = Icons.flag;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(statusIcon, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rider.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        rider.phoneNumber,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  rider.statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  rider.hasProfilePhoto ? Icons.check_circle : Icons.cancel,
                  color: rider.hasProfilePhoto ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text('Profile Photo'),
                const SizedBox(width: 16),
                Icon(
                  rider.hasIdPhoto ? Icons.check_circle : Icons.cancel,
                  color: rider.hasIdPhoto ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text('ID Photo'),
              ],
            ),
            if (rider.faceMatchScore != null) ...[
              const SizedBox(height: 8),
              Text(
                'Face Match: ${(rider.faceMatchScore! * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!rider.hasAllPhotos)
                  Text(
                    'Missing photos',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 12,
                    ),
                  )
                else ...[
                  TextButton.icon(
                    onPressed: () => _verifyRiderPhotos(rider),
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Verify Photos'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showApprovalDialog(rider),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Manual Review'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
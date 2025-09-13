import 'package:flutter/material.dart';
import '../services/photo_verification_service.dart';

class PhotoVerificationDashboard extends StatefulWidget {
  const PhotoVerificationDashboard({Key? key}) : super(key: key);

  @override
  State<PhotoVerificationDashboard> createState() => _PhotoVerificationDashboardState();
}

class _PhotoVerificationDashboardState extends State<PhotoVerificationDashboard> {
  PhotoVerificationStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await PhotoVerificationService.getPhotoVerificationStats();

      if (result['success'] == true) {
        setState(() {
          _stats = PhotoVerificationStats.fromJson(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load statistics';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Photo Verification Dashboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _stats != null
                  ? _buildDashboard()
                  : _buildNoDataWidget(),
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
              'Error Loading Dashboard',
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
              onPressed: _loadStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dashboard statistics are not available',
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

  Widget _buildDashboard() {
    if (_stats == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 20),
            _buildVerificationStatusCard(),
            const SizedBox(height: 20),
            _buildPerformanceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Riders',
                _stats!.totalRiders.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'With Photos',
                _stats!.ridersWithPhotos.toString(),
                Icons.photo_camera,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Photo Coverage',
          '${_stats!.photoCoveragePercentage.toStringAsFixed(1)}%',
          Icons.bar_chart,
          Colors.orange,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusRow('Pending', _stats!.pendingCount, Colors.blue, Icons.pending),
            const SizedBox(height: 8),
            _buildStatusRow('Verified', _stats!.verifiedCount, Colors.green, Icons.verified),
            const SizedBox(height: 8),
            _buildStatusRow('Flagged', _stats!.flaggedCount, Colors.orange, Icons.flag),
            const SizedBox(height: 8),
            _buildStatusRow('Rejected', _stats!.rejectedCount, Colors.red, Icons.cancel),
            const SizedBox(height: 16),
            _buildStatusChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color, IconData icon) {
    final totalCount = _stats!.totalRiders;
    final percentage = totalCount > 0 ? (count / totalCount * 100) : 0.0;

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          '$count (${percentage.toStringAsFixed(1)}%)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChart() {
    final totalCount = _stats!.totalRiders;
    if (totalCount == 0) {
      return Container(
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text('No Data', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    final pendingPct = _stats!.pendingCount / totalCount;
    final verifiedPct = _stats!.verifiedCount / totalCount;
    final flaggedPct = _stats!.flaggedCount / totalCount;
    final rejectedPct = _stats!.rejectedCount / totalCount;

    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Row(
          children: [
            if (pendingPct > 0)
              Flexible(
                flex: (_stats!.pendingCount * 1000).round(),
                child: Container(color: Colors.blue),
              ),
            if (verifiedPct > 0)
              Flexible(
                flex: (_stats!.verifiedCount * 1000).round(),
                child: Container(color: Colors.green),
              ),
            if (flaggedPct > 0)
              Flexible(
                flex: (_stats!.flaggedCount * 1000).round(),
                child: Container(color: Colors.orange),
              ),
            if (rejectedPct > 0)
              Flexible(
                flex: (_stats!.rejectedCount * 1000).round(),
                child: Container(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceRow(
              'Average Face Match Score',
              '${(_stats!.averageFaceMatchScore * 100).toStringAsFixed(1)}%',
              _stats!.averageFaceMatchScore,
            ),
            const SizedBox(height: 12),
            _buildPerformanceRow(
              'Photo Coverage Rate',
              '${_stats!.photoCoveragePercentage.toStringAsFixed(1)}%',
              _stats!.photoCoveragePercentage / 100,
            ),
            if (_stats!.totalRiders > 0) ...[
              const SizedBox(height: 12),
              _buildPerformanceRow(
                'Verification Success Rate',
                '${((_stats!.verifiedCount / _stats!.totalRiders) * 100).toStringAsFixed(1)}%',
                _stats!.verifiedCount / _stats!.totalRiders,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value, double progress) {
    Color progressColor = progress >= 0.8 
        ? Colors.green 
        : progress >= 0.5 
            ? Colors.orange 
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      ],
    );
  }
}
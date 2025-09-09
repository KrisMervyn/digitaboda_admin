import 'package:flutter/material.dart';
import '../services/enumerator_service.dart';
import 'enumerator_pending_riders_screen.dart';

class EnumeratorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> enumeratorInfo;
  
  const EnumeratorDashboardScreen({
    Key? key,
    required this.enumeratorInfo,
  }) : super(key: key);

  @override
  State<EnumeratorDashboardScreen> createState() => _EnumeratorDashboardScreenState();
}

class _EnumeratorDashboardScreenState extends State<EnumeratorDashboardScreen> {
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Debug: Print the enumerator info received
    print('🏠 Dashboard - Enumerator Info received: ${widget.enumeratorInfo}');
    print('🔍 Dashboard - Available keys: ${widget.enumeratorInfo?.keys.toList()}');
    
    // Check specific fields
    final info = widget.enumeratorInfo ?? {};
    print('📋 Dashboard - Field check:');
    print('   fullName: ${info['fullName']}');
    print('   full_name: ${info['full_name']}');
    print('   name: ${info['name']}');
    print('   uniqueId: ${info['uniqueId']}');
    print('   unique_id: ${info['unique_id']}');
    print('   location: ${info['location']}');
    
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      Map<String, dynamic> result = await EnumeratorService.getDashboardStats();
      
      if (result['success']) {
        setState(() {
          _dashboardStats = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load dashboard stats';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enumerator Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadDashboardStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                EnumeratorService.logout();
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadDashboardStats,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Enumerator Info Card - Compact
                        Flexible(
                          flex: 2,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 36,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final info = widget.enumeratorInfo ?? {};
                                            final name = info['full_name'] ?? 
                                                        info['fullName'] ?? 
                                                        info['name'] ?? 
                                                        info['username'] ?? 
                                                        '${info['firstName'] ?? info['first_name'] ?? ''} ${info['lastName'] ?? info['last_name'] ?? ''}'.trim();
                                            
                                            // Debug print
                                            print('🏠 Main card name lookup: ${name.isEmpty ? 'EMPTY' : name}');
                                            print('🔍 Available name fields: ${info.keys.where((k) => k.toLowerCase().contains('name')).toList()}');
                                            
                                            return Text(
                                              name.isEmpty ? 'Enumerator' : name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 4),
                                        Builder(
                                          builder: (context) {
                                            final info = widget.enumeratorInfo ?? {};
                                            final id = info['unique_id'] ?? 
                                                      info['uniqueId'] ?? 
                                                      info['enumerator_id'] ?? 
                                                      info['id']?.toString() ?? 
                                                      'N/A';
                                            
                                            // Debug print
                                            print('🏠 Main card ID lookup: $id');
                                            print('🔍 Available ID fields: ${info.keys.where((k) => k.toLowerCase().contains('id')).toList()}');
                                            
                                            return Text(
                                              'ID: $id',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '📍 ${widget.enumeratorInfo['location'] ?? widget.enumeratorInfo['area'] ?? widget.enumeratorInfo['region'] ?? 'Unknown Location'}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Statistics Grid
                        Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.2,
                                  children: [
                                    _buildStatCard(
                                      'Area Allocated',
                                      '${_dashboardStats?['areaAllocated'] ?? _dashboardStats?['totalAssigned'] ?? 0}',
                                      Icons.location_on,
                                      const Color(0xFF3498DB),
                                    ),
                                    _buildStatCard(
                                      'Pending Approval',
                                      '${_dashboardStats?['pendingApproval'] ?? 0}',
                                      Icons.pending,
                                      const Color(0xFFF39C12),
                                    ),
                                    _buildStatCard(
                                      'Approved',
                                      '${_dashboardStats?['approvedRiders'] ?? 0}',
                                      Icons.check_circle,
                                      const Color(0xFF27AE60),
                                    ),
                                    _buildStatCard(
                                      'Approval Rate',
                                      '${_dashboardStats?['approvalRate']?.toStringAsFixed(1) ?? '0'}%',
                                      Icons.trending_up,
                                      const Color(0xFF9B59B6),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const EnumeratorPendingRidersScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.pending_actions, size: 20),
                                label: const Text(
                                  'Review Pending',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF39C12),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to all assigned riders
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('All assigned riders screen coming soon!'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.people_outline, size: 20),
                                label: const Text(
                                  'All Riders',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3498DB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

}
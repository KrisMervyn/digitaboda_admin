import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import 'admin_rider_review_screen.dart';

class AdminPendingRidersByEnumeratorScreen extends StatefulWidget {
  const AdminPendingRidersByEnumeratorScreen({Key? key}) : super(key: key);

  @override
  State<AdminPendingRidersByEnumeratorScreen> createState() => _AdminPendingRidersByEnumeratorScreenState();
}

class _AdminPendingRidersByEnumeratorScreenState extends State<AdminPendingRidersByEnumeratorScreen> {
  List<dynamic> _enumeratorGroups = [];
  int _totalPending = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPendingRidersByEnumerator();
  }

  Future<void> _loadPendingRidersByEnumerator() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      Map<String, dynamic> result = await AdminService.getPendingRidersByEnumerator();
      
      if (result['success']) {
        setState(() {
          _enumeratorGroups = result['data']['enumerator_groups'] ?? [];
          _totalPending = result['data']['total_pending'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load pending riders by enumerator';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load pending riders by enumerator';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Pending by Enumerator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPendingRidersByEnumerator,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C3E50)),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadPendingRidersByEnumerator,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : _enumeratorGroups.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Pending Applications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF636E72),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'All applications have been reviewed',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF636E72),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header Stats
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF39C12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Pending Applications',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_totalPending',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Enumerators',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_enumeratorGroups.length}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Enumerator Groups List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _enumeratorGroups.length,
                            itemBuilder: (context, index) {
                              final group = _enumeratorGroups[index];
                              return _buildEnumeratorGroup(group);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildEnumeratorGroup(Map<String, dynamic> group) {
    final enumerator = group['enumerator'];
    final riders = group['pending_riders'] as List<dynamic>;
    final count = group['count'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF9B59B6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            enumerator['id'] == 'unassigned' ? Icons.group : Icons.person,
            color: const Color(0xFF9B59B6),
            size: 24,
          ),
        ),
        title: Text(
          enumerator['full_name'] ?? 'Unknown Enumerator',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              enumerator['unique_id'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count pending',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF39C12),
                ),
              ),
            ),
          ],
        ),
        children: riders.map<Widget>((rider) => _buildRiderListItem(rider)).toList(),
      ),
    );
  }

  Widget _buildRiderListItem(Map<String, dynamic> rider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminRiderReviewScreen(
                riderId: rider['id'],
                riderData: rider,
              ),
            ),
          ).then((_) => _loadPendingRidersByEnumerator()); // Refresh when coming back
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and phone
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF3498DB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rider['fullName'] ?? 'Unknown Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        rider['phoneNumber'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF39C12).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF39C12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Details Row
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Experience',
                    rider['experienceLevel'] ?? 'Unknown',
                    Icons.work,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Age',
                    rider['age']?.toString() ?? 'N/A',
                    Icons.cake,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Reference and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ref: ${rider['referenceNumber'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF636E72),
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Submitted: ${_formatDate(rider['submittedAt'] ?? '')}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Review Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AdminRiderReviewScreen(
                        riderId: rider['id'],
                        riderData: rider,
                      ),
                    ),
                  ).then((_) => _loadPendingRidersByEnumerator());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Review Application',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF636E72),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF636E72),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
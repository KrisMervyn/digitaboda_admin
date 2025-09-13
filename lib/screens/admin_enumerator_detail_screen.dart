import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import 'admin_enumerator_form_screen.dart';

class AdminEnumeratorDetailScreen extends StatefulWidget {
  final String enumeratorId;
  final Map<String, dynamic>? enumeratorData;

  const AdminEnumeratorDetailScreen({
    Key? key,
    required this.enumeratorId,
    this.enumeratorData,
  }) : super(key: key);

  @override
  State<AdminEnumeratorDetailScreen> createState() => _AdminEnumeratorDetailScreenState();
}

class _AdminEnumeratorDetailScreenState extends State<AdminEnumeratorDetailScreen> {
  Map<String, dynamic>? _enumerator;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.enumeratorData != null) {
      _enumerator = widget.enumeratorData;
    } else {
      _loadEnumeratorDetails();
    }
  }

  Future<void> _loadEnumeratorDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await AdminService.getEnumeratorDetails(widget.enumeratorId);
      
      if (result['success']) {
        setState(() {
          _enumerator = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load enumerator details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load enumerator details: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToEditEnumerator() {
    if (_enumerator != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminEnumeratorFormScreen(
            isEditing: true,
            enumeratorData: _enumerator!,
          ),
        ),
      ).then((_) => _loadEnumeratorDetails());
    }
  }

  Future<void> _toggleActiveStatus() async {
    if (_enumerator == null) return;

    try {
      final newStatus = !(_enumerator!['is_active'] ?? false);
      final result = await AdminService.updateEnumerator(
        widget.enumeratorId,
        {'is_active': newStatus},
      );

      if (result['success']) {
        setState(() {
          _enumerator!['is_active'] = newStatus;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Enumerator ${newStatus ? 'activated' : 'deactivated'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteEnumerator() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Enumerator'),
          content: Text(
            'Are you sure you want to delete ${_enumerator!['first_name']} ${_enumerator!['last_name']}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final result = await AdminService.deleteEnumerator(widget.enumeratorId);
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enumerator deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to delete enumerator'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _enumerator != null 
              ? '${_enumerator!['first_name'] ?? ''} ${_enumerator!['last_name'] ?? ''}'
              : 'Enumerator Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_enumerator != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditEnumerator,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle_status') {
                  _toggleActiveStatus();
                } else if (value == 'delete') {
                  _deleteEnumerator();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'toggle_status',
                  child: Row(
                    children: [
                      Icon(
                        (_enumerator!['is_active'] ?? false) 
                            ? Icons.pause_circle_outline 
                            : Icons.play_circle_outline,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (_enumerator!['is_active'] ?? false) 
                            ? 'Deactivate' 
                            : 'Activate',
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
                        onPressed: _loadEnumeratorDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _enumerator == null
                  ? const Center(
                      child: Text(
                        'No enumerator data found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 50,
                                    child: Text(
                                      '${_enumerator!['first_name']?[0] ?? ''}${_enumerator!['last_name']?[0] ?? ''}',
                                      style: const TextStyle(
                                        color: Color(0xFF2C3E50),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${_enumerator!['first_name'] ?? ''} ${_enumerator!['last_name'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ID: ${_enumerator!['unique_id'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (_enumerator!['is_active'] ?? false)
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: (_enumerator!['is_active'] ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    child: Text(
                                      (_enumerator!['is_active'] ?? false) ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: (_enumerator!['is_active'] ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Enumerator Information
                          _buildInfoSection(
                            'Enumerator Details',
                            Icons.person,
                            [
                              _buildInfoRow('First Name', _enumerator!['first_name']),
                              _buildInfoRow('Last Name', _enumerator!['last_name']),
                              _buildInfoRow('Phone Number', _enumerator!['phone']),
                              _buildInfoRow('Location', _enumerator!['location']),
                              _buildInfoRow('Assigned Region', _enumerator!['assigned_region']),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Account Information
                          _buildInfoSection(
                            'Account Information',
                            Icons.admin_panel_settings,
                            [
                              _buildInfoRow('Unique ID', _enumerator!['unique_id']),
                              _buildInfoRow('Status', (_enumerator!['is_active'] ?? false) ? 'Active' : 'Inactive'),
                              _buildInfoRow('Date Created', _formatDateTime(_enumerator!['date_joined'])),
                              _buildInfoRow('Last Updated', _formatDateTime(_enumerator!['updated_at'])),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Statistics (if available)
                          if (_enumerator!['stats'] != null) ...[
                            _buildInfoSection(
                              'Statistics',
                              Icons.analytics,
                              [
                                _buildInfoRow('Total Riders Reviewed', _enumerator!['stats']['total_reviewed']),
                                _buildInfoRow('Riders Approved', _enumerator!['stats']['approved']),
                                _buildInfoRow('Riders Rejected', _enumerator!['stats']['rejected']),
                                _buildInfoRow('Approval Rate', '${_enumerator!['stats']['approval_rate']}%'),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Emergency Contact (if available)
                          if (_enumerator!['emergency_contact_name'] != null) ...[
                            _buildInfoSection(
                              'Emergency Contact',
                              Icons.emergency,
                              [
                                _buildInfoRow('Contact Name', _enumerator!['emergency_contact_name']),
                                _buildInfoRow('Contact Phone', _enumerator!['emergency_contact_phone']),
                                _buildInfoRow('Relationship', _enumerator!['emergency_contact_relationship']),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Notes/Comments (if available)
                          if (_enumerator!['notes'] != null && _enumerator!['notes'].toString().isNotEmpty) ...[
                            _buildInfoSection(
                              'Notes',
                              Icons.note,
                              [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _enumerator!['notes'].toString(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2C3E50), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime.toString());
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime.toString();
    }
  }
}
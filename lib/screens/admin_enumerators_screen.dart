import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import 'admin_enumerator_detail_screen.dart';
import 'admin_enumerator_form_screen.dart';

class AdminEnumeratorsScreen extends StatefulWidget {
  final bool showInactiveOnly;
  
  const AdminEnumeratorsScreen({Key? key, this.showInactiveOnly = false}) : super(key: key);

  @override
  State<AdminEnumeratorsScreen> createState() => _AdminEnumeratorsScreenState();
}

class _AdminEnumeratorsScreenState extends State<AdminEnumeratorsScreen> {
  List<dynamic> _enumerators = [];
  List<dynamic> _filteredEnumerators = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadEnumerators();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredEnumerators = List.from(_enumerators);
      });
    } else {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredEnumerators = List.from(_enumerators);
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final result = await AdminService.searchEnumerators(query);
      
      if (result['success']) {
        setState(() {
          _filteredEnumerators = result['data'] ?? [];
          _isSearching = false;
        });
      } else {
        // Fallback to local filtering if API search fails
        _filterLocally(query);
      }
    } catch (e) {
      // Fallback to local filtering if network fails
      _filterLocally(query);
    }
  }

  void _filterLocally(String query) {
    final filtered = _enumerators.where((enumerator) {
      final name = '${enumerator['first_name'] ?? ''} ${enumerator['last_name'] ?? ''}'.toLowerCase();
      final uniqueId = (enumerator['unique_id'] ?? '').toLowerCase();
      final phone = (enumerator['phone'] ?? '').toLowerCase();
      final location = (enumerator['location'] ?? '').toLowerCase();
      final assignedRegion = (enumerator['assigned_region'] ?? '').toLowerCase();
      
      return name.contains(query.toLowerCase()) ||
             uniqueId.contains(query.toLowerCase()) ||
             phone.contains(query.toLowerCase()) ||
             location.contains(query.toLowerCase()) ||
             assignedRegion.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredEnumerators = filtered;
      _isSearching = false;
    });
  }

  Future<void> _loadEnumerators() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await AdminService.getAllEnumerators();
      
      if (result['success']) {
        List<dynamic> allEnumerators = result['data'] ?? [];
        
        // Filter based on showInactiveOnly parameter
        if (widget.showInactiveOnly) {
          allEnumerators = allEnumerators.where((enumerator) => 
            enumerator['is_active'] == false || enumerator['status'] == 'INACTIVE'
          ).toList();
        }
        
        setState(() {
          _enumerators = allEnumerators;
          _filteredEnumerators = List.from(_enumerators);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load enumerators';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load enumerators: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToEnumeratorDetail(Map<String, dynamic> enumerator) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF2C3E50),
                radius: 20,
                child: Text(
                  '${enumerator['first_name']?[0] ?? ''}${enumerator['last_name']?[0] ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${enumerator['first_name'] ?? ''} ${enumerator['last_name'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', enumerator['unique_id'] ?? 'N/A'),
              _buildDetailRow('Phone', enumerator['phone'] ?? 'No phone'),
              _buildDetailRow('Gender', _getGenderDisplay(enumerator['gender'])),
              _buildDetailRow('Location', enumerator['location'] ?? 'No location'),
              _buildDetailRow('Region', enumerator['assigned_region'] ?? 'No region'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Approved Riders',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${enumerator['approved_riders'] ?? 0} riders approved',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Assigned',
                      '${enumerator['total_assigned_riders'] ?? 0}',
                      Icons.group,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      '${enumerator['pending_riders'] ?? 0}',
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToEditEnumerator(enumerator);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddEnumerator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminEnumeratorFormScreen(),
      ),
    ).then((_) => _loadEnumerators());
  }

  void _navigateToEditEnumerator(Map<String, dynamic> enumerator) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEnumeratorFormScreen(
          isEditing: true,
          enumeratorData: enumerator,
        ),
      ),
    ).then((_) => _loadEnumerators());
  }

  Future<void> _deleteEnumerator(Map<String, dynamic> enumerator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Enumerator'),
          content: Text(
            'Are you sure you want to delete ${enumerator['first_name']} ${enumerator['last_name']}? This action cannot be undone.',
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
        final result = await AdminService.deleteEnumerator(
          enumerator['unique_id'] ?? enumerator['id'].toString(),
        );
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enumerator deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadEnumerators();
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
          widget.showInactiveOnly ? 'Deactivated Enumerators' : 'Manage Enumerators',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEnumerators,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddEnumerator,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search enumerators by name, ID, phone, location, or region...',
                prefixIcon: _isSearching 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
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
                              onPressed: _loadEnumerators,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredEnumerators.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No enumerators found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadEnumerators,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _filteredEnumerators.length,
                              itemBuilder: (context, index) {
                                final enumerator = _filteredEnumerators[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF2C3E50),
                                      radius: 25,
                                      child: Text(
                                        '${enumerator['first_name']?[0] ?? ''}${enumerator['last_name']?[0] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${enumerator['first_name'] ?? ''} ${enumerator['last_name'] ?? ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          'ID: ${enumerator['unique_id'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Phone: ${enumerator['phone'] ?? 'No phone'}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Gender: ${_getGenderDisplay(enumerator['gender'])}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Location: ${enumerator['location'] ?? 'No location'}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Region: ${enumerator['assigned_region'] ?? 'No region'}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (enumerator['is_active'] ?? false) 
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            (enumerator['is_active'] ?? false) ? 'Active' : 'Inactive',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: (enumerator['is_active'] ?? false) 
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'view') {
                                          _navigateToEnumeratorDetail(enumerator);
                                        } else if (value == 'delete') {
                                          _deleteEnumerator(enumerator);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        const PopupMenuItem<String>(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility, size: 18),
                                              SizedBox(width: 8),
                                              Text('View Details'),
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
                                    onTap: () => _navigateToEnumeratorDetail(enumerator),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: widget.showInactiveOnly ? null : FloatingActionButton(
        onPressed: _navigateToAddEnumerator,
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getGenderDisplay(String? gender) {
    switch (gender) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'O':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
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
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
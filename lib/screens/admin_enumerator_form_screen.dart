import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminEnumeratorFormScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? enumeratorData;

  const AdminEnumeratorFormScreen({
    Key? key,
    this.isEditing = false,
    this.enumeratorData,
  }) : super(key: key);

  @override
  State<AdminEnumeratorFormScreen> createState() => _AdminEnumeratorFormScreenState();
}

class _AdminEnumeratorFormScreenState extends State<AdminEnumeratorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers - simplified to match Django dashboard
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _assignedRegionController = TextEditingController();

  // Status dropdown
  bool _isActive = true;
  
  // Gender dropdown
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.enumeratorData != null) {
      _populateFormFields();
    }
  }

  void _populateFormFields() {
    final data = widget.enumeratorData!;
    _firstNameController.text = data['first_name'] ?? '';
    _lastNameController.text = data['last_name'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _locationController.text = data['location'] ?? '';
    _assignedRegionController.text = data['assigned_region'] ?? '';
    _selectedGender = data['gender'];
    _isActive = data['is_active'] ?? true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _assignedRegionController.dispose();
    super.dispose();
  }


  Future<void> _saveEnumerator() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final enumeratorData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone': _phoneController.text,
        'gender': _selectedGender,
        'location': _locationController.text,
        'assigned_region': _assignedRegionController.text,
        'is_active': _isActive,
      };

      Map<String, dynamic> result;
      
      if (widget.isEditing) {
        final enumeratorId = widget.enumeratorData!['unique_id'] ?? 
                           widget.enumeratorData!['id'].toString();
        result = await AdminService.updateEnumerator(enumeratorId, enumeratorData);
      } else {
        result = await AdminService.createEnumerator(enumeratorData);
      }

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                  ? 'Enumerator updated successfully'
                  : 'Enumerator created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Operation failed'),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Enumerator' : 'Add New Enumerator',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEnumerator,
            child: Text(
              widget.isEditing ? 'Update' : 'Save',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_ind,
                        color: const Color(0xFF2C3E50),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.isEditing ? 'Edit Enumerator Details' : 'New Enumerator Details',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // First Name and Last Name
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Phone Number
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    required: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Gender Selection
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'M',
                        child: Text('Male'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'F',
                        child: Text('Female'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'O',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Status:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Switch(
                          value: _isActive,
                          onChanged: (value) => setState(() => _isActive = value),
                          activeColor: const Color(0xFF2C3E50),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isActive ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Location
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    required: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Assigned Region
                  _buildTextField(
                    controller: _assignedRegionController,
                    label: 'Assigned Region',
                    required: true,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEnumerator,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              widget.isEditing ? 'Update Enumerator' : 'Create Enumerator',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }
}
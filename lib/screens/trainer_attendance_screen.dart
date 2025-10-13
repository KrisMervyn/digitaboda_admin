import 'package:flutter/material.dart';
import '../services/enumerator_service.dart';

class TrainerAttendanceScreen extends StatefulWidget {
  const TrainerAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<TrainerAttendanceScreen> createState() => _TrainerAttendanceScreenState();
}

class _TrainerAttendanceScreenState extends State<TrainerAttendanceScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _modules = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _trainerInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load students and modules in parallel
      final studentsFuture = EnumeratorService.getTrainingStudents();
      final modulesFuture = EnumeratorService.getAvailableModules();

      final results = await Future.wait([studentsFuture, modulesFuture]);
      final studentsResult = results[0];
      final modulesResult = results[1];

      if (studentsResult['success'] && modulesResult['success']) {
        setState(() {
          _trainerInfo = studentsResult['data']['trainer'];
          _students = List<Map<String, dynamic>>.from(studentsResult['data']['students'] ?? []);
          _modules = List<Map<String, dynamic>>.from(modulesResult['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = studentsResult['error'] ?? modulesResult['error'] ?? 'Failed to load data';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Training Attendance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          ),
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading training data...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2C3E50),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Students Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'No riders have expressed interest in training modules yet.\n\nOnce riders use the "Express Interest" feature in their app, they will appear here for attendance tracking.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Riders can express interest by:\n1. Opening the rider app\n2. Going to Training Modules\n3. Clicking "Express Interest"',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Trainer Info Header
        if (_trainerInfo != null)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _trainerInfo!['name'] ?? 'Trainer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${_trainerInfo!['unique_id'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_students.length} Students Assigned',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Students List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return _buildStudentCard(student);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CA1AF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF4CA1AF),
            size: 24,
          ),
        ),
        title: Text(
          student['name'] ?? 'Unknown Student',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${student['unique_id'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              'Phone: ${student['phone'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatChip(
                  '${student['sessions_attended'] ?? 0} sessions',
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  '${student['points'] ?? 0} points',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mark Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAttendanceForm(student),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAttendanceForm(Map<String, dynamic> student) {
    return AttendanceForm(
      student: student,
      modules: _modules,
      onAttendanceMarked: () {
        // Refresh student data
        _loadData();
      },
    );
  }
}

class AttendanceForm extends StatefulWidget {
  final Map<String, dynamic> student;
  final List<Map<String, dynamic>> modules;
  final VoidCallback onAttendanceMarked;

  const AttendanceForm({
    Key? key,
    required this.student,
    required this.modules,
    required this.onAttendanceMarked,
  }) : super(key: key);

  @override
  State<AttendanceForm> createState() => _AttendanceFormState();
}

class _AttendanceFormState extends State<AttendanceForm> {
  int? _selectedModuleId;
  int? _selectedSessionId;
  String _selectedStatus = 'ATTENDED';
  String _notes = '';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  String _message = '';

  Map<String, dynamic>? get selectedModule {
    if (_selectedModuleId == null) return null;
    return widget.modules.firstWhere(
      (module) => module['id'] == _selectedModuleId,
      orElse: () => {},
    );
  }

  List<Map<String, dynamic>> get availableSessions {
    final module = selectedModule;
    if (module == null) return [];
    return List<Map<String, dynamic>>.from(module['sessions'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Module Selection
        DropdownButtonFormField<int>(
          value: _selectedModuleId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Select Module',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: widget.modules.map((module) {
            return DropdownMenuItem<int>(
              value: module['id'],
              child: Flexible(
                child: Text(
                  module['title'] ?? 'Unknown Module',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedModuleId = value;
              _selectedSessionId = null; // Reset session selection
            });
          },
        ),
        const SizedBox(height: 16),

        // Session Selection
        if (selectedModule != null) ...[
          DropdownButtonFormField<int>(
            value: _selectedSessionId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Session',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: availableSessions.map((session) {
              return DropdownMenuItem<int>(
                value: session['id'],
                child: Flexible(
                  child: Text(
                    'Session ${session['session_number']}: ${session['title']}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSessionId = value;
              });
            },
          ),
          const SizedBox(height: 16),
        ],

        // Attendance Status
        const Text(
          'Attendance Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildStatusChip('ATTENDED', 'Present', Colors.green),
            _buildStatusChip('ABSENT', 'Absent', Colors.red),
            _buildStatusChip('LATE', 'Late', Colors.orange),
            _buildStatusChip('EXCUSED', 'Excused', Colors.grey),
          ],
        ),
        const SizedBox(height: 16),

        // Date Selection
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today, color: Color(0xFF4CA1AF)),
          title: Text(
            'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Notes
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            border: OutlineInputBorder(),
            hintText: 'Add any additional notes...',
          ),
          maxLines: 2,
          onChanged: (value) {
            setState(() {
              _notes = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canSubmit() ? _submitAttendance : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CA1AF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Mark Attendance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        // Message
        if (_message.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _message.contains('success') || _message.contains('✅')
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _message.contains('success') || _message.contains('✅')
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Text(
              _message,
              style: TextStyle(
                color: _message.contains('success') || _message.contains('✅')
                    ? Colors.green[800]
                    : Colors.red[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip(String status, String label, Color color) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
      selectedColor: color.withOpacity(0.2),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey[300]!,
      ),
    );
  }

  bool _canSubmit() {
    return _selectedModuleId != null &&
        _selectedSessionId != null &&
        !_isSubmitting;
  }

  Future<void> _submitAttendance() async {
    if (!_canSubmit()) return;

    setState(() {
      _isSubmitting = true;
      _message = '';
    });

    try {
      final result = await EnumeratorService.markStudentAttendance(
        studentPhone: widget.student['phone'],
        sessionId: _selectedSessionId!,
        status: _selectedStatus,
        sessionDate: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        notes: _notes.trim().isEmpty ? null : _notes.trim(),
      );

      setState(() {
        _isSubmitting = false;
        if (result['success']) {
          _message = '✅ ${result['message'] ?? 'Attendance marked successfully!'}';
          // Reset form
          _selectedModuleId = null;
          _selectedSessionId = null;
          _selectedStatus = 'ATTENDED';
          _notes = '';
          _selectedDate = DateTime.now();
          
          // Notify parent to refresh
          widget.onAttendanceMarked();
        } else {
          _message = 'Error: ${result['error']}';
        }
      });

      // Clear success message after 3 seconds
      if (result['success']) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _message = '';
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _message = 'Connection error: $e';
      });
    }
  }
}
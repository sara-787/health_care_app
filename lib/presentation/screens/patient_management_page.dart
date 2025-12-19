import 'package:flutter/material.dart';

class PatientManagementPage extends StatefulWidget {
  const PatientManagementPage({super.key});

  @override
  State<PatientManagementPage> createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  List<Map<String, dynamic>> patients = [
    {
      'id': '1',
      'name': 'Sarah Johnson',
      'gender': 'Female',
      'dateOfBirth': DateTime(1980, 3, 15),
      'email': 'sarah.johnson@example.com',
    },
    {
      'id': '2',
      'name': 'Michael Chen',
      'gender': 'Male',
      'dateOfBirth': DateTime(1963, 7, 22),
      'email': 'michael.chen@example.com',
    },
    {
      'id': '3',
      'name': 'Emily Davis',
      'gender': 'Female',
      'dateOfBirth': DateTime(1997, 11, 8),
      'email': 'emily.davis@example.com',
    },
    {
      'id': '4',
      'name': 'James Wilson',
      'gender': 'Male',
      'dateOfBirth': DateTime(1970, 2, 28),
      'email': 'james.wilson@example.com',
    },
    {
      'id': '5',
      'name': 'Maria Garcia',
      'gender': 'Female',
      'dateOfBirth': DateTime(1987, 9, 12),
      'email': 'maria.garcia@example.com',
    },
    {
      'id': '6',
      'name': 'Ahmed Ali',
      'gender': 'Male',
      'dateOfBirth': DateTime(1992, 5, 18),
      'email': 'ahmed.ali@example.com',
    },
  ];

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _addPatient() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Patient feature coming soon')),
    );
  }

  void _viewPatient(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          patient['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gender: ${patient['gender']}'),
            Text('Date of Birth: ${_formatDate(patient['dateOfBirth'])}'),
            Text('Email: ${patient['email']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editPatient(Map<String, dynamic> patient) {
    // TODO: Implement edit
  }

  void _deletePatient(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${patient['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => patients.remove(patient));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${patient['name']} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Title
              const Text(
                'Patient Management',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // Subtitle + Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Patient Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addPatient,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Add Patient',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Responsive Table Card
              Expanded(
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive column spacing based on screen width
                        double columnSpacing = constraints.maxWidth > 800
                            ? 60
                            : 30;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              headingRowHeight: 64,
                              dataRowHeight: 80,
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              columnSpacing: columnSpacing,
                              columns: const [
                                DataColumn(label: Text('Patient Name')),
                                DataColumn(label: Text('Gender')),
                                DataColumn(label: Text('Date of Birth')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: patients.map((patient) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        patient['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(patient['gender'])),
                                    DataCell(
                                      Text(_formatDate(patient['dateOfBirth'])),
                                    ),
                                    DataCell(
                                      SelectableText(
                                        patient['email'],
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.visibility,
                                              color: Colors.blue,
                                            ),
                                            tooltip: 'View',
                                            onPressed: () =>
                                                _viewPatient(patient),
                                            splashRadius: 22,
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                            tooltip: 'Edit',
                                            onPressed: () =>
                                                _editPatient(patient),
                                            splashRadius: 22,
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            tooltip: 'Delete',
                                            onPressed: () =>
                                                _deletePatient(patient),
                                            splashRadius: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

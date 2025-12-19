import 'package:flutter/material.dart';


class PatientManagementPage extends StatefulWidget {
  const PatientManagementPage({super.key});

  @override
  State<PatientManagementPage> createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  // ------------------------- DATA -------------------------
  List<Map<String, dynamic>> patients = [
    {
      'nationalId': '30609800315001',
      'age': '45',
      'name': 'Sarah Johnson',
      'gender': 'Female',
      'dateOfBirth': DateTime(1980, 3, 15),
      'bloodType': 'A+',
      'email': 'sarah.johnson@example.com',
      'phone': '(555) 123-4567',
      'address': '123 Main Street, City, ST 12345',
      'condition': 'Diabetes',
      'status': 'Stable',
      'statusColor': Colors.green,
      'assignedDoctor': 'Dr. Smith',
      'lastVisit': '2024-12-15',
      'allergies': ['Penicillin', 'Peanuts'],
      'labResults': [
        {'test': 'Blood Glucose', 'value': '180 mg/dL', 'status': 'High', 'color': Colors.orange, 'date': '2025-12-19'},
        {'test': 'HbA1c', 'value': '7.8%', 'status': 'Elevated', 'color': Colors.red, 'date': '2025-12-19'},
      ],
      'prescriptions': [
        {'medication': 'Metformin', 'dosage': '500mg', 'instructions': 'Twice daily', 'date': '2025-12-19'},
      ],
    },
    {
      'nationalId': '306019630722002',
      'age': '62',
      'name': 'Michael Chen',
      'gender': 'Male',
      'dateOfBirth': DateTime(1963, 7, 22),
      'bloodType': 'O-',
      'email': 'michael.chen@example.com',
      'phone': '(555) 987-6543',
      'address': '456 Oak Avenue, Town, NY 67890',
      'condition': 'Hypertension',
      'status': 'Critical',
      'statusColor': Colors.red,
      'assignedDoctor': 'Dr. Williams',
      'lastVisit': '2024-12-18',
      'allergies': ['None'],
      'labResults': [],
      'prescriptions': [],
    },
  ];

  // ------------------------- HELPERS -------------------------
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get _today => _formatDate(DateTime.now());

  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = _formatDate(picked);
    }
  }

  // ------------------------- FORMS (ADD/EDIT PATIENT) -------------------------
  void _showPatientForm({Map<String, dynamic>? patient, int? index}) {
    final isEdit = patient != null;
    final formKey = GlobalKey<FormState>();

    // Controllers
    final nationalIdCtrl = TextEditingController(text: isEdit ? patient['nationalId'] : '');
    final nameCtrl = TextEditingController(text: isEdit ? patient['name'] : '');
    final ageCtrl = TextEditingController(text: isEdit ? patient['age'] : '');
    final emailCtrl = TextEditingController(text: isEdit ? patient['email'] : '');
    final phoneCtrl = TextEditingController(text: isEdit ? patient['phone'] : '');
    final addressCtrl = TextEditingController(text: isEdit ? patient['address'] : '');
    final conditionCtrl = TextEditingController(text: isEdit ? patient['condition'] : '');
    final assignedDoctorCtrl = TextEditingController(text: isEdit ? patient['assignedDoctor'] : '');
    final dobCtrl = TextEditingController(text: isEdit ? _formatDate(patient['dateOfBirth']) : '');
    final allergiesCtrl = TextEditingController(text: isEdit ? (patient['allergies'] as List).join(', ') : '');

    String gender = isEdit ? patient['gender'] : 'Male';
    String bloodType = isEdit ? patient['bloodType'] : 'A+';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Patient' : 'Add New Patient'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: nationalIdCtrl,
                  decoration: const InputDecoration(labelText: 'National ID'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.length != 14 ? '14 digits required' : null,
                ),
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => gender = v!,
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                TextFormField(
                  controller: dobCtrl,
                  decoration: InputDecoration(
                    labelText: 'DOB (YYYY-MM-DD)',
                    suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(context, dobCtrl))
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null
                ),
                TextFormField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                TextFormField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
                TextFormField(controller: conditionCtrl, decoration: const InputDecoration(labelText: 'Condition')),
                TextFormField(controller: assignedDoctorCtrl, decoration: const InputDecoration(labelText: 'Assigned Doctor')),
                TextFormField(controller: allergiesCtrl, decoration: const InputDecoration(labelText: 'Allergies (comma separated)')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                List<String> allergiesList = allergiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                if (allergiesList.isEmpty) allergiesList = ['None'];

                final updatedPatient = {
                  'nationalId': nationalIdCtrl.text,
                  'name': nameCtrl.text,
                  'gender': gender,
                  'dateOfBirth': DateTime.tryParse(dobCtrl.text) ?? DateTime.now(),
                  'age': ageCtrl.text,
                  'bloodType': bloodType,
                  'email': emailCtrl.text,
                  'phone': phoneCtrl.text,
                  'address': addressCtrl.text,
                  'condition': conditionCtrl.text.isEmpty ? 'None' : conditionCtrl.text,
                  'status': isEdit ? patient['status'] : 'Stable',
                  'statusColor': isEdit ? patient['statusColor'] : Colors.green,
                  'assignedDoctor': assignedDoctorCtrl.text.isEmpty ? 'Not Assigned' : assignedDoctorCtrl.text,
                  'lastVisit': isEdit ? patient['lastVisit'] : _today,
                  'allergies': allergiesList,
                  // Safely handle existing lists
                  'labResults': isEdit ? patient['labResults'] : [],
                  'prescriptions': isEdit ? patient['prescriptions'] : [],
                };

                setState(() {
                  if (isEdit) { patients[index!] = updatedPatient; } 
                  else { patients.add(updatedPatient); }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ------------------------- FORMS (LABS & RX) -------------------------
  void _showItemForm({
    required String type, // 'Lab' or 'Rx'
    required Map<String, dynamic> patient,
    Map<String, dynamic>? item,
    int? index,
  }) {
    final formKey = GlobalKey<FormState>();
    final field1Ctrl = TextEditingController(text: item != null ? (type == 'Lab' ? item['test'] : item['medication']) : '');
    final field2Ctrl = TextEditingController(text: item != null ? (type == 'Lab' ? item['value'] : item['dosage']) : '');
    final field3Ctrl = TextEditingController(text: item != null ? (type == 'Lab' ? item['status'] : item['instructions']) : '');
    final dateCtrl = TextEditingController(text: item?['date'] ?? _today);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Add $type' : 'Edit $type'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: field1Ctrl,
                decoration: InputDecoration(labelText: type == 'Lab' ? 'Test Name' : 'Medication'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: field2Ctrl,
                decoration: InputDecoration(labelText: type == 'Lab' ? 'Value' : 'Dosage'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: field3Ctrl,
                decoration: InputDecoration(labelText: type == 'Lab' ? 'Status' : 'Instructions'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: dateCtrl,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(ctx, dateCtrl),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  Map<String, dynamic> newItem;
                  if (type == 'Lab') {
                    Color c = Colors.green;
                    if (field3Ctrl.text.toLowerCase().contains('high')) c = Colors.orange;
                    newItem = {'test': field1Ctrl.text, 'value': field2Ctrl.text, 'status': field3Ctrl.text, 'color': c, 'date': dateCtrl.text};
                    
                    // FIX: safely copy the existing list to a mutable generic list
                    var sourceList = patient['labResults'] as List? ?? [];
                    List<Map<String, dynamic>> currentList = sourceList.map((e) => Map<String, dynamic>.from(e)).toList();

                    if (item == null) {
                      currentList.add(newItem);
                    } else {
                      currentList[index!] = newItem;
                    }
                    patient['labResults'] = currentList; // Update patient record
                  } else {
                    newItem = {'medication': field1Ctrl.text, 'dosage': field2Ctrl.text, 'instructions': field3Ctrl.text, 'date': dateCtrl.text};
                    
                    // FIX: safely copy the existing list to a mutable generic list
                    var sourceList = patient['prescriptions'] as List? ?? [];
                    List<Map<String, dynamic>> currentList = sourceList.map((e) => Map<String, dynamic>.from(e)).toList();

                    if (item == null) {
                      currentList.add(newItem);
                    } else {
                      currentList[index!] = newItem;
                    }
                    patient['prescriptions'] = currentList; // Update patient record
                  }
                });
                Navigator.pop(ctx);
                Navigator.pop(context); // Pop current details view
                _openPatientDetails(patient); // Re-push details view with updates
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deletePatient(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${patient['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => patients.remove(patient));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ------------------------- DETAIL VIEW (SIMPLIFIED) -------------------------
  void _openPatientDetails(Map<String, dynamic> patient) {
    // FIX: Safely cast the lists for display to avoid type errors
    final rawLabs = patient['labResults'] as List? ?? [];
    final displayLabs = rawLabs.map((e) => Map<String, dynamic>.from(e)).toList();

    final rawRx = patient['prescriptions'] as List? ?? [];
    final displayRx = rawRx.map((e) => Map<String, dynamic>.from(e)).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(patient['name'])),
          backgroundColor: Colors.grey.shade100,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                      const SizedBox(height: 10),
                      Text(patient['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('${patient['age']} yrs • ${patient['gender']} • ${patient['condition']}'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: patient['statusColor'], borderRadius: BorderRadius.circular(20)),
                        child: Text(patient['status'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Contact Info
              const Text("Contact Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Card(
                child: Column(
                  children: [
                    ListTile(leading: const Icon(Icons.email), title: const Text("Email"), subtitle: Text(patient['email'])),
                    ListTile(leading: const Icon(Icons.phone), title: const Text("Phone"), subtitle: Text(patient['phone'])),
                    ListTile(leading: const Icon(Icons.location_on), title: const Text("Address"), subtitle: Text(patient['address'])),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Allergies
              const Text("Allergies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8,
                    children: (patient['allergies'] as List).map<Widget>((a) => Chip(
                      label: Text(a), 
                      backgroundColor: Colors.red.shade50
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Labs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Lab Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () => _showItemForm(type: 'Lab', patient: patient),
                  )
                ],
              ),
              if (displayLabs.isEmpty) const Text("No records found", style: TextStyle(color: Colors.grey)),
              ...displayLabs.asMap().entries.map((entry) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.science, color: Colors.orange),
                    title: Text(entry.value['test']),
                    subtitle: Text("${entry.value['status']} • ${entry.value['date']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.value['value'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                          onPressed: () => _showItemForm(type: 'Lab', patient: patient, item: entry.value, index: entry.key),
                        )
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Prescriptions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Prescriptions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () => _showItemForm(type: 'Rx', patient: patient),
                  )
                ],
              ),
              if (displayRx.isEmpty) const Text("No records found", style: TextStyle(color: Colors.grey)),
              ...displayRx.asMap().entries.map((entry) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.medication, color: Colors.blue),
                    title: Text(entry.value['medication']),
                    subtitle: Text("${entry.value['instructions']}\n${entry.value['date']}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.value['dosage'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                          onPressed: () => _showItemForm(type: 'Rx', patient: patient, item: entry.value, index: entry.key),
                        )
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------- MAIN BUILD (TABLE VIEW) -------------------------
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
              const Text('Patient Management', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Patient Records', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
                  ElevatedButton.icon(
                    onPressed: () => _showPatientForm(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Patient', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 64,
                          dataRowHeight: 80,
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          columnSpacing: 40,
                          columns: const [
                            DataColumn(label: Text('National ID')),
                            DataColumn(label: Text('Patient Name')),
                            DataColumn(label: Text('Gender')),
                            DataColumn(label: Text('Date of Birth')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: patients.map((patient) {
                            return DataRow(
                              cells: [
                                DataCell(Text(patient['nationalId'], style: const TextStyle(fontWeight: FontWeight.w500))),
                                DataCell(Text(patient['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                                DataCell(Text(patient['gender'])),
                                DataCell(Text(_formatDate(patient['dateOfBirth']))),
                                DataCell(SelectableText(patient['email'], style: const TextStyle(color: Colors.blue))),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.blue),
                                      tooltip: 'View',
                                      onPressed: () => _openPatientDetails(patient),
                                      splashRadius: 22,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                      tooltip: 'Edit',
                                      onPressed: () => _showPatientForm(patient: patient, index: patients.indexOf(patient)),
                                      splashRadius: 22,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      tooltip: 'Delete',
                                      onPressed: () => _deletePatient(patient),
                                      splashRadius: 22,
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
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
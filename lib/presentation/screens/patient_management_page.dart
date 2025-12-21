import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientManagementPage extends StatefulWidget {
  const PatientManagementPage({super.key});

  @override
  State<PatientManagementPage> createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  final CollectionReference<Map<String, dynamic>> patientsCollection =
  FirebaseFirestore.instance.collection('users');

  // ---------------- DATE UTILITIES ----------------
  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String get _today => _formatDate(DateTime.now());

  Future<void> _pickDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) controller.text = _formatDate(picked);
  }

  // ---------------- PATIENT FORM ----------------
  void _showPatientForm({DocumentSnapshot<Map<String, dynamic>>? doc}) {
    final isEdit = doc != null;
    final formKey = GlobalKey<FormState>();
    final data = doc?.data();

    final nationalIdCtrl =
    TextEditingController(text: data?['nationalId'] ?? '');
    final nameCtrl =
    TextEditingController(text: data?['fullName'] ?? data?['name'] ?? '');
    final ageCtrl = TextEditingController(text: data?['age'] ?? '');
    final emailCtrl = TextEditingController(text: data?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: data?['phone'] ?? '');
    final addressCtrl = TextEditingController(text: data?['address'] ?? '');
    final conditionCtrl = TextEditingController(text: data?['condition'] ?? '');
    final assignedDoctorCtrl =
    TextEditingController(text: data?['assignedDoctor'] ?? '');
    final dobCtrl = TextEditingController(text: data?['dateOfBirth'] ?? '');
    final allergiesCtrl = TextEditingController(
        text: data?['allergies'] != null
            ? (data!['allergies'] as List).join(', ')
            : '');

    String gender = data?['gender'] ?? 'Male';
    String bloodType = data?['bloodType'] ?? 'A+';

    // ---------------- FETCH EMAIL AUTOMATICALLY ----------------
    Future<void> fetchEmail() async {
      if (nationalIdCtrl.text.isEmpty) return;
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('nationalId', isEqualTo: nationalIdCtrl.text.trim())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        emailCtrl.text = query.docs.first['email'] ?? '';
      } else {
        emailCtrl.text = '';
      }
    }

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
                  validator: (v) =>
                  v != null && v.length != 14 ? '14 digits required' : null,
                  onChanged: (_) => fetchEmail(),
                ),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                // FIXED: Replaced 'value' with 'initialValue'
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  items: ['Male', 'Female']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => gender = v ?? 'Male',
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                TextFormField(
                  controller: dobCtrl,
                  decoration: InputDecoration(
                    labelText: 'DOB (YYYY-MM-DD)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(context, dobCtrl),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                    controller: ageCtrl,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled: false,
                ),
                TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone')),
                TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address')),
                TextFormField(
                    controller: conditionCtrl,
                    decoration: const InputDecoration(labelText: 'Condition')),
                TextFormField(
                    controller: assignedDoctorCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Assigned Doctor')),
                TextFormField(
                    controller: allergiesCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Allergies (comma separated)')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                List<String> allergiesList = allergiesCtrl.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                if (allergiesList.isEmpty) allergiesList = ['None'];

                final patientData = {
                  'nationalId': nationalIdCtrl.text,
                  'fullName': nameCtrl.text,
                  'name': nameCtrl.text,
                  'gender': gender,
                  'dateOfBirth': dobCtrl.text,
                  'age': ageCtrl.text,
                  'bloodType': bloodType,
                  'email': emailCtrl.text,
                  'phone': phoneCtrl.text,
                  'address': addressCtrl.text,
                  'condition': conditionCtrl.text.isNotEmpty
                      ? conditionCtrl.text
                      : 'None',
                  'status': data?['status'] ?? 'Stable',
                  'statusColor':
                  data?['statusColor'] ?? Colors.green.toARGB32(),
                  'assignedDoctor': assignedDoctorCtrl.text.isNotEmpty
                      ? assignedDoctorCtrl.text
                      : 'Not Assigned',
                  'lastVisit': data?['lastVisit'] ?? _today,
                  'allergies': allergiesList,
                  'labResults': data?['labResults'] ?? [],
                  'prescriptions': data?['prescriptions'] ?? [],
                };

                if (isEdit) {
                  await patientsCollection.doc(doc.id).update(patientData);
                } else {
                  await patientsCollection.add(patientData);
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  // ---------------- LAB RESULTS & PRESCRIPTIONS FORM ----------------
  void _showItemForm({
    required String type,
    required DocumentSnapshot<Map<String, dynamic>> patientDoc,
    Map<String, dynamic>? item,
    int? index,
  }) {
    final formKey = GlobalKey<FormState>();
    final patientData = Map<String, dynamic>.from(patientDoc.data()!);

    final field1Ctrl = TextEditingController(
        text: item != null
            ? (type == 'Lab' ? item['test'] : item['medication'])
            : '');
    final field2Ctrl = TextEditingController(
        text: item != null
            ? (type == 'Lab' ? item['value'] : item['dosage'])
            : '');
    final field3Ctrl = TextEditingController(
        text: item != null
            ? (type == 'Lab' ? item['status'] : item['instructions'])
            : '');
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
                decoration: InputDecoration(
                    labelText: type == 'Lab' ? 'Test Name' : 'Medication'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: field2Ctrl,
                decoration: InputDecoration(
                    labelText: type == 'Lab' ? 'Value' : 'Dosage'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: field3Ctrl,
                decoration: InputDecoration(
                    labelText: type == 'Lab' ? 'Status' : 'Instructions'),
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
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                List<dynamic> listKey = type == 'Lab'
                    ? patientData['labResults'] ?? []
                    : patientData['prescriptions'] ?? [];

                Map<String, dynamic> newItem;
                if (type == 'Lab') {
                  int color = Colors.green.toARGB32();
                  if (field3Ctrl.text.toLowerCase().contains('high')) {
                    color = Colors.orange.toARGB32();
                  }
                  newItem = {
                    'test': field1Ctrl.text,
                    'value': field2Ctrl.text,
                    'status': field3Ctrl.text,
                    'color': color,
                    'date': dateCtrl.text,
                  };
                } else {
                  newItem = {
                    'medication': field1Ctrl.text,
                    'dosage': field2Ctrl.text,
                    'instructions': field3Ctrl.text,
                    'date': dateCtrl.text,
                  };
                }

                if (item == null) {
                  listKey.add(newItem);
                } else {
                  listKey[index!] = newItem;
                }

                await patientsCollection.doc(patientDoc.id).update({
                  type == 'Lab' ? 'labResults' : 'prescriptions': listKey,
                });

                if (!context.mounted) return;
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ---------------- PATIENT DETAILS VIEW ----------------
  void _openPatientDetails(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final rawLabs =
    data['labResults'] != null ? data['labResults'] as List : [];
    final displayLabs =
    rawLabs.map((e) => Map<String, dynamic>.from(e)).toList();
    final rawRx =
    data['prescriptions'] != null ? data['prescriptions'] as List : [];
    final displayRx = rawRx.map((e) => Map<String, dynamic>.from(e)).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(data['fullName'] ?? data['name'] ?? '')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                          radius: 30, child: Icon(Icons.person, size: 30)),
                      const SizedBox(height: 10),
                      Text(data['fullName'] ?? data['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(
                          '${data['age']} yrs • ${data['gender']} • ${data['condition']}'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Color(data['statusColor'] ??
                                Colors.green.toARGB32()),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(data['status'] ?? 'Stable',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Contact Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Card(
                child: Column(
                  children: [
                    ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text("Email"),
                        subtitle: Text(data['email'] ?? '')),
                    ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text("Phone"),
                        subtitle: Text(data['phone'] ?? '')),
                    ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text("Address"),
                        subtitle: Text(data['address'] ?? '')),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text("Allergies",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8,
                    children: (data['allergies'] as List?)
                        ?.map<Widget>((a) => Chip(
                        label: Text(a.toString()),
                        backgroundColor: Colors.red.shade50))
                        .toList() ??
                        [],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Lab Results",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () =>
                        _showItemForm(type: 'Lab', patientDoc: doc),
                  )
                ],
              ),
              if (displayLabs.isEmpty)
                const Text("No records found",
                    style: TextStyle(color: Colors.grey)),
              ...displayLabs.asMap().entries.map((entry) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.science, color: Colors.orange),
                    title: Text(entry.value['test']),
                    subtitle: Text(
                        "${entry.value['status']} • ${entry.value['date']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.value['value'],
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 20, color: Colors.grey),
                          onPressed: () => _showItemForm(
                              type: 'Lab',
                              patientDoc: doc,
                              item: entry.value,
                              index: entry.key),
                        )
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Prescriptions",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () => _showItemForm(type: 'Rx', patientDoc: doc),
                  )
                ],
              ),
              if (displayRx.isEmpty)
                const Text("No records found",
                    style: TextStyle(color: Colors.grey)),
              ...displayRx.asMap().entries.map((entry) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.medication, color: Colors.blue),
                    title: Text(entry.value['medication']),
                    subtitle: Text(
                        "${entry.value['instructions']}\n${entry.value['date']}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.value['dosage'],
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 20, color: Colors.grey),
                          onPressed: () => _showItemForm(
                              type: 'Rx',
                              patientDoc: doc,
                              item: entry.value,
                              index: entry.key),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _deletePatient(DocumentSnapshot<Map<String, dynamic>> doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Delete ${doc.data()?['fullName'] ?? doc.data()?['name'] ?? ''}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await patientsCollection.doc(doc.id).delete();
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ---------------- MAIN BUILD ----------------
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
              const Text('Patient Management',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Patient Records',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ElevatedButton.icon(
                    onPressed: () => _showPatientForm(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Patient',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: patientsCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final patients = snapshot.data!.docs;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('National ID')),
                          DataColumn(label: Text('Patient Name')),
                          DataColumn(label: Text('Gender')),
                          DataColumn(label: Text('Date of Birth')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: patients.map((patientDoc) {
                          final data = patientDoc.data();
                          return DataRow(
                            cells: [
                              DataCell(Text(data['nationalId'] ?? '')),
                              DataCell(
                                  Text(data['fullName'] ?? data['name'] ?? '')),
                              DataCell(Text(data['gender'] ?? '')),
                              DataCell(Text(data['dateOfBirth'] ?? '')),
                              DataCell(SelectableText(data['email'] ?? '',
                                  style: const TextStyle(color: Colors.blue))),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.blue),
                                    tooltip: 'View',
                                    onPressed: () =>
                                        _openPatientDetails(patientDoc),
                                    splashRadius: 22,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    tooltip: 'Edit',
                                    onPressed: () =>
                                        _showPatientForm(doc: patientDoc),
                                    splashRadius: 22,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    tooltip: 'Delete',
                                    onPressed: () => _deletePatient(patientDoc),
                                    splashRadius: 22,
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
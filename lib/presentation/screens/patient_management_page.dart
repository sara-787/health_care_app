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

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String get _today => _formatDate(DateTime.now());

  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) controller.text = _formatDate(picked);
  }

  // ---------------- PATIENT FORM (Includes Blood Type) ----------------
  void _showPatientForm({DocumentSnapshot<Map<String, dynamic>>? doc}) {
    final isEdit = doc != null;
    final formKey = GlobalKey<FormState>();
    final data = doc?.data();

    final nationalIdCtrl = TextEditingController(text: data?['nationalId'] ?? '');
    final nameCtrl = TextEditingController(text: data?['fullName'] ?? data?['name'] ?? '');
    final ageCtrl = TextEditingController(text: data?['age'] ?? '');
    final emailCtrl = TextEditingController(text: data?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: data?['phone'] ?? '');
    final addressCtrl = TextEditingController(text: data?['address'] ?? '');
    final conditionCtrl = TextEditingController(text: data?['condition'] ?? '');
    final assignedDoctorCtrl = TextEditingController(text: data?['assignedDoctor'] ?? '');
    final dobCtrl = TextEditingController(text: data?['dateOfBirth'] ?? '');
    final allergiesCtrl = TextEditingController(
        text: data?['allergies'] != null ? (data!['allergies'] as List).join(', ') : '');

    String gender = data?['gender'] ?? 'Male';
    String bloodType = data?['bloodType'] ?? 'A+'; // Blood type state

    Future<void> fetchEmail() async {
      if (nationalIdCtrl.text.isEmpty) return;
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('nationalId', isEqualTo: nationalIdCtrl.text.trim())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        emailCtrl.text = query.docs.first['email'] ?? '';
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Allows dropdown state to update in dialog
        builder: (context, setDialogState) => AlertDialog(
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
                    onChanged: (_) => fetchEmail(),
                  ),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setDialogState(() => gender = v!),
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                  // Added Blood Type Dropdown
                  DropdownButtonFormField<String>(
                    value: bloodType,
                    items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => bloodType = v!),
                    decoration: const InputDecoration(labelText: 'Blood Type'),
                  ),
                  TextFormField(
                    controller: dobCtrl,
                    decoration: InputDecoration(
                      labelText: 'DOB (YYYY-MM-DD)',
                      suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(context, dobCtrl)),
                    ),
                  ),
                  TextFormField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age')),
                  TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), enabled: false),
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
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  List<String> allergiesList = allergiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  
                  final patientData = {
                    'nationalId': nationalIdCtrl.text,
                    'fullName': nameCtrl.text,
                    'gender': gender,
                    'bloodType': bloodType, // Saved to Firestore
                    'dateOfBirth': dobCtrl.text,
                    'age': ageCtrl.text,
                    'email': emailCtrl.text,
                    'phone': phoneCtrl.text,
                    'address': addressCtrl.text,
                    'condition': conditionCtrl.text.isNotEmpty ? conditionCtrl.text : 'None',
                    'assignedDoctor': assignedDoctorCtrl.text,
                    'allergies': allergiesList.isEmpty ? ['None'] : allergiesList,
                    'status': data?['status'] ?? 'Stable',
                    'statusColor': data?['statusColor'] ?? Colors.green.value,
                    'labResults': data?['labResults'] ?? [],
                    'prescriptions': data?['prescriptions'] ?? [],
                  };

                  if (isEdit) {
                    await patientsCollection.doc(doc!.id).update(patientData);
                  } else {
                    await patientsCollection.add(patientData);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- REFACTORED ITEM FORM (Lab/Rx) ----------------
  void _showItemForm({required String type, required String docId, Map<String, dynamic>? item, int? index}) async {
    final formKey = GlobalKey<FormState>();
    
    // Fetch fresh data before editing
    final docSnapshot = await patientsCollection.doc(docId).get();
    final patientData = docSnapshot.data()!;

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
              TextFormField(controller: field1Ctrl, decoration: InputDecoration(labelText: type == 'Lab' ? 'Test' : 'Medication')),
              TextFormField(controller: field2Ctrl, decoration: InputDecoration(labelText: type == 'Lab' ? 'Value' : 'Dosage')),
              TextFormField(controller: field3Ctrl, decoration: InputDecoration(labelText: type == 'Lab' ? 'Status' : 'Instructions')),
              TextFormField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                List<dynamic> list = type == 'Lab' ? List.from(patientData['labResults'] ?? []) : List.from(patientData['prescriptions'] ?? []);

                Map<String, dynamic> newItem = type == 'Lab' 
                  ? {'test': field1Ctrl.text, 'value': field2Ctrl.text, 'status': field3Ctrl.text, 'date': dateCtrl.text, 'color': field3Ctrl.text.toLowerCase().contains('high') ? Colors.orange.value : Colors.green.value}
                  : {'medication': field1Ctrl.text, 'dosage': field2Ctrl.text, 'instructions': field3Ctrl.text, 'date': dateCtrl.text};

                if (item == null) list.add(newItem); else list[index!] = newItem;

                await patientsCollection.doc(docId).update({type == 'Lab' ? 'labResults' : 'prescriptions': list});
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ---------------- PATIENT DETAILS (With StreamBuilder for Real-time) ----------------
  void _openPatientDetails(String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: patientsCollection.doc(docId).snapshots(), // Real-time listener
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            
            final data = snapshot.data!.data()!;
            final displayLabs = (data['labResults'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
            final displayRx = (data['prescriptions'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();

            return Scaffold(
              appBar: AppBar(title: Text(data['fullName'] ?? 'Patient Details')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                          Text(data['fullName'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('${data['age']} yrs • ${data['gender']} • Blood: ${data['bloodType'] ?? 'N/A'}'), // Blood Type Shown
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Color(data['statusColor'] ?? Colors.green.value), borderRadius: BorderRadius.circular(20)),
                            child: Text(data['status'] ?? 'Stable', style: const TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Lab Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...displayLabs.asMap().entries.map((entry) => Card(
                    child: ListTile(
                      title: Text(entry.value['test']),
                      subtitle: Text("${entry.value['status']} • ${entry.value['date']}"),
                      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showItemForm(type: 'Lab', docId: docId, item: entry.value, index: entry.key)),
                    ),
                  )),
                  IconButton(icon: const Icon(Icons.add_circle), onPressed: () => _showItemForm(type: 'Lab', docId: docId)),
                  const SizedBox(height: 20),
                  const Text("Prescriptions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...displayRx.asMap().entries.map((entry) => Card(
                    child: ListTile(
                      title: Text(entry.value['medication']),
                      subtitle: Text(entry.value['instructions']),
                      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showItemForm(type: 'Rx', docId: docId, item: entry.value, index: entry.key)),
                    ),
                  )),
                  IconButton(icon: const Icon(Icons.add_circle), onPressed: () => _showItemForm(type: 'Rx', docId: docId)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Management')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: patientsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final patients = snapshot.data!.docs;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('National ID')),
                DataColumn(label: Text('Patient Name')),
                DataColumn(label: Text('Actions')),
              ],
              rows: patients.map((doc) => DataRow(cells: [
                DataCell(Text(doc['nationalId'] ?? '')),
                DataCell(Text(doc['fullName'] ?? '')),
                DataCell(Row(
                  children: [
                    IconButton(icon: const Icon(Icons.visibility), onPressed: () => _openPatientDetails(doc.id)),
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showPatientForm(doc: doc)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => patientsCollection.doc(doc.id).delete()),
                  ],
                )),
              ])).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showPatientForm(), child: const Icon(Icons.add)),
    );
  }
}
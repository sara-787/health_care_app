import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  Future<Map<String, dynamic>> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      throw Exception('User data not found');
    }

    return doc.data()!;
  }

  Future<void> updateUserData(Map<String, dynamic> newData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(newData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0288D1)));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final data = snapshot.data!;
            final fullName = data['fullName'] ?? 'John Doe';
            final nationalId = data['nationalId'] ?? 'N/A';
            final dob = data['dateOfBirth'] ?? 'N/A';
            final gender = data['gender'] ?? 'N/A';
            final email = FirebaseAuth.instance.currentUser!.email ?? 'No email';
            final phone = data['phone'] ?? '01281662269';
            final address = data['address'] ?? '123 Main Street, City, State 12345';

            final contactInfo = {
              'Phone': phone,
              'Address': address,
            }.map((key, value) => MapEntry(key, value.toString()));

            final emergencyContact = {
              'Name': data['emergencyName'] ?? 'Jane Doe',
              'Relationship': data['emergencyRelationship'] ?? 'Spouse',
              'Phone': data['emergencyPhone'] ?? '+1 555-123-4567',
            }.map((key, value) => MapEntry(key, value.toString()));

            final medicalInfo = {
              'Blood Type': 'O+',
              'Allergies': 'Penicillin',
              'Chronic Conditions': 'None',
            };

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.person,
                              size: 60, color: Color(0xFF0288D1)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Personal Information (Read-only)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileCard(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      fields: {
                        'Full Name': fullName,
                        'National ID': nationalId,
                        'Date of Birth': dob,
                        'Gender': gender,
                        'Email': email,
                      },
                      specialNotes: {'National ID': 'Cannot be changed'},
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contact Information Card with Edit Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileCard(
                      icon: Icons.contact_mail_outlined,
                      title: 'Contact Information',
                      fields: contactInfo,
                      editAction: () {
                        _showEditDialog(
                          context,
                          'Contact Information',
                          contactInfo,
                          (newValues) => updateUserData(newValues),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Medical Information Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileCard(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Medical Information',
                      fields: medicalInfo,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Emergency Contact Card with Edit Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileCard(
                      icon: Icons.emergency_outlined,
                      title: 'Emergency Contact',
                      fields: emergencyContact,
                      editAction: () {
                        _showEditDialog(
                          context,
                          'Emergency Contact',
                          emergencyContact,
                          (newValues) => updateUserData({
                            'emergencyName': newValues['Name'],
                            'emergencyRelationship': newValues['Relationship'],
                            'emergencyPhone': newValues['Phone'],
                          }),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Log Out Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 93, 106, 189),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required Map<String, String> fields,
    Map<String, String>? specialNotes,
    VoidCallback? editAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF0288D1), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0288D1),
                    ),
                  ),
                ],
              ),
              if (editAction != null)
                IconButton(
                  onPressed: editAction,
                  icon: const Icon(Icons.edit, color: Color(0xFF0288D1)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...fields.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;
            final note = specialNotes?[key];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      note,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title,
      Map<String, String> fields, Function(Map<String, String>) onSave) {
    final controllers = <String, TextEditingController>{};
    fields.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $title'),
        content: SingleChildScrollView(
          child: Column(
            children: fields.keys
                .map((key) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: controllers[key],
                        decoration: InputDecoration(
                          labelText: key,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newValues = controllers.map(
                  (key, controller) => MapEntry(key, controller.text));
              await onSave(newValues);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

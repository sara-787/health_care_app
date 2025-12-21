import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // UPDATE using DocumentReference (same as working version)
  Future<void> updateUserData(
      DocumentReference docRef, Map<String, dynamic> newData) async {
    try {
      await docRef.update(newData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          // ✅ SAME QUERY AS WORKING VERSION
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0288D1)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('User data not found'));
            }

            final userDoc = snapshot.data!.docs.first;
            final data = userDoc.data() as Map<String, dynamic>;

            // -------- DATA PARSING (UNCHANGED) --------
            final fullName = data['fullName'] ?? data['name'] ?? 'N/A';
            final email = data['email'] ?? currentUser!.email ?? 'N/A';
            final nationalId = data['nationalId'] ?? 'N/A';
            final dob = data['dateOfBirth'] ?? 'Not Set';
            final gender = data['gender'] ?? 'Not Set';
            final phone = data['phone'] ?? '';
            final address = data['address'] ?? '';
            final emName = data['emergencyName'] ?? '';
            final emRel = data['emergencyRelationship'] ?? '';
            final emPhone = data['emergencyPhone'] ?? '';
            final bloodType = data['bloodType'] ?? 'Not Set';
            final condition = data['condition'] ?? 'None';
            final allergiesList = data['allergies'] as List<dynamic>?;
            final allergiesString =
                (allergiesList != null && allergiesList.isNotEmpty)
                    ? allergiesList.join(', ')
                    : 'None';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                              Text(fullName,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(email,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Personal Information
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

                  // Medical Information (blood + allergies kept)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileCard(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Medical Information',
                      fields: {
                        'Blood Type': bloodType,
                        'Condition': condition,
                        'Allergies': allergiesString,
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contact Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileCard(
                      icon: Icons.contact_mail_outlined,
                      title: 'Contact Information',
                      fields: {
                        'Phone': phone,
                        'Address': address,
                      },
                      editAction: () {
                        _showEditDialog(
                          context,
                          'Contact Info',
                          {'Phone': phone, 'Address': address},
                          (values) => updateUserData(userDoc.reference, {
                            'phone': values['Phone'],
                            'address': values['Address'],
                          }),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Emergency Contact
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileCard(
                      icon: Icons.emergency_outlined,
                      title: 'Emergency Contact',
                      fields: {
                        'Name': emName,
                        'Relationship': emRel,
                        'Phone': emPhone,
                      },
                      editAction: () {
                        _showEditDialog(
                          context,
                          'Emergency Contact',
                          {
                            'Name': emName,
                            'Relationship': emRel,
                            'Phone': emPhone,
                          },
                          (values) => updateUserData(userDoc.reference, {
                            'emergencyName': values['Name'],
                            'emergencyRelationship': values['Relationship'],
                            'emergencyPhone': values['Phone'],
                          }),
                        );
                      },
                    ),
                  ),

                  // Logout
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
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

  // ---------- UI HELPERS (UNCHANGED) ----------

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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0288D1))),
                ],
              ),
              if (editAction != null)
                IconButton(
                  onPressed: editAction,
                  icon: const Icon(Icons.edit,
                      color: Color(0xFF0288D1)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...fields.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(e.value,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                    if (specialNotes?[e.key] != null)
                      Text(specialNotes![e.key]!,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.orange)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title,
      Map<String, String> fields, Function(Map<String, String>) onSave) {
    final controllers = {
      for (var e in fields.entries)
        e.key: TextEditingController(text: e.value)
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controllers.entries
              .map((e) => TextField(
                    controller: e.value,
                    decoration: InputDecoration(labelText: e.key),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                onSave(controllers
                    .map((k, v) => MapEntry(k, v.text.trim())));
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }
}

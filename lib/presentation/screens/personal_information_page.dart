import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: const Color(0xFF81D4FA),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF81D4FA)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          final email = FirebaseAuth.instance.currentUser!.email ?? '';

          // Fetch specific fields
          final fullName = data['fullName'] ?? data['name'] ?? 'N/A';
          final nationalId = data['nationalId'] ?? 'N/A';
          final dob = data['dateOfBirth'] ?? 'Not Set';
          final gender = data['gender'] ?? 'Not Set';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _infoCard(Icons.person, 'Full Name', fullName),
                const SizedBox(height: 12),
                _infoCard(Icons.email, 'Email', email),
                const SizedBox(height: 12),
                _infoCard(Icons.badge, 'National ID', nationalId),
                const SizedBox(height: 12),
                _infoCard(Icons.calendar_today, 'Date of Birth', dob),
                const SizedBox(height: 12),
                _infoCard(Icons.wc, 'Gender', gender),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0288D1), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0288D1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
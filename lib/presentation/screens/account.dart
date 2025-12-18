import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/account_menu.dart';
import 'personal_information_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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

            return Column(
              children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['fullName'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),


                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      AccountMenuItem(
                        icon: Icons.person,
                        title: 'Personal Information',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const PersonalInformationPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const AccountMenuItem(
                        icon: Icons.monitor_heart_outlined,
                        title: 'Medical Information',
                      ),
                      const SizedBox(height: 16),
                      const AccountMenuItem(
                        icon: Icons.emergency_outlined,
                        title: 'Emergency Contact',
                      ),
                      const SizedBox(height: 16),
                      const AccountMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                      ),
                      const SizedBox(height: 16),
                      const AccountMenuItem(
                        icon: Icons.help_outline,
                        title: 'Help',
                      ),
                      const SizedBox(height: 16),
                      const AccountMenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                      ),
                    ],
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Log Out'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

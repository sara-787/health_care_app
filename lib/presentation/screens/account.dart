import 'package:flutter/material.dart';
import 'package:health_care_app/widgets/account_menu.dart';
class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Sam',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.edit, size: 18, color: Color.fromARGB(255, 76, 140, 175)),
                        ],
                      ),
                      const Text(
                        'sam@gmail.com',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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
                children: const [
                  AccountMenuItem(icon: Icons.person, title: 'Personal Information'),
                  SizedBox(height: 16,),
                  AccountMenuItem(icon: Icons.monitor_heart_outlined, title: 'Medical Information'),
                  SizedBox(height: 16,),
                  AccountMenuItem(icon: Icons.emergency_outlined, title: 'Emergency Contact'),
                  SizedBox(height: 16,),
                  AccountMenuItem(icon: Icons.notifications_outlined, title: 'Notifications'),
                  SizedBox(height: 16,),
                  AccountMenuItem(icon: Icons.help_outline, title: 'Help'),
                  SizedBox(height: 16,),
                  AccountMenuItem(icon: Icons.info_outline, title: 'About'),
                  SizedBox(height: 16,),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/getStarted');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 62, 134, 176),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: const BorderSide(color: Color.fromARGB(255, 93, 114, 208), width: 1.5),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

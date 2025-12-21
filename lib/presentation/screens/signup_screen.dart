import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Check if National ID already exists (Pre-registered by Admin)
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('nationalId', isEqualTo: nationalIdController.text.trim())
          .limit(1)
          .get();

      // 2. Create Authentication User
      UserCredential credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = credential.user!.uid;
      String email = emailController.text.trim();
      String name = nameController.text.trim();
      String nationalId = nationalIdController.text.trim();

      // 3. Save Data to Firestore
      if (query.docs.isNotEmpty) {
        // SCENARIO A: Admin already added this National ID.
        // We update the EXISTING document to link it to this Auth account.
        final userDoc = query.docs.first;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .update({
          'uid': uid,
          'email': email,
          'fullName': name,
          'name': name, // Update name in case user spells it differently than admin
        });
      } else {
        // SCENARIO B: New User (Not in system).
        // We create a NEW document. We must add default fields so it shows up
        // correctly in the Admin Panel.
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'fullName': name,
          'name': name,
          'nationalId': nationalId,
          // Default values for Admin Dashboard compatibility
          'role': 'patient',
          'status': 'Stable',
          'statusColor': Colors.green.value,
          'gender': 'Not Specified',
          'age': '',
          'dateOfBirth': '',
          'phone': '',
          'address': '',
          'condition': 'None',
          'allergies': [],
          'labResults': [],
          'prescriptions': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful!')),
        );

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Dashboard()));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'An error occurred: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nationalIdController,
                      decoration: const InputDecoration(
                        labelText: 'National ID',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter National ID';
                        if (v.length != 14) {
                          return 'National ID must be 14 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      // Removed ReadOnly: User must enter their email to sign up
                      readOnly: false,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter Email';
                        if (!v.contains('@')) return 'Invalid Email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
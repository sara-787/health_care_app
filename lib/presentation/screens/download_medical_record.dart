import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FirebaseRecordsPage extends StatelessWidget {
  const FirebaseRecordsPage({super.key});

  // Function to handle File Download
  Future<void> downloadFile(BuildContext context, String url, String fileName) async {
    try {
      // 1. Check Permission (Android 10+ doesn't need external storage perm mostly, but good practice)
      // For simplicity in this example, we save to the App Documents directory

      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Starting download...')),
      );

      // 2. Download using Dio
      await Dio().download(url, savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded to $savePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloud Records")),
      body: StreamBuilder<QuerySnapshot>(
        // Fetching from Firebase collection 'medical_records'
        stream: FirebaseFirestore.instance.collection('medical_records').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No records found in cloud."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Safely get data with fallbacks
              String title = data['title'] ?? 'Untitled Record';
              String url = data['file_url'] ?? ''; // The PDF link in Firebase

              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(title),
                subtitle: Text(data['date'] ?? 'No date'),
                trailing: IconButton(
                  icon: const Icon(Icons.cloud_download),
                  onPressed: () {
                    if (url.isNotEmpty) {
                      downloadFile(context, url, '$title.pdf');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No file URL found for this record')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
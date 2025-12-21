import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'RecordDetailPage.dart';


class MedicalRecord extends StatefulWidget {
  const MedicalRecord({super.key});

  @override
  State<MedicalRecord> createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "";

  // ---------------------------------------------------------------------------
  // HELPER METHODS
  // ---------------------------------------------------------------------------

  Color getTagColor(String type) {
    switch (type) {
      case 'Checkup':
        return Colors.green.shade100;
      case 'Lab Result':
        return Colors.orange.shade100;
      case 'Prescription':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color getTagTextColor(String type) {
    switch (type) {
      case 'Checkup':
        return Colors.green.shade800;
      case 'Lab Result':
        return Colors.orange.shade800;
      case 'Prescription':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  // ---------------------------------------------------------------------------
  // ACTIONS (Share & Download)
  // ---------------------------------------------------------------------------

  void _shareRecord(Map<String, dynamic> record) {
    String content =
        'Medical Record: ${record['title']}\nDate: ${record['date']}';
    if (record['url'] != null && record['url'].isNotEmpty) {
      content += '\nDownload: ${record['url']}';
    } else {
      content += '\nDetails: ${record['description']}';
    }
    Share.share(content);
  }

  Future<void> _downloadRecord(
      BuildContext context, Map<String, dynamic> record) async {
    if (record['url'] == null || record['url'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('This record is text-only (No PDF attached).')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading file... Please wait.')),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          "${record['title'].toString().replaceAll(RegExp(r'[^\w\s]+'), '')}.pdf";
      final savePath = '${dir.path}/$fileName';

      await Dio().download(record['url'], savePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ File Saved! Location: $savePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Download Failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
          body: Center(child: Text("Please login to view records")));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Medical Records',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Your personal health history',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search records...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Firestore Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // --- FIX: Query by 'uid' field instead of Document ID ---
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('uid', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No patient record found.'));
                  }

                  // Since we query by unique UID, we take the first matching document
                  final userDoc = snapshot.data!.docs.first;
                  final userData = userDoc.data() as Map<String, dynamic>;
                  final String assignedDoctor =
                      userData['assignedDoctor'] ?? 'General Doctor';

                  List<Map<String, dynamic>> allItems = [];

                  // 2. Parse Lab Results
                  if (userData['labResults'] != null) {
                    for (var item in userData['labResults']) {
                      allItems.add({
                        'title': item['test'] ?? 'Unknown Test',
                        'type': 'Lab Result',
                        'description':
                        'Value: ${item['value']} | Status: ${item['status']}',
                        'date': item['date'] ?? 'No Date',
                        'doctor': assignedDoctor,
                        'url': '',
                        'raw': item,
                      });
                    }
                  }

                  // 3. Parse Prescriptions
                  if (userData['prescriptions'] != null) {
                    for (var item in userData['prescriptions']) {
                      allItems.add({
                        'title': item['medication'] ?? 'Unknown Med',
                        'type': 'Prescription',
                        'description':
                        'Dosage: ${item['dosage']} | ${item['instructions']}',
                        'date': item['date'] ?? 'No Date',
                        'doctor': assignedDoctor,
                        'url': '',
                        'raw': item,
                      });
                    }
                  }

                  // 4. Filter Logic
                  final filteredRecords = allItems.where((item) {
                    final title = item['title'].toString().toLowerCase();
                    return _searchKeyword.isEmpty ||
                        title.contains(_searchKeyword);
                  }).toList();

                  if (filteredRecords.isEmpty) {
                    return const Center(child: Text('No records found.'));
                  }

                  // 5. Build List
                  return ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: getTagColor(record['type']),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        record['type'],
                                        style: TextStyle(
                                          color:
                                          getTagTextColor(record['type']),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      record['title'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      record['description'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 4,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 16,
                                                color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(record['date'],
                                                style: TextStyle(
                                                    color:
                                                    Colors.grey.shade600)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.person,
                                                size: 16,
                                                color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(record['doctor'],
                                                style: TextStyle(
                                                    color:
                                                    Colors.grey.shade600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecordDetailPage(data: record),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                    ),
                                    child: const Text('View'),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (record['url'] != null &&
                                          record['url'].isNotEmpty)
                                        IconButton(
                                          onPressed: () =>
                                              _downloadRecord(context, record),
                                          icon: const Icon(Icons.download),
                                          tooltip: 'Download',
                                        ),
                                      IconButton(
                                        onPressed: () => _shareRecord(record),
                                        icon: const Icon(Icons.share),
                                        tooltip: 'Share',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
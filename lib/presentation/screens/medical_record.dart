import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'RecordDetailPage.dart';

// ---------------------------------------------------------------------------
// 1. The Main Page (MedicalRecord)
// ---------------------------------------------------------------------------

class MedicalRecord extends StatefulWidget {
  const MedicalRecord({super.key});

  @override
  State<MedicalRecord> createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  final TextEditingController _searchController = TextEditingController();

  // STATIC DATA
  final List<Map<String, dynamic>> _allRecords = [
    {
      'title': 'Annual Physical Examination',
      'type': 'Checkup',
      'description': 'Routine health check including blood pressure, cholesterol, and general wellness. Patient showed good vitals.',
      'date': 'November 15, 2025',
      'doctor': 'Dr. Sarah Johnson',
      'fileType': 'PDF',
      'fileSize': '2.4 MB',
      'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
    },
    {
      'title': 'Blood Test Results',
      'type': 'Lab Result',
      'description': 'Complete blood count (CBC) and metabolic panel results. Hemoglobin levels are normal.',
      'date': 'October 28, 2025',
      'doctor': 'Dr. Michael Chen',
      'fileType': 'PDF',
      'fileSize': '1.1 MB',
      'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
    },
    {
      'title': 'X-Ray Report - Chest',
      'type': 'Report',
      'description': 'Chest X-ray following mild respiratory symptoms. No signs of infection found.',
      'date': 'September 5, 2025',
      'doctor': 'Dr. Emily Rodriguez',
      'fileType': 'PDF',
      'fileSize': '4.8 MB',
      'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
    },
  ];

  List<Map<String, dynamic>> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _filteredRecords = _allRecords;
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allRecords;
    } else {
      results = _allRecords
          .where((item) =>
      item["title"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          item["doctor"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredRecords = results;
    });
  }

  void _shareRecord(Map<String, dynamic> record) {
    Share.share(
      'Medical Record Shared:\nTitle: ${record['title']}\nDownload here: ${record['url']}',
    );
  }

  // DOWNLOAD LOGIC
  Future<void> _downloadRecord(BuildContext context, Map<String, dynamic> record) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading file... Please wait.')),
      );

      // This gets the internal app folder
      final dir = await getApplicationDocumentsDirectory();
      // We name the file based on the record title
      final fileName = "${record['title'].replaceAll(' ', '_')}.pdf";
      final savePath = '${dir.path}/$fileName';

      // Actual download
      await Dio().download(record['url'], savePath);

      if (context.mounted) {
        // SUCCESS MESSAGE - This proves it downloaded
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ File Saved! Location: $savePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        print("File saved to: $savePath"); // Check your 'Run' console too
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color getTagColor(String type) {
    switch (type) {
      case 'Checkup': return Colors.green.shade100;
      case 'Lab Result': return Colors.orange.shade100;
      case 'Report': return Colors.blue.shade100;
      default: return Colors.grey.shade100;
    }
  }

  Color getTagTextColor(String type) {
    switch (type) {
      case 'Checkup': return Colors.green.shade800;
      case 'Lab Result': return Colors.orange.shade800;
      case 'Report': return Colors.blue.shade800;
      default: return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Medical Records',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Access your health documents',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: 'Search medical records...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _filteredRecords.isEmpty
                  ? const Center(child: Text('No records found'))
                  : ListView.builder(
                itemCount: _filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: getTagColor(record['type']),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    record['type'],
                                    style: TextStyle(
                                      color: getTagTextColor(record['type']),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  record['title'],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  record['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12, runSpacing: 4,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(record['date'], style: TextStyle(color: Colors.grey.shade600)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(record['doctor'], style: TextStyle(color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              // ----------------------------------------------------
                              // VIEW BUTTON: NOW NAVIGATES TO DETAILS PAGE
                              // ----------------------------------------------------
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to the new page and pass the data
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecordDetailPage(data: record),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('View'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _downloadRecord(context, record),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
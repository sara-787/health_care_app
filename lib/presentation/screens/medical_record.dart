import 'package:flutter/material.dart';

class MedicalRecord extends StatefulWidget {
  const MedicalRecord({super.key});

  @override
  State<MedicalRecord> createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  // Sample data
  final List<Map<String, dynamic>> records = [
    {
      'title': 'Annual Physical Examination',
      'type': 'Checkup',
      'description':
          'Routine health check including blood pressure, cholesterol, and general wellness.',
      'date': 'November 15, 2025',
      'doctor': 'Dr. Sarah Johnson',
      'fileType': 'PDF',
      'fileSize': '2.4 MB',
    },
    {
      'title': 'Blood Test Results',
      'type': 'Lab Result',
      'description': 'Complete blood count and metabolic panel results.',
      'date': 'October 28, 2025',
      'doctor': 'Dr. Michael Chen',
      'fileType': 'PDF',
      'fileSize': '1.1 MB',
    },
    {
      'title': 'X-Ray Report - Chest',
      'type': 'Report',
      'description': 'Chest X-ray following mild respiratory symptoms.',
      'date': 'September 5, 2025',
      'doctor': 'Dr. Emily Rodriguez',
      'fileType': 'PDF',
      'fileSize': '4.8 MB',
    },
    {
      'title': 'Cardiology Consultation',
      'type': 'Report',
      'description': 'Follow-up on ECG and heart health assessment.',
      'date': 'August 20, 2025',
      'doctor': 'Dr. Robert Lee',
      'fileType': 'PDF',
      'fileSize': '3.2 MB',
    },
  ];

  Color getTagColor(String type) {
    switch (type) {
      case 'Checkup':
        return Colors.green.shade100;
      case 'Lab Result':
        return Colors.orange.shade100;
      case 'Report':
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
      case 'Report':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
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
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Access your health documents and reports',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: ElevatedButton.icon(
        //       onPressed: () {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(
        //             content: Text('Upload Record feature coming soon'),
        //           ),
        //         );
        //       },
        //       icon: const Icon(Icons.cloud_upload),
        //       label: const Text('Upload Record'),
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Theme.of(context).colorScheme.primary,
        //         foregroundColor: Colors.white,
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 20,
        //           vertical: 14,
        //         ),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(30),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search medical records...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            // Records List
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  record['description'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record['date'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record['doctor'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${record['fileType']} • ${record['fileSize']}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Viewing ${record['title']}',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('View'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.download),
                                    tooltip: 'Download',
                                  ),
                                  IconButton(
                                    onPressed: () {},
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

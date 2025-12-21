import 'package:flutter/material.dart';

class RecordDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const RecordDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Determine the icon and color based on type
    IconData typeIcon = Icons.description;
    Color themeColor = Colors.blue;

    if (data['type'] == 'Lab Result') {
      typeIcon = Icons.science;
      themeColor = Colors.orange;
    } else if (data['type'] == 'Prescription') {
      typeIcon = Icons.medication;
      themeColor = Colors.blue;
    }

    // Extract raw data for specific fields
    final raw = data['raw'] ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Record Details"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, size: 40, color: themeColor),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              data['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(data['type'],
                  style: TextStyle(
                      color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 24),

            // General Details
            _buildDetailRow(Icons.calendar_today, "Date", data['date']),
            const Divider(height: 24),
            _buildDetailRow(Icons.person, "Assigned Doctor", data['doctor']),
            const Divider(height: 24),

            // SPECIFIC DATA BASED ON TYPE
            if (data['type'] == 'Lab Result') ...[
              _buildDetailRow(Icons.analytics, "Result Value", raw['value'] ?? 'N/A'),
              const Divider(height: 24),
              _buildDetailRow(Icons.grading, "Status", raw['status'] ?? 'N/A'),
            ] else if (data['type'] == 'Prescription') ...[
              _buildDetailRow(Icons.numbers, "Dosage", raw['dosage'] ?? 'N/A'),
              const Divider(height: 24),
              _buildDetailRow(Icons.info_outline, "Instructions", raw['instructions'] ?? 'N/A'),
            ],

            const SizedBox(height: 24),

            // Description / Raw data Summary
            const Text(
              "Full Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              data['description'],
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
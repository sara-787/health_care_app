import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadMedicalRecord extends StatefulWidget {
  const DownloadMedicalRecord({super.key});

  @override
  State<DownloadMedicalRecord> createState() => _DownloadMedicalRecordState();
}

class _DownloadMedicalRecordState extends State<DownloadMedicalRecord> {
  bool _isDownloading = false;
  String? _downloadMessage;

  Future<void> _downloadFile(String url, String fileName) async {
    setState(() {
      _isDownloading = true;
      _downloadMessage = "Downloading...";
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      await Dio().download(url, filePath);

      if (!mounted) return; // Fixed use_build_context_synchronously
      setState(() {
        _downloadMessage = "Downloaded successfully!\nSaved to: $filePath";
      });
    } catch (e) {
      if (!mounted) return; // Fixed
      setState(() {
        _downloadMessage = "Download failed: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download Medical Record")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDownloading) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isDownloading
                  ? null
                  : () => _downloadFile(
                "https://example.com/sample-report.pdf",
                "medical_report.pdf",
              ),
              child: const Text("Download Sample Report"),
            ),
            const SizedBox(height: 20),
            if (_downloadMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _downloadMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
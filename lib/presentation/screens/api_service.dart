import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;
import 'patient_model.dart';

class ApiService {
  // Determine the correct Base URL safely
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000'; // Localhost for Web
    } else {
      // For Android Emulator, use 10.0.2.2. For real phones, use your PC's IP.
      return 'http://10.0.2.2:8000';
    }
  }

  static Future<Patient?> fetchPatientData() async {
    try {
      final uri = Uri.parse('$baseUrl/patients');
      print('Fetching: $uri'); // Debug log

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Return the first patient (P001)
          return Patient.fromJson(data[0]);
        }
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Connection Error: $e');
      throw Exception('Failed to connect to backend. Is run_all.py running?');
    }
    return null;
  }
}
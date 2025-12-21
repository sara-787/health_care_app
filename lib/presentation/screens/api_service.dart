import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'; // For debugPrint and kIsWeb
import 'package:http/http.dart' as http;

import 'patient_model.dart';

class ApiService {
  // Determine the correct Base URL safely
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000'; // Localhost for Web
    } else {
      // For Android Emulator: use 10.0.2.2
      // For physical device: replace with your PC's local IP (e.g., 192.168.x.x)
      return 'http://10.0.2.2:8000';
    }
  }

  /// Fetches patient data from the backend API
  /// Returns the first patient (assumed to be the logged-in user) or null if not found
  static Future<Patient?> fetchPatientData() async {
    try {
      final uri = Uri.parse('$baseUrl/patients');
      debugPrint('Fetching patient data from: $uri');

      final response = await http.get(uri).timeout(
          const Duration(seconds: 10)); // Increased timeout for reliability

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          debugPrint('Patient data received successfully');
          return Patient.fromJson(data[0] as Map<String, dynamic>);
        } else {
          debugPrint('No patients found in response');
          return null;
        }
      } else {
        debugPrint('Server returned error: ${response.statusCode}');
        return null;
      }
    } on http.ClientException catch (e) {
      debugPrint('Network error: $e');
      throw Exception('Network error. Check your connection.');
    } on TimeoutException catch (_) {
      debugPrint('Request timed out');
      throw Exception('Server took too long to respond. Try again.');
    } catch (e) {
      debugPrint('Unexpected error while fetching patient data: $e');
      throw Exception('Failed to connect to backend. Is the server running?');
    }
  }
}

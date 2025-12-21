import 'dart:convert';
import 'package:http/http.dart' as http;
import 'patient_model.dart';

class ApiService {
  // ANDROID EMULATOR: Use 'http://10.0.2.2:8000'
  // REAL PHONE: Use your PC IP 'http://192.168.x.x:8000'
  // iOS SIMULATOR: Use 'http://127.0.0.1:8000'
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<Patient?> fetchPatientData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/patients'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Patient.fromJson(data[0]);
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }

  static Future<String> sendChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'];
      }
    } catch (e) {
      return "Error: Could not connect to AI server.";
    }
    return "Error: Something went wrong.";
  }
}
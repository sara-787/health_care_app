import 'dart:math';
import 'patient_model.dart';

class SimulationService {
  // Singleton pattern to make sure data stays consistent
  static final SimulationService _instance = SimulationService._internal();
  factory SimulationService() => _instance;
  SimulationService._internal();

  // Internal state (Simulates the Database)
  int _hr = 75;
  double _temp = 37.0;
  int _steps = 5200;
  final Random _rng = Random();

  Patient getNextPatientData() {
    // 1. Simulate Heart Rate (Random small changes)
    int change = _rng.nextInt(6) - 2; // -2 to +3
    _hr += change;
    if (_hr > 100) _hr -= 3;
    if (_hr < 60) _hr += 3;

    // 2. Simulate Temperature
    double tempChange = (_rng.nextDouble() * 0.2) - 0.1;
    _temp += tempChange;
    // Keep reasonable limits
    if (_temp < 36.0) _temp = 36.0;
    if (_temp > 39.0) _temp = 39.0;

    // 3. Simulate Steps (Occasionally increase)
    if (_rng.nextDouble() < 0.3) {
      _steps += _rng.nextInt(5);
    }

    // 4. Simulate Critical Events (5% chance)
    String status = "NORMAL";
    String risk = "Low Risk";
    double confidence = 0.1;

    // Random spike logic
    if (_rng.nextDouble() < 0.05) {
      _hr = 110 + _rng.nextInt(20);
      status = "WARNING";
      risk = "Moderate Risk";
      confidence = 0.65;
    }

    return Patient(
      id: "P001",
      name: "Maryam Ahmed", // Customize with your name or user's name
      heartRate: _hr,
      temperature: double.parse(_temp.toStringAsFixed(1)),
      spo2: 98,
      steps: _steps,
      status: status,
      riskLevel: risk,
      confidence: confidence,
    );
  }
}
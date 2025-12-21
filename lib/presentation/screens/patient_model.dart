class Patient {
  final String id;
  final String name;
  final int heartRate;
  final double temperature;
  final int spo2;
  final int steps;       // Matches 'steps' in api.py
  final String status;   // Matches 'health_status' in api.py
  final String riskLevel;
  final double confidence;

  Patient({
    required this.id,
    required this.name,
    required this.heartRate,
    required this.temperature,
    required this.spo2,
    required this.steps,
    required this.status,
    required this.riskLevel,
    required this.confidence,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['patient_id'] ?? '',
      name: json['full_name'] ?? 'Unknown',
      heartRate: json['heart_rate_bpm'] ?? 0,
      temperature: (json['temperature_c'] ?? 0).toDouble(),
      spo2: json['spo2_percent'] ?? 0,
      steps: json['steps'] ?? 0,
      status: json['health_status'] ?? 'NORMAL',
      riskLevel: json['risk_level'] ?? 'Low',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}
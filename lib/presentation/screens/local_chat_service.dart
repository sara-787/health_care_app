import 'patient_model.dart';

class LocalChatService {
  static String getResponse(String message, Patient currentData) {
    String msg = message.toLowerCase();

    if (msg.contains("heart") || msg.contains("hr")) {
      String status = (currentData.heartRate >= 60 && currentData.heartRate <= 100)
          ? "normal"
          : "abnormal";
      return "The patient's heart rate is ${currentData.heartRate} bpm, which is considered $status.";
    }
    else if (msg.contains("temp")) {
      return "Current body temperature is ${currentData.temperature}°C.";
    }
    else if (msg.contains("spo2") || msg.contains("oxygen")) {
      return "Oxygen saturation levels are at ${currentData.spo2}%.";
    }
    else if (msg.contains("step")) {
      return "The patient has recorded ${currentData.steps} steps so far today.";
    }
    else if (msg.contains("status") || msg.contains("condition")) {
      return "The overall health status is marked as: ${currentData.status}.";
    }
    else if (msg.contains("risk")) {
      return "AI Risk Assessment: ${currentData.riskLevel} (Confidence: ${(currentData.confidence * 100).toStringAsFixed(1)}%).";
    }
    else if (msg.contains("hello") || msg.contains("hi")) {
      return "Hello! I'm your medical assistant. You can ask me about the patient's vitals, steps, or risk level.";
    }

    return "I can track Heart Rate, Temperature, SpO2, Steps, and Risk Level. What would you like to know?";
  }
}
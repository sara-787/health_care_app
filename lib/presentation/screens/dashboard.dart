import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Your existing screen imports
import 'package:health_care_app/presentation/screens/account.dart';
import 'package:health_care_app/presentation/screens/medical_record.dart';
import 'chat_screen.dart';
import 'patient_model.dart';
import 'simulation_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentPageIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const DashboardContent(),
      const MedicalRecord(),
      const Account(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[currentPageIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatBotScreen()),
          );
        },
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        currentIndex: currentPageIndex,
        onTap: (index) => setState(() => currentPageIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Medical'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  Patient? _patient;
  Timer? _timer;
  final List<FlSpot> _hrHistory = [];
  double _timeCounter = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser; // Get logged in user

  @override
  void initState() {
    super.initState();
    _loadSimulatedVitals();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadSimulatedVitals());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadSimulatedVitals() {
    final patientData = SimulationService().getNextPatientData();
    if (mounted) {
      setState(() {
        _patient = patientData;
        _hrHistory.add(FlSpot(_timeCounter++, patientData.heartRate.toDouble()));
        if (_hrHistory.length > 20) _hrHistory.removeAt(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("User session not found. Please log in."));
    }

    // Wrap the UI in a StreamBuilder to get real-time info from Firebase
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: currentUser!.uid) // Finding doc by the field we updated in sign up
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        String firebaseName = "User"; // Default fallback
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          firebaseName = userData['fullName'] ?? userData['name'] ?? "User"; // Fetching name
        }

        if (_patient == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "HealthCare Plus",
              style: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 20),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(firebaseName), // Pass name from Firebase
                const SizedBox(height: 24),
                _buildVitalsGrid(),
                const SizedBox(height: 24),
                _buildAppointmentCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(String displayName) {
    bool isCritical = _patient?.status == 'WARNING' || _patient?.status == 'CRITICAL';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCritical
              ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
              : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isCritical ? Colors.red : Colors.blue).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back, ${displayName.split(' ')[0]}!", // Greets user with first name
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _patient?.status ?? 'Unknown',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Risk Level: ${_patient?.riskLevel}",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildVitalCard("Heart Rate", "${_patient?.heartRate} bpm", Icons.favorite_border, Colors.redAccent, _hrHistory, cardWidth),
            _buildVitalCard("Temperature", "${_patient?.temperature} °C", Icons.thermostat, Colors.orangeAccent, [], cardWidth),
            _buildVitalCard("SpO2", "${_patient?.spo2} %", Icons.air, Colors.purpleAccent, [], cardWidth),
            _buildVitalCard("Steps", "${_patient?.steps}", Icons.directions_walk, Colors.green, [], cardWidth),
          ],
        );
      },
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color, List<FlSpot> chartData, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          if (chartData.isNotEmpty)
            SizedBox(
              height: 40,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData:  FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5')),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dr. Sarah Johnson", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              Text("Cardiologist", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Text("10:00 AM", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}
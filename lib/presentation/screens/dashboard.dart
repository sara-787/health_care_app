import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your specific screens and models
import 'package:health_care_app/presentation/screens/account.dart';
import 'package:health_care_app/presentation/screens/medical_record.dart';
import 'chat_screen.dart';
import 'patient_model.dart';
import 'api_service.dart';

// ==========================================
// 1. MAIN WRAPPER (Handles Navigation)
// ==========================================
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentPageIndex = 0;

  // The list of pages to switch between
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const DashboardContent(), // <--- The rich UI from your second file
      const MedicalRecord(),    // Your existing screen
      const Account(),          // Your existing screen
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We removed the generic AppBar here so the DashboardContent
      // can show its own custom "HealthCare Plus" header.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: pages[currentPageIndex],
      ),
      // ADD THIS FLOATING BUTTON:
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Good for 3+ items
        selectedItemColor: const Color.fromARGB(255, 74, 116, 233),
        unselectedItemColor: Colors.grey,
        currentIndex: currentPageIndex,
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medical',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. DASHBOARD CONTENT (The Rich UI Logic)
// ==========================================
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  Patient? _patient;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;

  // Chart Data
  final List<FlSpot> _hrHistory = [];
  double _timeCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Refresh data every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final patient = await ApiService.fetchPatientData();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null; // Clear errors if successful
          if (patient != null) {
            _patient = patient;
            // Add point to chart
            _hrHistory.add(FlSpot(_timeCounter++, patient.heartRate.toDouble()));
            // Keep only last 20 points for a moving window
            if (_hrHistory.length > 20) _hrHistory.removeAt(0);
          }
        });
      }
    } catch (e) {
      if (mounted && _patient == null) {
        // Only show full-screen error if we have NO data yet
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Handle Loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Handle Error (Initial Load)
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              "Could not load data",
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_errorMessage!, textAlign: TextAlign.center),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadData();
              },
              child: const Text("Retry Connection"),
            )
          ],
        ),
      );
    }

    // 3. Main Dashboard UI
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
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
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildVitalsGrid(),
            const SizedBox(height: 24),
            _buildAppointmentCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    bool isCritical = _patient?.status == 'CRITICAL';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCritical
              ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)] // Red if critical
              : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)], // Blue normally
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
            "Welcome back, ${_patient?.name.split(' ')[0] ?? 'User'}!",
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
                "AI Risk Level: ${_patient?.riskLevel}",
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
        // Responsive: 2 columns on mobile, 4 on larger screens
        final width = constraints.maxWidth > 600
            ? (constraints.maxWidth - 20) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildCard(
              title: "Heart Rate",
              value: "${_patient?.heartRate} bpm",
              icon: Icons.favorite_border,
              color: Colors.redAccent,
              chartData: _hrHistory,
              width: (constraints.maxWidth - 16) / 2, // Half width
            ),
            _buildCard(
              title: "Temperature",
              value: "${_patient?.temperature} °C",
              icon: Icons.thermostat,
              color: Colors.orangeAccent,
              chartData: [], // Add history if you want
              width: (constraints.maxWidth - 16) / 2,
            ),
            _buildCard(
              title: "SpO2",
              value: "${_patient?.spo2} %",
              icon: Icons.air,
              color: Colors.purpleAccent,
              chartData: [],
              width: (constraints.maxWidth - 16) / 2,
            ),
            _buildCard(
              title: "Steps",
              value: "${_patient?.steps} ",
              icon: Icons.directions_walk,
              color: Colors.green,
              chartData: [],
              width: (constraints.maxWidth - 16) / 2,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<FlSpot> chartData,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          // Mini Chart
          SizedBox(
            height: 40,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.isEmpty ? [const FlSpot(0, 0)] : chartData,
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
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
          const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
          ),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("10:00 AM", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:health_care_app/config/routes/routes_handler.dart';
import 'package:health_care_app/config/routes/routes_name.dart';
import 'package:health_care_app/presentation/screens/splash_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health App',
      home: const SplashScreen(),
      initialRoute: RoutesName.getStarted,
      onGenerateRoute: RoutesHandler.generateRoute,
    );
  }
}
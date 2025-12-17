import 'package:flutter/material.dart';
import 'package:health_care_app/config/routes/routes_handler.dart';
import 'package:health_care_app/presentation/screens/splash_screen.dart';
import 'firebase/firebase_init.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
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
      onGenerateRoute: RoutesHandler.generateRoute,
    );
  }
}

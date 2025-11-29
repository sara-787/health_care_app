import 'package:flutter/material.dart';
import 'package:health_care_app/config/routes/routes_handler.dart';
import 'package:health_care_app/config/routes/routes_name.dart';


void main() {
  runApp(const MyApp());
}
// app
class MyApp extends StatelessWidget {
  const MyApp({super.key}); 
  
  @override
  Widget build(BuildContext context) { 
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      initialRoute: RoutesName.accountScreen,
      onGenerateRoute: RoutesHandler.generateRoute,
    );
  }
}

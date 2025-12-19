import 'package:flutter/material.dart';
import 'package:health_care_app/presentation/screens/account.dart';
import 'package:health_care_app/config/routes/routes_name.dart';
import 'package:health_care_app/presentation/screens/authchoose_screen.dart';
import 'package:health_care_app/presentation/screens/dashboard.dart';
import 'package:health_care_app/presentation/screens/getstarted_screen.dart';
import 'package:health_care_app/presentation/screens/login_screen.dart';
import 'package:health_care_app/presentation/screens/medical_record.dart';
import 'package:health_care_app/presentation/screens/patient_management_page.dart';
import 'package:health_care_app/presentation/screens/signup_screen.dart';


class RoutesHandler {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

        case RoutesName.login:
        return MaterialPageRoute(
          builder:(context)=> LoginPage(),
          );
        case RoutesName.signUp:
        return MaterialPageRoute(
          builder:(context)=> SignUpPage(),
          ); 
          case RoutesName.authchooseScreen:
        return MaterialPageRoute(
          builder:(context)=> AuthChoiceScreen(),
          );
          case RoutesName.getStarted:
        return MaterialPageRoute(
          builder:(context)=> GetStartedScreen(),
          );
          case RoutesName.account:
        return MaterialPageRoute(
          builder:(context)=> Account(),
          );
          case RoutesName.admin:
        return MaterialPageRoute(
          builder:(context)=> PatientManagementPage(),
          );
          case RoutesName.dashboard:
        return MaterialPageRoute(
          builder:(context)=> Dashboard(),
          );
          case RoutesName.medicalRecord:
        return MaterialPageRoute(
          builder:(context)=> MedicalRecord(),
          );
        

          
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('No routes defined')),
          ),
        );
    }
  }
}
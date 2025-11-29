import 'package:flutter/material.dart';
import 'package:health_care_app/account.dart';
import 'package:health_care_app/config/routes/routes_name.dart';


class RoutesHandler {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {    
        case RoutesName.accountScreen:
        return MaterialPageRoute(
          builder: (context) => Account(),
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

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'getstarted_screen.dart';



//
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen(
//       duration: 3500,
//       splashIconSize: 1000,
//       backgroundColor: Colors.white,
//
//       splash: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//
//           Lottie.asset('assets/animation/Doctor.json', height: 300),
//
//           const SizedBox(height: 20),
//
//
//           Text(
//             "Halooooooooooooooz",
//             style: TextStyle(
//               color: Colors.black87,
//               fontSize: 29,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//
//           const SizedBox(height: 10),
//
//           Text(
//             "Welcome to your healthcare app",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 17,
//             ),
//           ),
//         ],
//       ),
//
//       nextScreen: GetStartedScreen(),
//     );
//   }
// }

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        duration: 1800,
        splashIconSize: 600,
        backgroundColor: Colors.white,

        splash: Center(child: Lottie.asset('assets/animation/Doctor.json')), nextScreen: GetStartedScreen());
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_care_app/presentation/screens/getstarted_screen.dart';
import 'package:health_care_app/presentation/screens/login_screen.dart';
import 'package:health_care_app/presentation/screens/patient_management_page.dart';
import 'package:health_care_app/presentation/screens/record_detail_page.dart%20.dart';
import 'package:health_care_app/presentation/screens/signup_screen.dart';

void main() {
  group('Component Tests', () {
    testWidgets('SignUpPage renders all input fields and button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpPage()));

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'National ID'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('LoginPage renders email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      expect(find.text('Login'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('GetStartedScreen renders welcome text and button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GetStartedScreen()));

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(
          find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);
    });

    testWidgets('RecordDetailPage renders data correctly',
        (WidgetTester tester) async {
      final mockData = {
        'title': 'Blood Test',
        'type': 'Lab Result',
        'date': '2025-01-01',
        'doctor': 'Dr. House',
        'description': 'Routine checkup',
        'raw': {'value': 'Normal', 'status': 'Final'}
      };

      await tester
          .pumpWidget(MaterialApp(home: RecordDetailPage(data: mockData)));

      expect(find.text('Blood Test'), findsOneWidget);
      expect(find.text('Lab Result'), findsOneWidget);
      expect(find.byIcon(Icons.science), findsOneWidget);
    });

    testWidgets('PatientManagementPage renders dashboard title and button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PatientManagementPage()));
      expect(find.text('Patient Management'), findsOneWidget);
      expect(
          find.widgetWithText(ElevatedButton, 'Add Patient'), findsOneWidget);
    });

    testWidgets('PatientManagementPage renders table headers',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PatientManagementPage()));
      expect(find.text('National ID'), findsOneWidget);
      expect(find.text('Patient Name'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
    });

    testWidgets('Admin Login Scenario: Inputs sam@gmail.com correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'sam@gmail.com');
      await tester.enterText(passwordField, '123456');
      await tester.pump();

      expect(find.text('sam@gmail.com'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });
  });
}

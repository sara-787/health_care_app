import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unit Tests', () {
    test('Email Validation returns error if no @ symbol', () {
      String? validateEmail(String? v) {
        if (v == null || !v.contains('@')) return 'Enter valid email';
        return null;
      }

      expect(validateEmail('invalid-email'), 'Enter valid email');
      expect(validateEmail('test@example.com'), null);
    });

    test('Password Validation returns error if less than 6 characters', () {
      String? validatePassword(String? v) {
        if (v == null || v.length < 6) return 'Minimum 6 characters';
        return null;
      }

      expect(validatePassword('12345'), 'Minimum 6 characters');
      expect(validatePassword('123456'), null);
    });

    test('National ID Validation returns error if not exactly 14 digits', () {
      String? validateNationalId(String? v) {
        if (v == null || v.isEmpty) return 'Enter National ID';
        if (v.length != 14) return 'National ID must be 14 digits';
        return null;
      }

      expect(validateNationalId('123'), 'National ID must be 14 digits');
      expect(validateNationalId('12345678901234'), null);
      expect(validateNationalId(''), 'Enter National ID');
    });

    test('Name Validation returns error if empty', () {
      String? validateName(String? v) {
        if (v == null || v.isEmpty) return 'Enter your name';
        return null;
      }

      expect(validateName(''), 'Enter your name');
      expect(validateName('John Doe'), null);
    });
  });
}


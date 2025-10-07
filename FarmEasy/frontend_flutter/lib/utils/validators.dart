import 'constants.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final RegExp emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? soilValue(String? value, String nutrient) {
    if (value == null || value.isEmpty) {
      return '$nutrient value is required';
    }

    final double? numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid number';
    }

    if (numValue < 0 || numValue > 100) {
      return '$nutrient value should be between 0-100';
    }

    return null;
  }

  static String? phValue(String? value) {
    if (value == null || value.isEmpty) {
      return 'pH value is required';
    }

    final double? numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid number';
    }

    if (numValue < 0 || numValue > 14) {
      return 'pH value should be between 0-14';
    }

    return null;
  }
}

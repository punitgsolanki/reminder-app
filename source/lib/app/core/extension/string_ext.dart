import '../values/app_values.dart';

extension StringExt on String? {
  bool isValidMobileNumber() {
    if(this == null) {
      return false;
    }
    // Define the desired length for a valid mobile number
    // const int desiredLength = 10;

    // Remove any non-digit characters
    String digitsOnly = this!.replaceAll(RegExp(r'\D'), '');

    // Check if the length is correct and contains only digits
    return (digitsOnly.length > 5 && digitsOnly.length <= 15) && digitsOnly.contains(RegExp(r'^[0-9]+$'));
  }

  bool isEmptyOrNull() {
    return this == null || this!.trim().isEmpty;
  }

  bool isNotEmptyAndNotNull() {
    return this != null && this!.trim().isNotEmpty;
  }

  String trimString() {
    if(this == null) {
      return "";
    }
    if(this!.toLowerCase() == "null") {
      return "";
    }
    return this!.trim();
  }

  String trimStringAndToLowerCase() {
    if(this == null) {
      return "";
    }
    return this!.trim().toLowerCase();
  }

  String trimStringToPrice() {
    if(this == null) {
      return "${AppValues.inr}0.00";
    }
    return "\$${this!.trim()}";
  }

  bool isValidEmail() {
    if(this == null) {
      return false;
    }
    // Regular expression for email validation
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this!);
  }

  String capitalize() {
    if(this == null) {
      return "";
    }
    return "${this?[0].toUpperCase()}${this?.substring(1).toLowerCase()}";
  }

  String toTitleCase() {
    if(this == null) {
      return "";
    }
    return this!.split(' ').map((word) =>
    word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
    ).join(' ');
  }

  /*String toTitleCase() {
    return trim()
        .split(RegExp(r'\s+')) // Split by any whitespace (handles multiple spaces)
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '') // Capitalize first letter, lowercase rest
        .join(' '); // Join words with a single space
  }*/
}
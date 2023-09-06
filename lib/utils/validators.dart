class Validators {
  // Method to validate an email address.
  static String? emailValidator(String? value) {

    Pattern pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';

    RegExp regex = RegExp(pattern as String);

    // Check if the provided value matches the email pattern.
    if (!regex.hasMatch(value!)) {
      return 'Enter a valid email';
    } else {
      return null;
    }
  }
}

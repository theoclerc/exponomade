class Validators {
  static String? emailValidator(String? value) {
    Pattern pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern as String);
    if (!regex.hasMatch(value!)) {
      return 'Entrez un e-mail valide';
    } else {
      return null;
    }
  }
}
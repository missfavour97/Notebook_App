class FormValidators {
  static final RegExp _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  static bool isValidEmail(String value) {
    return _emailPattern.hasMatch(value.trim());
  }

  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredText(value, 'Email');

    if (requiredError != null) return requiredError;

    if (!isValidEmail(value ?? '')) {
      return 'Enter a real email address, like name@example.com';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredText(value, 'Password');

    if (requiredError != null) return requiredError;

    final password = value ?? '';

    if (password.length < 6) {
      return 'Use at least 6 characters';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = requiredText(value, 'Confirm password');

    if (requiredError != null) return requiredError;

    if ((value ?? '') != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}

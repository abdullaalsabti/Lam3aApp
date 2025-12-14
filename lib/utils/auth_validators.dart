/// Validators for authentication forms
class AuthValidators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    
    final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegEx.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    
    final trimmedPassword = value.trim();
    
    if (trimmedPassword.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (trimmedPassword.length > 30) {
      return 'Password can\'t be longer than 30 characters';
    }
    
    return null;
  }
}


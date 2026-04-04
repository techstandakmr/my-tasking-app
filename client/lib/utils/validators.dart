class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$');

    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Minimum 8 characters required";
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Must contain uppercase letter";
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Must contain lowercase letter";
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Must contain a number";
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Must contain special character";
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    if (value.trim().length < 2) {
      return "Name must be at least 2 characters";
    }

    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "Only letters allowed";
    }

    return null;
  }

  // Title validation
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Title is required";
    }

    if (value.trim().length < 3) {
      return "Title must be at least 3 characters";
    }

    if (value.length > 100) {
      return "Title too long";
    }

    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Description is required";
    }

    if (value.trim().length < 10) {
      return "Description must be at least 10 characters";
    }

    if (value.length > 500) {
      return "Description too long";
    }

    return null;
  }
}

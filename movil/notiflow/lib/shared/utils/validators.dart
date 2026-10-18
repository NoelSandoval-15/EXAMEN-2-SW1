class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }
}

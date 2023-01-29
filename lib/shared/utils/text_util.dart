extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}

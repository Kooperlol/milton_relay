import 'package:flutter/material.dart';

/// Capitalizes the first letter of a word.
///
/// 'apple' becomes 'Apple'
extension StringExtension on String {
  String capitalize() => length > 0
      ? "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}"
      : "";
}

/// Formats [time] to hour:minute AM/PM.
String timeOfDayToString(TimeOfDay time) =>
    '${time.hourOfPeriod}:${time.minute < 10 ? '0${time.minute}' : time.minute} ${time.period.name.toUpperCase()}';

/// Whether a string is a number or not.
bool isNumeric(String s) => double.tryParse(s) != null;

import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

String timeOfDayToString(TimeOfDay time) =>
    '${time.hourOfPeriod}:${time.minute < 10 ? '0${time.minute}' : time.minute} ${time.period.name.toUpperCase()}';

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}

import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() => length > 0
      ? "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}"
      : "";
}

String timeOfDayToString(TimeOfDay time) =>
    '${time.hourOfPeriod}:${time.minute < 10 ? '0${time.minute}' : time.minute} ${time.period.name.toUpperCase()}';

bool isNumeric(String s) => double.tryParse(s) != null;

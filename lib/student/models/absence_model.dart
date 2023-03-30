import 'package:flutter/material.dart';

class AbsenceModel {
  final String student, id;
  final DateTime date;
  final TimeOfDay startTime, endTime;
  final AbsenceReasons reason;

  AbsenceModel(this.id, this.student, this.date, this.startTime, this.endTime,
      this.reason);
}

enum AbsenceReasons { sick, appointment, vacation, funeral, religion, other }

extension AbsenceExstention on AbsenceReasons {
  String get toName {
    switch (this) {
      case AbsenceReasons.sick:
        return "sick";
      case AbsenceReasons.appointment:
        return "appointment";
      case AbsenceReasons.vacation:
        return "vacation";
      case AbsenceReasons.funeral:
        return "funeral";
      case AbsenceReasons.religion:
        return "religion";
      case AbsenceReasons.other:
        return "other";
    }
  }
}

AbsenceReasons absenceReasonFromString(String string) =>
    AbsenceReasons.values.where((element) => element.toName == string).first;

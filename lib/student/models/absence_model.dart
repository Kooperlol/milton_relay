import 'package:flutter/material.dart';

class AbsenceModel {
  final DateTime date, posted;
  final TimeOfDay startTime, endTime;
  final AbsenceReasons reason;
  bool isExcused, isViewed;

  AbsenceModel(this.posted, this.date, this.startTime, this.endTime,
      this.reason, this.isExcused, this.isViewed);
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

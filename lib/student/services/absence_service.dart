import 'package:flutter/material.dart';
import 'package:milton_relay/student/models/absence_model.dart';

class AbsenceService {
  AbsenceModel getAbsenceFromJson(Map<String, dynamic> json) => AbsenceModel(
      DateTime.fromMicrosecondsSinceEpoch(json['posted'] as int),
      DateTime.fromMicrosecondsSinceEpoch(json['date'] as int),
      TimeOfDay(
          hour: json['start-time-hour'] as int,
          minute: json['start-time-minute'] as int),
      TimeOfDay(
          hour: json['end-time-hour'] as int,
          minute: json['end-time-minute'] as int),
      absenceReasonFromString(json['reason']),
      json['excused'] as bool,
      json['viewed'] as bool);

  Map<String, dynamic> absenceToJson(AbsenceModel absence) => <String, dynamic>{
        'posted': absence.posted.microsecondsSinceEpoch,
        'date': absence.date.microsecondsSinceEpoch,
        'excused': absence.isExcused,
        'start-time-hour': absence.startTime.hour,
        'start-time-minute': absence.startTime.minute,
        'end-time-hour': absence.endTime.hour,
        'end-time-minute': absence.endTime.minute,
        'reason': absence.reason.toName,
        'viewed': absence.isViewed
      };
}

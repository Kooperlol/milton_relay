import 'package:milton_relay/student/services/absence_service.dart';

import '../../shared/models/roles.dart';
import '../models/student_model.dart';

class StudentService {
  StudentModel getStudentFromJson(Map<String, dynamic> json) => StudentModel(
      json['id'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      json['avatarURL'] as String,
      (json['absences'] as List<dynamic>)
          .map((e) => AbsenceService().getAbsenceFromJson(e))
          .toList(),
      double.parse(json['laudePoints'].toString()));

  Map<String, dynamic> studentToJson(StudentModel student) => <String, dynamic>{
        'id': student.id,
        'firstName': student.firstName,
        'lastName': student.lastName,
        'avatarURL': student.avatarURL,
        'absences':
            student.absences.map((e) => AbsenceService().absenceToJson(e)),
        'role': Roles.student.toName,
        'laudePoints': student.laudePoints
      };
}

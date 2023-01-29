import '../../shared/models/roles.dart';
import '../models/student.dart';

class StudentService {
  StudentModel getStudentFromJson(Map<String, dynamic> json) => StudentModel(
      json['id'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      json['avatarURL'] as String,
      int.parse(json['absences'].toString()),
      double.parse(json['laudePoints'].toString()));

  Map<String, dynamic> studentToJson(StudentModel student) => <String, dynamic>{
        'id': student.id,
        'firstName': student.firstName,
        'lastName': student.lastName,
        'avatarURL': student.avatarURL,
        'absences': student.absences,
        'role': Roles.student.toName,
        'laudePoints': student.laudePoints
      };
}

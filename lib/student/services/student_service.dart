import '../../shared/models/roles.dart';
import '../models/student_model.dart';

class StudentService {
  StudentModel getStudentFromJson(Map<String, dynamic> json) => StudentModel(
      json['id'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      json['avatarURL'] as String,
      (json['absences'] as List<dynamic>).map((e) => e.toString()).toList(),
      double.parse(json['laudePoints'].toString()));

  Map<String, dynamic> studentToJson(StudentModel student) => <String, dynamic>{
        'id': student.id,
        'firstName': student.firstName,
        'lastName': student.lastName,
        'avatarURL': student.avatarURL,
        'role': Roles.student.toName,
        'absences': student.absences,
        'laudePoints': student.laudePoints
      };
}

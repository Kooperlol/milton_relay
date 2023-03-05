import 'package:json_annotation/json_annotation.dart';
import 'package:milton_relay/shared/models/user_model.dart';
import 'package:milton_relay/student/services/student_service.dart';

import '../../shared/models/roles.dart';

@JsonSerializable(explicitToJson: true)
class StudentModel extends UserModel {
  int absences;
  double laudePoints;

  StudentModel(String id, String firstName, String lastName, String avatarURL,
      this.absences, this.laudePoints)
      : super(id, firstName, lastName, avatarURL, Roles.student);

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      StudentService().getStudentFromJson(json);
  Map<String, Object?> toJson() => StudentService().studentToJson(this);
}

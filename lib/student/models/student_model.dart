import 'package:milton_relay/shared/models/user_model.dart';

import '../../shared/models/roles.dart';

class StudentModel extends UserModel {
  final List<String> absences;
  double laudePoints;

  StudentModel(String id, String firstName, String lastName, String avatarURL,
      this.absences, this.laudePoints)
      : super(id, firstName, lastName, avatarURL, Roles.student);
}

import 'package:milton_relay/student/models/student_model.dart';

enum LaudeRoles { summaCumLaude, magnaCumLaude, cumLaude, normal }

extension LaudeRoleExtension on LaudeRoles {
  String get toName {
    switch (this) {
      case LaudeRoles.summaCumLaude:
        return 'Summa Cum Laude';
      case LaudeRoles.magnaCumLaude:
        return 'Magna Cum Laude';
      case LaudeRoles.cumLaude:
        return 'Cum Laude';
      case LaudeRoles.normal:
        return 'No Laude Recognition';
    }
  }
}

/// Returns the laude role of the student based on their laude points.
LaudeRoles? getLaudeRole(StudentModel student) {
  if (student == null) return null;
  if (student.laudePoints >= 60) return LaudeRoles.summaCumLaude;
  if (student.laudePoints >= 40) return LaudeRoles.magnaCumLaude;
  if (student.laudePoints >= 20) return LaudeRoles.cumLaude;
  return LaudeRoles.normal;
}

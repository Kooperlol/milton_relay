enum Roles { admin, instructor, parent, student }

extension RolesExstention on Roles {
  String get toName {
    switch (this) {
      case Roles.admin:
        return "admin";
      case Roles.instructor:
        return "instructor";
      case Roles.parent:
        return "parent";
      case Roles.student:
        return "student";
    }
  }
}

Roles roleFromString(String string) =>
    Roles.values.where((element) => element.toName == string).first;

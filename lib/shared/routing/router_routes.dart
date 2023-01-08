enum Routes { login, studentDashboard }

extension RoutesExtension on Routes {
  String get toName {
    switch (this) {
      case Routes.login:
        return "login";
      case Routes.studentDashboard:
        return "studentDashboard";
      default:
        return "loading";
    }
  }

  String get toPath {
    switch (this) {
      case Routes.login:
        return "/login";
      case Routes.studentDashboard:
        return "/student/dashboard";
      default:
        return "/";
    }
  }
}

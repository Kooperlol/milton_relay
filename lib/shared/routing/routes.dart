enum Routes { login, news, userManagerScreen, addUserScreen, viewChildren }

extension RoutesExtension on Routes {
  String get toName {
    switch (this) {
      case Routes.login:
        return "login";
      case Routes.news:
        return "news";
      case Routes.userManagerScreen:
        return "userManagerScreen";
      case Routes.viewChildren:
        return "viewChildren";
      default:
        return "loading";
    }
  }

  String get toPath {
    switch (this) {
      case Routes.login:
        return "/login";
      case Routes.news:
        return "/news";
      case Routes.userManagerScreen:
        return "/admin/userManagerScreen";
      case Routes.addUserScreen:
        return "/admin/addUserScreen";
      case Routes.viewChildren:
        return "/admin/viewChildren";
      default:
        return "/";
    }
  }
}

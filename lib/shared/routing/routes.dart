enum Routes {
  login,
  adminCalendar,
  adminNews,
  userManagerScreen,
  addUserScreen,
  addEventScreen,
  viewChildren
}

extension RoutesExtension on Routes {
  String get toName {
    switch (this) {
      case Routes.login:
        return "login";
      case Routes.adminCalendar:
        return "adminCalendar";
      case Routes.adminNews:
        return "adminNews";
      case Routes.userManagerScreen:
        return "userManagerScreen";
      case Routes.viewChildren:
        return "viewChildren";
      case Routes.addEventScreen:
        return "addEventScreen";
      default:
        return "loading";
    }
  }

  String get toPath {
    switch (this) {
      case Routes.login:
        return "/login";
      case Routes.adminNews:
        return "/admin/news";
      case Routes.adminCalendar:
        return "/admin/calendar";
      case Routes.userManagerScreen:
        return "/userManagerScreen";
      case Routes.addUserScreen:
        return "/addUserScreen";
      case Routes.viewChildren:
        return "/viewChildren";
      case Routes.addEventScreen:
        return "/admin/addEventScreen";
      default:
        return "/";
    }
  }
}

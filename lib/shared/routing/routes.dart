enum Routes {
  login,
  adminNews,
  studentNews,
  instructorNews,
  parentNews,
  adminCalendar,
  studentCalendar,
  instructorCalendar,
  parentCalendar,
  adminUserManager,
  instructorUserList,
  addUser,
  addEvent,
  viewEvent,
  viewUpcomingEvents,
  viewChildren,
  studentReportIssue,
  instructorReportIssue,
  parentReportIssue,
  viewImageScreen,
  issueManagerScreen
}

extension RoutesExtension on Routes {
  String get toName {
    switch (this) {
      case Routes.login:
        return "login";
      case Routes.adminCalendar:
        return "adminCalendar";
      case Routes.instructorCalendar:
        return "instructorCalendar";
      case Routes.parentCalendar:
        return "parentCalendar";
      case Routes.studentCalendar:
        return "studentCalendar";
      case Routes.adminNews:
        return "adminNews";
      case Routes.studentNews:
        return "studentNews";
      case Routes.parentNews:
        return "parentNews";
      case Routes.instructorNews:
        return "instructorNews";
      case Routes.adminUserManager:
        return "adminUserManager";
      case Routes.instructorUserList:
        return "instructorUserList";
      case Routes.viewChildren:
        return "viewChildren";
      case Routes.addEvent:
        return "addEvent";
      case Routes.viewEvent:
        return "viewEvent";
      case Routes.viewUpcomingEvents:
        return "viewUpcomingEvents";
      case Routes.studentReportIssue:
        return "studentReportIssue";
      case Routes.parentReportIssue:
        return "parentReportIssue";
      case Routes.instructorReportIssue:
        return "instructorReportIssue";
      case Routes.viewImageScreen:
        return "viewImageScreen";
      case Routes.issueManagerScreen:
        return "issueManagerScreen";
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
      case Routes.parentNews:
        return "/parent/news";
      case Routes.studentNews:
        return "/student/news";
      case Routes.instructorNews:
        return "/instructor/news";
      case Routes.adminCalendar:
        return "/admin/calendar";
      case Routes.parentCalendar:
        return "/parent/calendar";
      case Routes.instructorCalendar:
        return "/instructor/calendar";
      case Routes.studentCalendar:
        return "/student/calendar";
      case Routes.adminUserManager:
        return "/admin/userManager";
      case Routes.instructorUserList:
        return "/instructor/userList";
      case Routes.addUser:
        return "/addUser";
      case Routes.viewChildren:
        return "/viewChildren";
      case Routes.addEvent:
        return "/admin/addEvent";
      case Routes.viewEvent:
        return "/viewEvent";
      case Routes.viewUpcomingEvents:
        return "/viewUpcomingEvents";
      case Routes.parentReportIssue:
        return "/parent/reportIssue";
      case Routes.instructorReportIssue:
        return "/instructor/reportIssue";
      case Routes.studentReportIssue:
        return "/student/reportIssue";
      case Routes.viewImageScreen:
        return "/viewImageScreen";
      case Routes.issueManagerScreen:
        return "/admin/issueManagerScreen";
      default:
        return "/";
    }
  }
}

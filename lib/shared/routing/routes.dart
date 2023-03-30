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
  editEvent,
  addEvent,
  viewEvent,
  viewUpcomingEvents,
  viewChildren,
  studentSettings,
  instructorSettings,
  parentSettings,
  studentLaudePointCalculator,
  familyManager,
  studentProfile,
  viewImage,
  viewIssue,
  viewAbsences,
  issueManager,
  studentPosts,
  reportIssue,
  instructorPosts,
  reportAbsence,
  adminPosts,
  createPost,
  absenceManager
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
      case Routes.editEvent:
        return "editEvent";
      case Routes.addEvent:
        return "addEvent";
      case Routes.viewEvent:
        return "viewEvent";
      case Routes.viewUpcomingEvents:
        return "viewUpcomingEvents";
      case Routes.studentSettings:
        return "studentSettings";
      case Routes.parentSettings:
        return "parentSettings";
      case Routes.instructorSettings:
        return "instructorSettings";
      case Routes.viewImage:
        return "viewImage";
      case Routes.issueManager:
        return "issueManager";
      case Routes.studentProfile:
        return "studentProfile";
      case Routes.studentLaudePointCalculator:
        return "studentLaudePointCalculator";
      case Routes.viewIssue:
        return "viewIssue";
      case Routes.familyManager:
        return "familyManager";
      case Routes.viewAbsences:
        return "viewAbsences";
      case Routes.instructorPosts:
        return "instructorPosts";
      case Routes.studentPosts:
        return "studentPosts";
      case Routes.adminPosts:
        return "adminPosts";
      case Routes.createPost:
        return "createPost";
      case Routes.reportAbsence:
        return "reportAbsence";
      case Routes.absenceManager:
        return "absenceManager";
      case Routes.reportIssue:
        return "reportIssue";
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
      case Routes.editEvent:
        return "/admin/editEvent";
      case Routes.addEvent:
        return "/admin/addEvent";
      case Routes.viewEvent:
        return "/viewEvent";
      case Routes.viewUpcomingEvents:
        return "/viewUpcomingEvents";
      case Routes.parentSettings:
        return "/parent/settings";
      case Routes.instructorSettings:
        return "/instructor/settings";
      case Routes.studentSettings:
        return "/student/settings";
      case Routes.viewImage:
        return "/viewImage";
      case Routes.issueManager:
        return "/admin/issueManager";
      case Routes.viewIssue:
        return "/admin/viewIssue";
      case Routes.studentProfile:
        return "/student/profile";
      case Routes.studentLaudePointCalculator:
        return "/student/laudePointCalculator";
      case Routes.familyManager:
        return "/parent/familyManager";
      case Routes.viewAbsences:
        return "/student/viewAbsences";
      case Routes.studentPosts:
        return "/student/posts";
      case Routes.instructorPosts:
        return "/instructor/posts";
      case Routes.adminPosts:
        return "/admin/posts";
      case Routes.createPost:
        return "/createPost";
      case Routes.reportAbsence:
        return "/reportAbsence";
      case Routes.absenceManager:
        return "/admin/absenceManager";
      case Routes.reportIssue:
        return "/reportIssue";
      default:
        return "/";
    }
  }
}

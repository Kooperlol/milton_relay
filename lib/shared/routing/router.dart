import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/admin/screens/absence_manager_screen.dart';
import 'package:milton_relay/admin/screens/event_manager_screen.dart';
import 'package:milton_relay/admin/screens/add_user_screen.dart';
import 'package:milton_relay/admin/screens/issue_manager_screen.dart';
import 'package:milton_relay/admin/screens/view_issue_screen.dart';
import 'package:milton_relay/parent/screens/family_manager_screen.dart';
import 'package:milton_relay/parent/screens/report_absence_screen.dart';
import 'package:milton_relay/parent/screens/view_absences_screen.dart';
import 'package:milton_relay/shared/models/issue_model.dart';
import 'package:milton_relay/shared/screens/create_post_screen.dart';
import 'package:milton_relay/shared/screens/posts_screen.dart';
import 'package:milton_relay/shared/screens/report_issue_screen.dart';
import 'package:milton_relay/shared/screens/settings_screen.dart';
import 'package:milton_relay/shared/screens/user_list_screen.dart';
import 'package:milton_relay/shared/screens/view_children_screen.dart';
import 'package:milton_relay/shared/screens/view_image_screen.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/parent/models/parent_model.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/screens/calendar_screen.dart';
import 'package:milton_relay/shared/screens/error_screen.dart';
import 'package:milton_relay/shared/screens/splash_screen.dart';
import 'package:milton_relay/shared/screens/login_screen.dart';
import 'package:milton_relay/shared/screens/news_screen.dart';
import 'package:milton_relay/shared/screens/view_event_screen.dart';
import 'package:milton_relay/shared/screens/view_upcoming_events_screen.dart';
import 'package:milton_relay/shared/widgets/navigation_bar_widget.dart';
import 'package:milton_relay/student/models/student_model.dart';
import 'package:milton_relay/student/screens/laude_point_calculator_screen.dart';
import 'package:milton_relay/student/screens/student_profile_screen.dart';

import '../models/event_model.dart';
import '../utils/display_util.dart';

// Keys to store the navigation for each group
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminNavigatorKey = GlobalKey<NavigatorState>();
final _instructorNavigatorKey = GlobalKey<NavigatorState>();
final _studentNavigatorKey = GlobalKey<NavigatorState>();
final _parentNavigatorKey = GlobalKey<NavigatorState>();

/// Routes all locations of the application.
final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SplashScreen())),
      // Login Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.login.toName,
          path: Routes.login.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LoginScreen())),
      // Add User Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.addUser.toName,
          path: Routes.addUser.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AddUserScreen())),
      // Edit Event Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.editEvent.toName,
          path: Routes.editEvent.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: EventManagerScreen(event: state.extra as EventModel))),
      // Add Event Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.addEvent.toName,
          path: Routes.addEvent.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: EventManagerScreen())),
      // View Upcoming Events Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewUpcomingEvents.toName,
          path: Routes.viewUpcomingEvents.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ViewUpcomingEventsScreen())),
      // Laude Point Calculator
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.studentLaudePointCalculator.toName,
          path: Routes.studentLaudePointCalculator.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LaudePointCalculatorScreen())),
      // Create Post Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.createPost.toName,
          path: Routes.createPost.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CreatePostScreen())),
      // Absence Manager Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.absenceManager.toName,
          path: Routes.absenceManager.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AbsenceManagerScreen())),
      // Report Issue Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.reportIssue.toName,
          path: Routes.reportIssue.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ReportIssueScreen())),
      // View Event Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewEvent.toName,
          path: Routes.viewEvent.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewEventScreen(event: state.extra as EventModel))),
      // View Issue Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewIssue.toName,
          path: Routes.viewIssue.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewIssueScreen(issue: state.extra as IssueModel))),
      // View Children Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewChildren.toName,
          path: Routes.viewChildren.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewChildrenScreen(parent: state.extra as ParentModel))),
      // View Absences Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewAbsences.toName,
          path: Routes.viewAbsences.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewAbsencesScreen(student: state.extra as StudentModel))),
      // Report Absences Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.reportAbsence.toName,
          path: Routes.reportAbsence.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child:
                  ReportAbsenceScreen(student: state.extra as StudentModel))),
      // View Image Screen
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewImage.toName,
          path: Routes.viewImage.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewImageScreen(image: state.extra as File))),
      // Admin Navigation Bar & Screens
      ShellRoute(
          navigatorKey: _adminNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: RelayNavigationBar(
                  location: state.location,
                  nav: [
                    NavBarItem(
                        icon: const Icon(Icons.newspaper),
                        location: Routes.adminNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.image),
                        location: Routes.adminPosts.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.calendar_month),
                        location: Routes.adminCalendar.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.group),
                        location: Routes.adminUserManager.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.warning),
                        location: Routes.issueManager.toPath)
                  ],
                  child: child)),
          routes: [
            // Admin News Screen
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminNews.toName,
                path: Routes.adminNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NewsScreen())),
            // Admin Posts Screen
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminPosts.toName,
                path: Routes.adminPosts.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PostsScreen())),
            // Admin User Manager Screen
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminUserManager.toName,
                path: Routes.adminUserManager.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: UserListScreen())),
            // Admin Calendar Screen
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminCalendar.toName,
                path: Routes.adminCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
            // Issue Manager Screen
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.issueManager.toName,
                path: Routes.issueManager.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: IssueManagerScreen()))
          ]),
      // Parent Navigation Bar & Screens
      ShellRoute(
          navigatorKey: _parentNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: RelayNavigationBar(
                  location: state.location,
                  nav: [
                    NavBarItem(
                        icon: const Icon(Icons.newspaper),
                        location: Routes.parentNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.calendar_month),
                        location: Routes.parentCalendar.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.group),
                        location: Routes.familyManager.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.settings),
                        location: Routes.parentSettings.toPath)
                  ],
                  child: child)),
          routes: [
            // Parent News Screen
            GoRoute(
                parentNavigatorKey: _parentNavigatorKey,
                name: Routes.parentNews.toName,
                path: Routes.parentNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NewsScreen())),
            // Parent Calendar Screen
            GoRoute(
                parentNavigatorKey: _parentNavigatorKey,
                name: Routes.parentCalendar.toName,
                path: Routes.parentCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
            // Parent Family Manager Screen
            GoRoute(
                parentNavigatorKey: _parentNavigatorKey,
                name: Routes.familyManager.toName,
                path: Routes.familyManager.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FamilyManagerScreen())),
            // Parent Settings Screen
            GoRoute(
                parentNavigatorKey: _parentNavigatorKey,
                name: Routes.parentSettings.toName,
                path: Routes.parentSettings.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen())),
          ]),
      // Instructor Navigation Bar & Screens
      ShellRoute(
          navigatorKey: _instructorNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: RelayNavigationBar(
                  location: state.location,
                  nav: [
                    NavBarItem(
                        icon: const Icon(Icons.newspaper),
                        location: Routes.instructorNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.image),
                        location: Routes.instructorPosts.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.calendar_month),
                        location: Routes.instructorCalendar.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.group),
                        location: Routes.instructorUserList.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.settings),
                        location: Routes.instructorSettings.toPath)
                  ],
                  child: child)),
          routes: [
            // Instructor News Screen
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorNews.toName,
                path: Routes.instructorNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NewsScreen())),
            // Instructor Posts Screen
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorPosts.toName,
                path: Routes.instructorPosts.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PostsScreen())),
            // Instructor Calendar Screen
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorCalendar.toName,
                path: Routes.instructorCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
            // Instructor User List Screen
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorUserList.toName,
                path: Routes.instructorUserList.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: UserListScreen())),
            // Instructor Settings Screen
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorSettings.toName,
                path: Routes.instructorSettings.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen())),
          ]),
      // Student Navigation Bar & Screens
      ShellRoute(
          navigatorKey: _studentNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: RelayNavigationBar(
                  location: state.location,
                  nav: [
                    NavBarItem(
                        icon: const Icon(Icons.newspaper),
                        location: Routes.studentNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.image),
                        location: Routes.studentPosts.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.calendar_month),
                        location: Routes.studentCalendar.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.person),
                        location: Routes.studentProfile.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.settings),
                        location: Routes.studentSettings.toPath)
                  ],
                  child: child)),
          routes: [
            // Student News Screen
            GoRoute(
                parentNavigatorKey: _studentNavigatorKey,
                name: Routes.studentNews.toName,
                path: Routes.studentNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NewsScreen())),
            // Student Posts Screen
            GoRoute(
                parentNavigatorKey: _studentNavigatorKey,
                name: Routes.studentPosts.toName,
                path: Routes.studentPosts.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PostsScreen())),
            // Student Calendar Screen
            GoRoute(
                parentNavigatorKey: _studentNavigatorKey,
                name: Routes.studentCalendar.toName,
                path: Routes.studentCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
            // Student Profile Screen
            GoRoute(
                parentNavigatorKey: _studentNavigatorKey,
                name: Routes.studentProfile.toName,
                path: Routes.studentProfile.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: StudentProfileScreen())),
            // Student Settings Screen
            GoRoute(
                parentNavigatorKey: _studentNavigatorKey,
                name: Routes.studentSettings.toName,
                path: Routes.studentSettings.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen())),
          ])
    ],
    // Error Screen
    errorBuilder: (context, state) =>
        ErrorScreen(key: state.pageKey, error: state.error.toString()),
    // Checks to make sure that the user is logged in. Otherwise, the user is redirected to the login screen.
    redirect: (context, state) {
      if (state.subloc == Routes.login.toPath || state.subloc == '/') {
        return null;
      }
      if (AuthService().firebaseUser == null) return Routes.login.toPath;
      return null;
    });

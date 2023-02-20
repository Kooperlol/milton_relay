import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/admin/screens/add_event_screen.dart';
import 'package:milton_relay/admin/screens/add_user_screen.dart';
import 'package:milton_relay/admin/screens/issue_manager.dart';
import 'package:milton_relay/shared/screens/report_issue_screen.dart';
import 'package:milton_relay/shared/screens/user_list_screen.dart';
import 'package:milton_relay/shared/screens/view_children_screen.dart';
import 'package:milton_relay/shared/screens/view_image_screen.dart';
import 'package:milton_relay/shared/widgets/footer_widget.dart';
import 'package:milton_relay/parent/models/parent.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/screens/calendar_screen.dart';
import 'package:milton_relay/shared/screens/error_screen.dart';
import 'package:milton_relay/shared/screens/splash_screen.dart';
import 'package:milton_relay/shared/screens/login_screen.dart';
import 'package:milton_relay/shared/screens/news_screen.dart';
import 'package:milton_relay/shared/screens/view_event_screen.dart';
import 'package:milton_relay/shared/screens/view_upcoming_events_screen.dart';

import '../models/event_model.dart';
import '../utils/display_util.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminNavigatorKey = GlobalKey<NavigatorState>();
final _instructorNavigatorKey = GlobalKey<NavigatorState>();
final _studentNavigatorKey = GlobalKey<NavigatorState>();
final _parentNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: "/",
    routes: [
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SplashScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.login.toName,
          path: Routes.login.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LoginScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.addUser.toName,
          path: Routes.addUser.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AddUserScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.addEvent.toName,
          path: Routes.addEvent.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AddEventScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewUpcomingEvents.toName,
          path: Routes.viewUpcomingEvents.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ViewUpcomingEventsScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewEvent.toName,
          path: Routes.viewEvent.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewEventScreen(event: state.extra as EventModel))),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewChildren.toName,
          path: Routes.viewChildren.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewChildrenScreen(parent: state.extra as ParentModel))),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewImageScreen.toName,
          path: Routes.viewImageScreen.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewImageScreen(image: state.extra as File))),
      ShellRoute(
          navigatorKey: _adminNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: Footer(
                  location: state.location,
                  nav: [
                    NavBarItem(
                        icon: const Icon(Icons.newspaper),
                        location: Routes.adminNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.calendar_month),
                        location: Routes.adminCalendar.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.group),
                        location: Routes.adminUserManager.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.warning),
                        location: Routes.issueManagerScreen.toPath)
                  ],
                  child: child)),
          routes: [
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminNews.toName,
                path: Routes.adminNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NewsScreen())),
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminUserManager.toName,
                path: Routes.adminUserManager.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: UserManagerScreen())),
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminCalendar.toName,
                path: Routes.adminCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.issueManagerScreen.toName,
                path: Routes.issueManagerScreen.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: IssueManagerScreen()))
          ]),
      ShellRoute(
          navigatorKey: _parentNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: Footer(
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
                        location: Routes.parentNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.warning),
                        location: Routes.parentReportIssue.toPath)
                  ],
                  child: child)),
          routes: [
            GoRoute(
                parentNavigatorKey: _parentNavigatorKey,
                name: Routes.parentNews.toName,
                path: Routes.parentNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NewsScreen())),
            GoRoute(
                parentNavigatorKey: _parentNavigatorKey,
                name: Routes.parentCalendar.toName,
                path: Routes.parentCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
            GoRoute(
                parentNavigatorKey: _parentNavigatorKey,
                name: Routes.parentReportIssue.toName,
                path: Routes.parentReportIssue.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ReportIssueScreen())),
          ]),
      ShellRoute(
          navigatorKey: _instructorNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: Footer(
                  location: state.location,
                  nav: [
                    NavBarItem(
                        icon: const Icon(Icons.newspaper),
                        location: Routes.instructorNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.image),
                        location: Routes.instructorNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.calendar_month),
                        location: Routes.instructorCalendar.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.group),
                        location: Routes.instructorUserList.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.warning),
                        location: Routes.instructorReportIssue.toPath)
                  ],
                  child: child)),
          routes: [
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorNews.toName,
                path: Routes.instructorNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NewsScreen())),
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorCalendar.toName,
                path: Routes.instructorCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorUserList.toName,
                path: Routes.instructorUserList.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: UserManagerScreen())),
            GoRoute(
                parentNavigatorKey: _instructorNavigatorKey,
                name: Routes.instructorReportIssue.toName,
                path: Routes.instructorReportIssue.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ReportIssueScreen())),
          ]),
      ShellRoute(
          navigatorKey: _studentNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: Footer(
                  location: state.location,
                  nav: [
                    NavBarItem(
                        icon: const Icon(Icons.newspaper),
                        location: Routes.studentNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.image),
                        location: Routes.studentNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.calendar_month),
                        location: Routes.studentCalendar.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.person),
                        location: Routes.studentNews.toPath),
                    NavBarItem(
                        icon: const Icon(Icons.warning),
                        location: Routes.studentReportIssue.toPath)
                  ],
                  child: child)),
          routes: [
            GoRoute(
                parentNavigatorKey: _studentNavigatorKey,
                name: Routes.studentNews.toName,
                path: Routes.studentNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NewsScreen())),
            GoRoute(
                parentNavigatorKey: _studentNavigatorKey,
                name: Routes.studentCalendar.toName,
                path: Routes.studentCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
            GoRoute(
                parentNavigatorKey: _studentNavigatorKey,
                name: Routes.studentReportIssue.toName,
                path: Routes.studentReportIssue.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ReportIssueScreen())),
          ])
    ],
    errorBuilder: (context, state) =>
        ErrorScreen(key: state.pageKey, error: state.error.toString()));

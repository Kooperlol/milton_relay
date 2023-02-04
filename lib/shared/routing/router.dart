import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/admin/screens/add_event_screen.dart';
import 'package:milton_relay/admin/screens/add_user_screen.dart';
import 'package:milton_relay/admin/screens/user_manager_screen.dart';
import 'package:milton_relay/admin/screens/view_children_screen.dart';
import 'package:milton_relay/admin/widgets/footer.dart';
import 'package:milton_relay/parent/models/parent.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/screens/calendar_screen.dart';
import 'package:milton_relay/shared/screens/error_screen.dart';
import 'package:milton_relay/shared/screens/loading_screen.dart';
import 'package:milton_relay/shared/screens/login_screen.dart';
import 'package:milton_relay/shared/screens/media_screen.dart';
import 'package:milton_relay/shared/services/auth_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: "/",
    routes: [
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LoadingScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.login.toName,
          path: Routes.login.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LoginScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.addUserScreen.toName,
          path: Routes.addUserScreen.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AddUserScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.addEventScreen.toName,
          path: Routes.addEventScreen.toPath,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AddEventScreen())),
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          name: Routes.viewChildren.toName,
          path: Routes.viewChildren.toPath,
          pageBuilder: (context, state) => NoTransitionPage(
              child: ViewChildrenScreen(parent: state.extra as ParentModel))),
      ShellRoute(
          navigatorKey: _adminNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage(
              child: AdminFooter(location: state.location, child: child)),
          routes: [
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminNews.toName,
                path: Routes.adminNews.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MediaScreen())),
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.userManagerScreen.toName,
                path: Routes.userManagerScreen.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: UserManagerScreen())),
            GoRoute(
                parentNavigatorKey: _adminNavigatorKey,
                name: Routes.adminCalendar.toName,
                path: Routes.adminCalendar.toPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen())),
          ])
    ],
    redirect: (context, state) {
      if (state.location == Routes.login.toPath || state.location == '/') {
        return;
      }
      AuthService().authState.first.then((user) async {
        if (user == null) {
          return context.namedLocation(Routes.login.toName);
        } else {
          return true;
        }
      });
      return null;
    },
    errorBuilder: (context, state) =>
        ErrorScreen(key: state.pageKey, error: state.error.toString()));

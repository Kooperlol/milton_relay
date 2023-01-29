import 'package:go_router/go_router.dart';
import 'package:milton_relay/admin/screens/add_user_screen.dart';
import 'package:milton_relay/admin/screens/user_manager_screen.dart';
import 'package:milton_relay/admin/screens/view_children_screen.dart';
import 'package:milton_relay/parent/models/parent.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/screens/loading_screen.dart';
import 'package:milton_relay/shared/screens/login_screen.dart';
import 'package:milton_relay/shared/screens/media_screen.dart';

class AppRouter {
  GoRouter router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      name: Routes.login.toName,
      path: Routes.login.toPath,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: Routes.news.toName,
      path: Routes.news.toPath,
      builder: (context, state) => const MediaScreen(),
    ),
    GoRoute(
      name: Routes.userManagerScreen.toName,
      path: Routes.userManagerScreen.toPath,
      builder: (context, state) => const UserManagerScreen(),
    ),
    GoRoute(
      name: Routes.addUserScreen.toName,
      path: Routes.addUserScreen.toPath,
      builder: (context, state) => const AddUserScreen(),
    ),
    GoRoute(
      name: Routes.viewChildren.toName,
      path: Routes.viewChildren.toPath,
      builder: (context, state) =>
          ViewChildrenScreen(parent: state.extra as ParentModel),
    )
  ]);
}

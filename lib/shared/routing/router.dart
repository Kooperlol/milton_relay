import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/routing/router_routes.dart';
import 'package:milton_relay/shared/screens/loading_screen.dart';
import 'package:milton_relay/shared/screens/login_screen.dart';
import 'package:milton_relay/student/screens/dashboard_screen.dart';

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
      name: Routes.studentDashboard.toName,
      path: Routes.studentDashboard.toPath,
      builder: (context, state) => const DashboardScreen(),
    )
  ]);
}

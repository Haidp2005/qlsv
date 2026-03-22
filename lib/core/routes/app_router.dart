import 'package:go_router/go_router.dart';
import 'route_constants.dart';
import '../../features/position4_dashboard.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.dashboard,
    routes: [
      GoRoute(
        path: RouteConstants.dashboard,
        builder: (context, state) => const Position4Dashboard(),
      ),
      GoRoute(
        path: RouteConstants.profile,
        builder: (context, state) => const ProfileScreen(role: 'student'),
      ),
      GoRoute(
        path: RouteConstants.notifications,
        builder: (context, state) => const NotificationScreen(role: 'student'),
      ),
      GoRoute(
        path: RouteConstants.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
}

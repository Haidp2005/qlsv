import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/lecturer/presentation/pages/lecturer_dashboard_page.dart';
import 'route_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.login,
    routes: [
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.studentDashboard,
        builder: (context, state) => const StudentDashboardPage(),
      ),
      GoRoute(
        path: RouteConstants.lecturerDashboard,
        builder: (context, state) => const LecturerDashboardPage(),
      ),
    ],
  );
}

import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/lecturer/presentation/pages/lecturer_dashboard_page.dart';

// Import các màn hình của Vị trí 4
import '../../features/position4_dashboard.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';

import 'route_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.login, // Trả về trang chủ là Login theo chuẩn
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
      
      // Các route nhánh 4
      GoRoute(
        path: RouteConstants.dashboard,
        builder: (context, state) => const Position4Dashboard(),
      ),
      GoRoute(
        path: RouteConstants.profile,
        builder: (context, state) {
          // Lấy role được truyền qua extra (vd: context.push(..., extra: 'lecturer'))
          // Mặc định là 'student' nếu không truyền
          final role = (state.extra as String?) ?? 'student';
          return ProfileScreen(role: role);
        },
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/incidents/add_report/add_report_screen.dart';
import '../../features/incidents/detail/incident_detail_screen.dart';
import '../../features/incidents/recovered/recovered_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reports/create_report_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../widgets/pantaura_bottom_nav.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createReport,
        builder: (context, state) => const CreateReportScreen(),
      ),
      GoRoute(
        path: AppRoutes.incidentDetailPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return IncidentDetailScreen(incidentId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.incidentAddReportPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AddReportScreen(incidentId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.incidentRecoveredPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RecoveredScreen(incidentId: id);
        },
      ),
    ],
  );
});

class _ScaffoldWithBottomNav extends StatelessWidget {
  const _ScaffoldWithBottomNav({
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: PantauraBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: (tappedIndex) {
          navigationShell.goBranch(
            tappedIndex,
            initialLocation: tappedIndex == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

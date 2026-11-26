import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/incidents/incident_detail_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../theme/theme.dart';
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
                builder: (context, state) => const _PlaceholderTabScreen(
                  title: 'Peta Bencana',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const _PlaceholderTabScreen(
                  title: 'Riwayat Laporan',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const _PlaceholderTabScreen(
                  title: 'Profil Warga',
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createReport,
        builder: (context, state) => const _PlaceholderDetailScreen(
          title: 'Buat Laporan Bencana',
        ),
      ),
      GoRoute(
        path: AppRoutes.incidentDetailPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return IncidentDetailScreen(incidentId: id);
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

class _PlaceholderTabScreen extends StatelessWidget {
  const _PlaceholderTabScreen({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Text(
            'Halaman $title sedang dalam pengembangan.',
            style: AppTypography.bodyLg,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _PlaceholderDetailScreen extends StatelessWidget {
  const _PlaceholderDetailScreen({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Halaman $title sedang dalam pengembangan.',
                style: AppTypography.bodyLg,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.spaceXs),
                Text(subtitle!, style: AppTypography.caption),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

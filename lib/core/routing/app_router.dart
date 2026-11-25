import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
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
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => const _PlaceholderTabScreen(
          title: 'Peta Bencana',
          bottomNavIndex: 1,
        ),
      ),
      GoRoute(
        path: AppRoutes.createReport,
        builder: (context, state) => const _PlaceholderDetailScreen(
          title: 'Buat Laporan Bencana',
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const _PlaceholderTabScreen(
          title: 'Riwayat Laporan',
          bottomNavIndex: 2,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const _PlaceholderTabScreen(
          title: 'Profil Warga',
          bottomNavIndex: 3,
        ),
      ),
      GoRoute(
        path: AppRoutes.incidentDetailPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _PlaceholderDetailScreen(
            title: 'Detail Insiden',
            subtitle: 'ID: $id',
          );
        },
      ),
    ],
  );
});

class _PlaceholderTabScreen extends StatelessWidget {
  const _PlaceholderTabScreen({
    required this.title,
    required this.bottomNavIndex,
  });

  final String title;
  final int bottomNavIndex;

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
      bottomNavigationBar: PantauraBottomNav(currentIndex: bottomNavIndex),
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

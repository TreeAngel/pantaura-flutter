import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/incident_status_chip.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PantauraApp()));
}

class PantauraApp extends ConsumerWidget {
  const PantauraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Pantaura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

class ThemeShowcaseScreen extends StatelessWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantaura Civic Emergency'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          children: [
            Text('Display Hero', style: AppTypography.displayHero),
            const SizedBox(height: AppSpacing.spaceXs),
            Text('Headline Large', style: AppTypography.headlineLg),
            const SizedBox(height: AppSpacing.spaceXs),
            Text('Headline Medium', style: AppTypography.headlineMd),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              'Aplikasi respon tanggap bencana dan pelaporan warga dengan standar aksesibilitas tinggi untuk situasi darurat.',
              style: AppTypography.bodyLg,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            const Divider(),
            const SizedBox(height: AppSpacing.spaceMd),

            Text('Status Insiden (WCAG AAA)', style: AppTypography.headlineSm),
            const SizedBox(height: AppSpacing.spaceSm),
            const Wrap(
              spacing: AppSpacing.spaceXs,
              runSpacing: AppSpacing.spaceXs,
              children: [
                IncidentStatusChip(status: IncidentStatus.unverified),
                IncidentStatusChip(status: IncidentStatus.verified),
                IncidentStatusChip(status: IncidentStatus.resolutionSubmitted),
                IncidentStatusChip(status: IncidentStatus.resolved),
                IncidentStatusChip(status: IncidentStatus.rejected),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            Text('Input Field', style: AppTypography.headlineSm),
            const SizedBox(height: AppSpacing.spaceXs),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Lokasi Kejadian',
                hintText: 'Masukkan nama jalan atau kelurahan',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            Text('Tombol Aksi (Elder-Friendly 56px)', style: AppTypography.headlineSm),
            const SizedBox(height: AppSpacing.spaceSm),
            PrimaryButton(
              label: 'Laporkan Bencana Sekarang',
              icon: Icons.campaign_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            SecondaryButton(
              label: 'Lihat Peta Evakuasi',
              icon: Icons.map_rounded,
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_alert_rounded, size: 28),
      ),
    );
  }
}

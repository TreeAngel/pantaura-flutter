import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final List<({int pct, String text})> _stages = const [
    (pct: 35, text: 'Menghubungkan sensor darurat...'),
    (pct: 74, text: 'Memeriksa status siaga wilayah Anda...'),
    (pct: 92, text: 'Sinkronisasi posko & logistik terkini...'),
    (pct: 100, text: 'Sistem siap. Membuka dashboard aman...'),
  ];

  int _currentStageIndex = 0;
  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startStageSimulation();
  }

  void _startStageSimulation() {
    _stageTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      if (_currentStageIndex < _stages.length - 1) {
        setState(() {
          _currentStageIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          context.go(AppRoutes.login);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = _stages[_currentStageIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient sesuai Stitch & DESIGN.md
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF253B6E), // text-header / dark navy
                  Color(0xFF1E4D70),
                  Color(0xFF1F5F8B), // primary-container
                ],
              ),
            ),
          ),

          // Dynamic Ambient Topographic Lines
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _TopographicLinesPainter(),
              ),
            ),
          ),

          // Soft Ambient Radial Glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1891AC).withValues(alpha: 0.25),
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
                vertical: AppSpacing.spaceSm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Authority Badge
                  _buildAuthorityBadge(),

                  // Center Crest & Identity
                  _buildCenterIdentity(),

                  // Bottom Dock & Emergency Call
                  _buildBottomDock(currentStage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceXs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Color(0xFFD2ECF9), // surface-tint-ice
            size: 18,
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          Text(
            'Bekerja sama dengan BPBD & Posko Siaga',
            style: AppTypography.labelSm.copyWith(
              color: const Color(0xFFD2ECF9),
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIdentity() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emblem Container with Radar Pulse Ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Radar pulse ring
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1891AC).withValues(alpha: 0.18),
                ),
              ),
            ),

            // Sturdy Shield Outer Box
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFF163A5E),
                    Color(0xFF253B6E),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF1A446C).withValues(alpha: 0.9),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/pantaura-logo-svg.svg',
                    width: 64,
                    height: 64,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.spaceLg),

        // App Title
        Text(
          'Pantaura',
          style: AppTypography.displayHero.copyWith(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: AppSpacing.space2xs),

        // Subtitle
        Text(
          'Sistem Tanggap Bencana & Pemulihan Warga',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            color: const Color(0xFFD2ECF9),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: AppSpacing.spaceMd),

        // Reassurance Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceSm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1891AC).withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF16A34A), // status-resolved green
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Text(
                'Jaringan Siaga Nasional Aktif',
                style: AppTypography.labelSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomDock(({int pct, String text}) currentStage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live Status Checker Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            color: const Color(0xFF001D31).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1891AC),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spaceXs),
                        Expanded(
                          child: Text(
                            currentStage.text,
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFFD2ECF9),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${currentStage.pct}%',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFFD2ECF9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: currentStage.pct / 100.0,
                  ),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor:
                          const Color(0xFF1F5F8B).withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1891AC),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.spaceMd),

        // Hotline 112 & Inclusion Strip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // SOS 112 Quick Touch
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceSm,
                vertical: AppSpacing.spaceXs,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: const Color(0xFFFEE2E2).withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.phone_in_talk_rounded,
                    color: Color(0xFFFEE2E2),
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.spaceXs),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Darurat: 112',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bebas Pulsa',
                        style: TextStyle(
                          color: Color(0xFFD2ECF9),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Inclusion Pillars
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Aman • Cepat • Inklusif',
                  style: AppTypography.labelSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ramah Lansia & Disabilitas',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFFD2ECF9).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.spaceSm),

        // Build Version
        Text(
          'v1.0.0 • Pantaura',
          style: AppTypography.caption.copyWith(
            color: const Color(0xFFD2ECF9).withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Custom Painter for Background Topographic Lines
class _TopographicLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint1 = Paint()
      ..color = const Color(0xFFD2ECF9).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final linePaint2 = Paint()
      ..color = const Color(0xFF1891AC).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path1 = Path()
      ..moveTo(0, h * 0.25)
      ..cubicTo(w * 0.3, h * 0.15, w * 0.6, h * 0.35, w, h * 0.20);
    canvas.drawPath(path1, linePaint1);

    final path2 = Path()
      ..moveTo(0, h * 0.45)
      ..cubicTo(w * 0.35, h * 0.38, w * 0.65, h * 0.55, w, h * 0.42);
    canvas.drawPath(path2, linePaint2);

    final path3 = Path()
      ..moveTo(0, h * 0.65)
      ..cubicTo(w * 0.25, h * 0.75, w * 0.7, h * 0.55, w, h * 0.68);
    canvas.drawPath(path3, linePaint1);

    // Concentric rings
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.55,
      linePaint1,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.85,
      linePaint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

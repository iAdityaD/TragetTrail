import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/notification_service.dart';
import '../core/services/widget_sync_service.dart';
import '../data/local/app_database.dart';
import '../data/repositories/achievement_entry_repository.dart';
import '../data/repositories/countdown_repository.dart';
import '../data/repositories/theme_preferences_repository.dart';
import '../features/shared/providers.dart';
import '../features/shared/reminder_orchestrator.dart';
import 'app.dart';
import 'theme.dart';

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  static const _minimumStartupScreen = Duration(seconds: 10);

  _BootstrapBundle? _bundle;
  Object? _error;
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDependencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _bundle;
    if (bundle != null) {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(bundle.database),
          sharedPreferencesProvider.overrideWithValue(bundle.preferences),
          achievementEntryRepositoryProvider.overrideWithValue(
            bundle.achievementEntryRepository,
          ),
          countdownRepositoryProvider.overrideWithValue(
            bundle.countdownRepository,
          ),
          themePreferencesRepositoryProvider.overrideWithValue(
            bundle.themePreferencesRepository,
          ),
          notificationServiceProvider.overrideWithValue(
            bundle.notificationService,
          ),
          widgetSyncServiceProvider.overrideWithValue(bundle.widgetSyncService),
          reminderOrchestratorProvider.overrideWithValue(bundle.orchestrator),
        ],
        child: const CountdownApp(),
      );
    }

    return MaterialApp(
      title: 'TargetTrail',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(
        Brightness.light,
        seedColor: const Color(0xFFEF4444),
      ),
      darkTheme: buildAppTheme(
        Brightness.dark,
        seedColor: const Color(0xFFEF4444),
      ),
      themeMode: ThemeMode.system,
      home: StartupScreen(
        error: _error?.toString(),
        onRetry: _loadDependencies,
      ),
    );
  }

  Future<void> _loadDependencies() async {
    setState(() {
      _error = null;
    });

    try {
      final preferences = await SharedPreferences.getInstance();
      final database = AppDatabase();
      final achievementEntryRepository = AchievementEntryRepository(database);
      final countdownRepository = CountdownRepository(
        database,
        achievementEntryRepository,
      );
      final themePreferencesRepository =
          ThemePreferencesRepository(preferences);
      final notificationService = NotificationService();
      final widgetSyncService = WidgetSyncService();
      final orchestrator = ReminderOrchestrator(
        countdownRepository: countdownRepository,
        notificationService: notificationService,
        widgetSyncService: widgetSyncService,
      );

      final elapsed = DateTime.now().difference(_startedAt);
      final remaining = _minimumStartupScreen - elapsed;
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _bundle = _BootstrapBundle(
          database: database,
          preferences: preferences,
          achievementEntryRepository: achievementEntryRepository,
          countdownRepository: countdownRepository,
          themePreferencesRepository: themePreferencesRepository,
          notificationService: notificationService,
          widgetSyncService: widgetSyncService,
          orchestrator: orchestrator,
        );
      });

      unawaited(orchestrator.sync());
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
      });
    }
  }
}

class _BootstrapBundle {
  const _BootstrapBundle({
    required this.database,
    required this.preferences,
    required this.achievementEntryRepository,
    required this.countdownRepository,
    required this.themePreferencesRepository,
    required this.notificationService,
    required this.widgetSyncService,
    required this.orchestrator,
  });

  final AppDatabase database;
  final SharedPreferences preferences;
  final AchievementEntryRepository achievementEntryRepository;
  final CountdownRepository countdownRepository;
  final ThemePreferencesRepository themePreferencesRepository;
  final NotificationService notificationService;
  final WidgetSyncService widgetSyncService;
  final ReminderOrchestrator orchestrator;
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final String? error;
  final Future<void> Function() onRetry;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  static const _tips = [
    'Pin your most important target so it stays featured across the app.',
    'Use milestones daily to build a visible progress trail toward the finish.',
    'Add multiple widgets to track different goals side by side.',
    'Per-target reminders are quieter and more reliable than one global alarm.',
  ];

  late final AnimationController _controller;
  late final Timer _timer;
  var _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tipIndex = (_tipIndex + 1) % _tips.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF020617), Color(0xFF111827)]
                : const [Color(0xFFF8FAFC), Color(0xFFFDECEC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Center(
                  child: _PlaneMilestoneAnimation(controller: _controller),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 92,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final phase =
                                (_controller.value + (index * 0.18)) % 1;
                            final scale =
                                0.72 + ((1 - (phase - 0.5).abs() * 2) * 0.48);
                            return Transform.scale(
                              scale: scale.clamp(0.72, 1.2),
                              child: child,
                            );
                          },
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(
                                0.55 + (index * 0.12),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    'TargetTrail',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Preparing your countdowns, reminders, and widgets.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tip',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _tips[_tipIndex],
                            key: ValueKey(_tipIndex),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Startup issue',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(widget.error!),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: widget.onRetry,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Center(
                  child: Text(
                    'Track. Focus. Finish.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: theme.colorScheme.onSurface.withOpacity(0.82),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Small wins. Clear milestones. Real momentum.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaneMilestoneAnimation extends StatelessWidget {
  const _PlaneMilestoneAnimation({
    required this.controller,
  });

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 260,
      height: 144,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = controller.value;
          final planeX = 28 + (t * 188);
          final planeY = 90 - math.sin(t * math.pi * 1.15) * 26;
          final tilt = -0.35 + math.sin(t * math.pi * 2) * 0.18;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TrailPainter(
                    progress: t,
                    baseColor: theme.colorScheme.primary,
                    mutedColor: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              for (final item in const [
                (x: 46.0, y: 74.0, delay: 0.15),
                (x: 122.0, y: 46.0, delay: 0.45),
                (x: 198.0, y: 68.0, delay: 0.75),
              ])
                Positioned(
                  left: item.x,
                  top: item.y,
                  child: _MilestoneFlag(
                    controller: controller,
                    delay: item.delay,
                  ),
                ),
              Positioned(
                left: planeX,
                top: planeY,
                child: Transform.rotate(
                  angle: tilt,
                  child: Icon(
                    Icons.send_rounded,
                    size: 34,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MilestoneFlag extends StatelessWidget {
  const _MilestoneFlag({
    required this.controller,
    required this.delay,
  });

  final Animation<double> controller;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final phase = ((controller.value - delay) % 1 + 1) % 1;
    final active = phase < 0.2;
    final theme = Theme.of(context);

    return Opacity(
      opacity: active ? 1 : 0.75,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 3,
                height: 34,
                color: theme.colorScheme.onSurface.withOpacity(0.28),
              ),
              Positioned(
                left: 3,
                top: 2,
                child: AnimatedScale(
                  scale: active ? 1.08 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: CustomPaint(
                    size: const Size(20, 16),
                    painter: _FlagPainter(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  const _TrailPainter({
    required this.progress,
    required this.baseColor,
    required this.mutedColor,
  });

  final double progress;
  final Color baseColor;
  final Color mutedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(26, 104)
      ..quadraticBezierTo(size.width * 0.28, 92, size.width * 0.42, 62)
      ..quadraticBezierTo(size.width * 0.62, 22, size.width * 0.8, 72)
      ..quadraticBezierTo(size.width * 0.88, 96, size.width - 18, 78);

    final basePaint = Paint()
      ..color = mutedColor.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, basePaint);

    final metric = path.computeMetrics().first;
    final activePath = metric.extractPath(0, metric.length * progress);
    final activePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          baseColor.withOpacity(0.15),
          baseColor,
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(activePath, activePaint);
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.mutedColor != mutedColor;
  }
}

class _FlagPainter extends CustomPainter {
  const _FlagPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height * 0.28)
      ..lineTo(0, size.height * 0.56)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

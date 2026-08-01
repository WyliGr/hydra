import 'package:flutter/material.dart';
import '../services/hydra_state.dart';
import '../services/notification_service.dart';
import '../utils/theme.dart';

/// First-launch onboarding flow shown when [HydraState.hasCompletedOnboarding]
/// is false. Walks the user through welcome → profile → reminder setup.
class OnboardingScreen extends StatefulWidget {
  final HydraState state;
  final VoidCallback onCompleted;

  const OnboardingScreen({
    super.key,
    required this.state,
    required this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  final TextEditingController _weightController =
      TextEditingController(text: '70');
  bool _remindersEnabled = true;
  int _reminderInterval = 2;

  @override
  void dispose() {
    _pageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  int? get _weightKg {
    final v = int.tryParse(_weightController.text);
    if (v == null || v < 20 || v > 300) return null;
    return v;
  }

  int get _recommendedGoalMl => (_weightKg ?? 70) * 35;

  void _next() {
    if (_page < 2) {
      _pageController.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page == 0) return;
    _pageController.animateToPage(
      _page - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _page--);
  }

  Future<void> _finish() async {
    final weight = _weightKg ?? 70;

    await widget.state.saveProfile(
      widget.state.profile.copyWith(
        weightKg: weight,
        autoGoal: true,
      ),
    );

    if (_remindersEnabled) {
      await NotificationService.scheduleReminder(
        startHour: widget.state.profile.wakeHour,
        intervalHours: _reminderInterval,
      );
    } else {
      await NotificationService.cancelAll();
    }

    await widget.state.completeOnboarding();
    if (!mounted) return;
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HydraTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — skip / back
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  if (_page > 0)
                    GestureDetector(
                      onTap: _back,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('BACK', style: HydraTheme.label),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
                  const Spacer(),
                  if (_page < 2)
                    GestureDetector(
                      onTap: _finish,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'SKIP',
                          style: HydraTheme.label.copyWith(
                            color: HydraTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(),
                  _ProfilePage(
                    weightController: _weightController,
                    onChanged: (_) => setState(() {}),
                    recommendedMl: _recommendedGoalMl,
                  ),
                  _ReminderPage(
                    remindersEnabled: _remindersEnabled,
                    interval: _reminderInterval,
                    onToggle: (v) => setState(() => _remindersEnabled = v),
                    onSelectInterval: (h) =>
                        setState(() => _reminderInterval = h),
                  ),
                ],
              ),
            ),

            // Bottom CTA + dots
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  _PageDots(count: 3, current: _page),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: (_page == 1 && _weightKg == null) ? null : _next,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: HydraTheme.background,
                        border: Border.all(
                          color: (_page == 1 && _weightKg == null)
                              ? HydraTheme.borderStrong
                              : HydraTheme.textPrimary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        (_page < 2 ? 'CONTINUE' : "LET'S GO"),
                        style: HydraTheme.body.copyWith(
                          fontSize: 13,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w500,
                          color: (_page == 1 && _weightKg == null)
                              ? HydraTheme.textTertiary
                              : HydraTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1: Welcome ──────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Wireframe bottle (outline only)
          SizedBox(
            width: 140,
            height: 220,
            child: CustomPaint(
              painter: _WireBottlePainter(),
            ),
          ),
          const SizedBox(height: 40),
          Text('HYDRA', style: HydraTheme.displayLarge),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: HydraTheme.border,
            indent: 60,
            endIndent: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'TRACK WATER.\nCOMPENSATE DRINKS.',
            textAlign: TextAlign.center,
            style: HydraTheme.label.copyWith(
              fontSize: 12,
              height: 1.8,
              color: HydraTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WireBottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    final path = Path()
      ..moveTo(centerX - 16, 8)
      ..lineTo(centerX - 16, 28)
      ..quadraticBezierTo(centerX - 24, 42, centerX - 32, 56)
      ..lineTo(centerX - 32, h - 24)
      ..quadraticBezierTo(centerX - 32, h - 12, centerX - 18, h - 12)
      ..lineTo(centerX + 18, h - 12)
      ..quadraticBezierTo(centerX + 32, h - 12, centerX + 32, h - 24)
      ..lineTo(centerX + 32, 56)
      ..quadraticBezierTo(centerX + 24, 42, centerX + 16, 28)
      ..lineTo(centerX + 16, 8)
      ..close();

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = HydraTheme.textPrimary;
    canvas.drawPath(path, outline);

    // Cap
    final capRect = Rect.fromLTRB(centerX - 14, 4, centerX + 14, 14);
    canvas.drawRect(capRect, outline);

    // Hint dots
    final dotPaint = Paint()..color = HydraTheme.borderStrong;
    for (double y = 80; y < h - 20; y += 8) {
      for (double x = centerX - 28; x <= centerX + 28; x += 8) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Page 2: Profile ──────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  final TextEditingController weightController;
  final ValueChanged<String> onChanged;
  final int recommendedMl;

  const _ProfilePage({
    required this.weightController,
    required this.onChanged,
    required this.recommendedMl,
  });

  @override
  Widget build(BuildContext context) {
    final liters = (recommendedMl / 1000).toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text('WEIGHT', style: HydraTheme.label),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 140,
                child: TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  onChanged: onChanged,
                  style: HydraTheme.dataLarge,
                  cursorColor: HydraTheme.textPrimary,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'KG',
                  style: HydraTheme.label.copyWith(
                    color: HydraTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(
            height: 1,
            thickness: 1,
            color: HydraTheme.border,
          ),
          const SizedBox(height: 24),
          Text('GOAL', style: HydraTheme.label),
          const SizedBox(height: 6),
          Text(
            '$liters L / DAY',
            style: HydraTheme.dataMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '(35ML/KG)',
            style: HydraTheme.label.copyWith(
              color: HydraTheme.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Reminders ────────────────────────────────────────

class _ReminderPage extends StatelessWidget {
  final bool remindersEnabled;
  final int interval;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onSelectInterval;

  const _ReminderPage({
    required this.remindersEnabled,
    required this.interval,
    required this.onToggle,
    required this.onSelectInterval,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text('REMINDERS', style: HydraTheme.label),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ENABLED', style: HydraTheme.body),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onToggle(!remindersEnabled),
                child: Container(
                  width: 44,
                  height: 22,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: HydraTheme.background,
                    border: Border.all(
                      color: remindersEnabled
                          ? HydraTheme.accent
                          : HydraTheme.borderStrong,
                      width: 1,
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 150),
                    alignment: remindersEnabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: remindersEnabled
                          ? HydraTheme.accent
                          : HydraTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(
            height: 1,
            thickness: 1,
            color: HydraTheme.border,
          ),
          const SizedBox(height: 24),
          Text('INTERVAL', style: HydraTheme.label),
          const SizedBox(height: 14),
          Row(
            children: [1, 2, 3, 4].map((h) {
              final selected = interval == h;
              final disabled = !remindersEnabled;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap:
                        disabled ? null : () => onSelectInterval(h),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: HydraTheme.background,
                        border: Border.all(
                          color: selected
                              ? HydraTheme.accent
                              : HydraTheme.borderStrong,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${h}H',
                        style: HydraTheme.dataSmall.copyWith(
                          color: selected
                              ? HydraTheme.accent
                              : (disabled
                                  ? HydraTheme.textTertiary
                                  : HydraTheme.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Page indicator dots ──────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int count;
  final int current;
  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? HydraTheme.textPrimary
                : HydraTheme.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? HydraTheme.textPrimary
                  : HydraTheme.textTertiary,
              width: 1,
            ),
          ),
        );
      }),
    );
  }
}

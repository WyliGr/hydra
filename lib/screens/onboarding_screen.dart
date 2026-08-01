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
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HydraTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip / progress header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back,
                          color: HydraTheme.textSecondary),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  if (_page < 2)
                    TextButton(
                      onPressed: _finish,
                      child: const Text(
                        'Passer',
                        style: TextStyle(color: HydraTheme.textSecondary),
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _page == 1 && _weightKg == null
                          ? null
                          : _next,
                      child: Text(_page < 2 ? 'Continuer' : 'C\'est parti !'),
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
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [HydraTheme.accent, HydraTheme.primary],
                center: Alignment.center,
                radius: 0.7,
              ),
              boxShadow: [
                BoxShadow(
                  color: HydraTheme.primary.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.water_drop,
              size: 90,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Bienvenue sur Hydra 💧',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HydraTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tracker ta eau + compenser tes boissons',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HydraTheme.textSecondary,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.fitness_center,
              size: 64, color: HydraTheme.accent),
          const SizedBox(height: 24),
          const Text(
            'Quel est ton poids ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HydraTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'On calcule ton objectif idéal avec ça.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: HydraTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: HydraTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: onChanged,
                    style: const TextStyle(
                      color: HydraTheme.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'kg',
                    style: TextStyle(
                      color: HydraTheme.textSecondary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: HydraTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HydraTheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag, color: HydraTheme.primary, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ton objectif: $liters L/jour',
                        style: const TextStyle(
                          color: HydraTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '(35ml/kg)',
                        style: TextStyle(
                          color: HydraTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.notifications_active,
              size: 64, color: HydraTheme.accent),
          const SizedBox(height: 24),
          const Text(
            'Rappels',
            style: TextStyle(
              color: HydraTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Active des rappels pour ne jamais oublier de boire.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: HydraTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: HydraTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SwitchListTile(
              value: remindersEnabled,
              activeColor: HydraTheme.primary,
              title: const Text(
                'Activer les rappels',
                style: TextStyle(
                    color: HydraTheme.textPrimary,
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                remindersEnabled
                    ? 'Tu recevras des notifications'
                    : 'Aucune notification',
                style: const TextStyle(
                    color: HydraTheme.textSecondary, fontSize: 12),
              ),
              onChanged: onToggle,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: remindersEnabled ? 1 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: HydraTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Intervalle',
                    style: TextStyle(
                      color: HydraTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [1, 2, 3, 4].map((h) {
                      final selected = interval == h;
                      final disabled = !remindersEnabled;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: disabled
                                ? null
                                : () => onSelectInterval(h),
                            child: Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? HydraTheme.primary
                                    : HydraTheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? HydraTheme.primary
                                      : HydraTheme.surfaceLight,
                                ),
                              ),
                              child: Text(
                                '${h}h',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : (disabled
                                          ? HydraTheme.textSecondary
                                              .withValues(alpha: 0.5)
                                          : HydraTheme.textSecondary),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
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
            ),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? HydraTheme.primary : HydraTheme.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

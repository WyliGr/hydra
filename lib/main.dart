import 'package:flutter/material.dart';
import 'services/hydra_state.dart';
import 'services/widget_service.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = HydraState();
  await state.init();
  await WidgetService.init();
  await NotificationService.init();
  await NotificationService.requestPermissions();

  // Initial widget update
  WidgetService.updateWidget(
    todayMl: state.todayWaterMl,
    goalMl: state.dailyGoalMl,
    debtMl: state.waterDebtMl,
  );

  runApp(HydraApp(state: state));
}

class HydraApp extends StatelessWidget {
  final HydraState state;
  const HydraApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydra',
      theme: HydraTheme.dark,
      debugShowCheckedModeBanner: false,
      home: _RootRouter(state: state),
    );
  }
}

class _RootRouter extends StatefulWidget {
  final HydraState state;
  const _RootRouter({required this.state});

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.ready) {
      return const Scaffold(
        backgroundColor: HydraTheme.background,
        body: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: HydraTheme.textPrimary,
              strokeWidth: 1.5,
            ),
          ),
        ),
      );
    }

    if (!widget.state.hasCompletedOnboarding) {
      return OnboardingScreen(
        state: widget.state,
        onCompleted: () {
          if (mounted) setState(() {});
        },
      );
    }

    return HydraNav(state: widget.state);
  }
}

class HydraNav extends StatefulWidget {
  final HydraState state;
  const HydraNav({super.key, required this.state});

  @override
  State<HydraNav> createState() => _HydraNavState();
}

class _HydraNavState extends State<HydraNav> {
  int _index = 0;

  static const _tabs = ['HOME', 'STATS', 'SETTINGS'];

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(state: widget.state),
      StatsScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];

    return Scaffold(
      backgroundColor: HydraTheme.background,
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: HydraTheme.background,
          border: Border(
            top: BorderSide(color: HydraTheme.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = i == _index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _index = i),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                active ? HydraTheme.textPrimary : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        _tabs[i],
                        style: HydraTheme.label.copyWith(
                          color: active
                              ? HydraTheme.textPrimary
                              : HydraTheme.textTertiary,
                          fontSize: 11,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

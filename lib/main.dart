import 'package:flutter/material.dart';
import 'services/hydra_state.dart';
import 'services/widget_service.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

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
      home: HydraNav(state: state),
    );
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

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(state: widget.state),
      StatsScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: HydraTheme.surface,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}
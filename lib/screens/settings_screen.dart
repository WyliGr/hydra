import 'package:flutter/material.dart';
import '../services/hydra_state.dart';
import '../models/user_profile.dart';
import '../utils/theme.dart';
import '../utils/format.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final HydraState state;
  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _weightController;
  late TextEditingController _goalController;
  late int _wakeHour;
  late int _sleepHour;
  late bool _autoGoal;
  late bool _remindersEnabled;
  late int _reminderInterval;

  @override
  void initState() {
    super.initState();
    final p = widget.state.profile;
    _weightController = TextEditingController(text: p.weightKg.toString());
    _goalController = TextEditingController(text: widget.state.dailyGoalMl.toString());
    _wakeHour = p.wakeHour;
    _sleepHour = p.sleepHour;
    _autoGoal = p.autoGoal;
    _remindersEnabled = true;
    _reminderInterval = 2;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Réglages',
                style: TextStyle(
                  color: HydraTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),

              // Profile section
              _SectionTitle(title: 'Profil'),
              const SizedBox(height: 12),
              _SettingTile(
                child: SwitchListTile(
                  title: const Text('Objectif auto', style: TextStyle(color: HydraTheme.textPrimary)),
                  subtitle: const Text('Calcule selon ton poids (35ml/kg)',
                      style: TextStyle(color: HydraTheme.textSecondary, fontSize: 12)),
                  value: _autoGoal,
                  activeColor: HydraTheme.primary,
                  onChanged: (v) => setState(() => _autoGoal = v),
                ),
              ),
              const SizedBox(height: 10),
              _SettingTile(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('Poids', style: TextStyle(color: HydraTheme.textPrimary)),
                      const Spacer(),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: HydraTheme.textPrimary),
                          decoration: const InputDecoration(
                            suffixText: 'kg',
                            suffixStyle: TextStyle(color: HydraTheme.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_autoGoal) ...[
                const SizedBox(height: 10),
                _SettingTile(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('Objectif quotidien', style: TextStyle(color: HydraTheme.textPrimary)),
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _goalController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: HydraTheme.textPrimary),
                            decoration: const InputDecoration(
                              suffixText: 'ml',
                              suffixStyle: TextStyle(color: HydraTheme.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_autoGoal) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Objectif recommandé: ${FormatUtil.ml((int.tryParse(_weightController.text) ?? 70) * 35)}',
                    style: const TextStyle(color: HydraTheme.textSecondary, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Reminders section
              _SectionTitle(title: 'Rappels'),
              const SizedBox(height: 12),
              _SettingTile(
                child: SwitchListTile(
                  title: const Text('Rappels actifs', style: TextStyle(color: HydraTheme.textPrimary)),
                  value: _remindersEnabled,
                  activeColor: HydraTheme.primary,
                  onChanged: (v) => setState(() => _remindersEnabled = v),
                ),
              ),
              const SizedBox(height: 10),
              _SettingTile(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Intervalle des rappels', style: TextStyle(color: HydraTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [1, 2, 3, 4].map((h) {
                          final selected = _reminderInterval == h;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _reminderInterval = h),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected ? HydraTheme.primary : HydraTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${h}h',
                                  style: TextStyle(
                                    color: selected ? Colors.white : HydraTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
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

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Enregistrer'),
                ),
              ),

              const SizedBox(height: 24),
              // About
              const Text(
                'Hydra v0.1.0',
                style: TextStyle(color: HydraTheme.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    final weight = int.tryParse(_weightController.text) ?? 70;
    final goal = int.tryParse(_goalController.text) ?? 2500;

    await widget.state.saveProfile(UserProfile(
      weightKg: weight,
      wakeHour: _wakeHour,
      sleepHour: _sleepHour,
      autoGoal: _autoGoal,
    ));

    if (!_autoGoal) {
      await widget.state.setDailyGoal(goal);
    }

    if (_remindersEnabled) {
      await NotificationService.scheduleReminder(
        startHour: _wakeHour,
        intervalHours: _reminderInterval,
      );
    } else {
      await NotificationService.cancelAll();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réglages sauvegardés !'),
          backgroundColor: HydraTheme.success,
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: HydraTheme.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final Widget child;
  const _SettingTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HydraTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
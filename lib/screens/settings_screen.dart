import 'package:flutter/material.dart';
import '../services/hydra_state.dart';
import '../models/user_profile.dart';
import '../utils/theme.dart';
import '../utils/format.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';

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
    _goalController =
        TextEditingController(text: widget.state.dailyGoalMl.toString());
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
      backgroundColor: HydraTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SETTINGS', style: HydraTheme.displayMedium),
              const SizedBox(height: 8),
              const Divider(
                height: 1,
                thickness: 1,
                color: HydraTheme.border,
              ),
              const SizedBox(height: 8),
              Text('PROFILE & DATA', style: HydraTheme.label),
              const SizedBox(height: 28),

              // PROFILE
              NothingDecor.hairlineWithLabel('PROFILE'),
              const SizedBox(height: 18),
              _SettingRow(
                label: 'AUTO GOAL',
                trailing: _NothingToggle(
                  value: _autoGoal,
                  onChanged: (v) => setState(() => _autoGoal = v),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '35ML/KG OF BODY WEIGHT',
                style: HydraTheme.label.copyWith(
                  color: HydraTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 24),

              _UnderlineField(
                label: 'WEIGHT',
                controller: _weightController,
                suffix: 'KG',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 28),

              if (!_autoGoal)
                _UnderlineField(
                  label: 'DAILY GOAL',
                  controller: _goalController,
                  suffix: 'ML',
                ),

              if (_autoGoal) ...[
                Text(
                  'GOAL · ${FormatUtil.ml((int.tryParse(_weightController.text) ?? 70) * 35)}/DAY',
                  style: HydraTheme.dataRed,
                ),
                const SizedBox(height: 6),
              ],

              const SizedBox(height: 28),

              // REMINDERS
              NothingDecor.hairlineWithLabel('REMINDERS'),
              const SizedBox(height: 18),
              _SettingRow(
                label: 'ENABLED',
                trailing: _NothingToggle(
                  value: _remindersEnabled,
                  onChanged: (v) => setState(() => _remindersEnabled = v),
                ),
              ),
              const SizedBox(height: 24),
              Text('INTERVAL', style: HydraTheme.label),
              const SizedBox(height: 12),
              Row(
                children: [1, 2, 3, 4].map((h) {
                  final selected = _reminderInterval == h;
                  final disabled = !_remindersEnabled;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: disabled
                            ? null
                            : () => setState(() => _reminderInterval = h),
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
              const SizedBox(height: 32),

              // DATA
              NothingDecor.hairlineWithLabel('DATA'),
              const SizedBox(height: 18),
              _ExportButton(
                label: 'EXPORT CSV',
                onPressed: _exportCsv,
              ),
              const SizedBox(height: 10),
              _ExportButton(
                label: 'EXPORT JSON BACKUP',
                onPressed: _exportJson,
              ),
              const SizedBox(height: 10),
              _ExportButton(
                label: 'IMPORT JSON BACKUP',
                onPressed: _importJson,
              ),

              const SizedBox(height: 32),

              // Save button — full width, 1px border, transparent bg
              GestureDetector(
                onTap: _save,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: HydraTheme.background,
                    border: Border.all(
                      color: HydraTheme.textPrimary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'SAVE',
                    style: HydraTheme.body.copyWith(
                      fontSize: 13,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'HYDRA V0.1.0',
                  style: HydraTheme.label.copyWith(
                    color: HydraTheme.textTertiary,
                    fontSize: 10,
                  ),
                ),
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
        SnackBar(
          content: Text('SETTINGS SAVED', style: HydraTheme.body),
          backgroundColor: HydraTheme.surfaceElevated,
        ),
      );
    }
  }

  // ── Export / Import handlers ─────────────────────────────────

  final ExportService _exportService = ExportService();

  Future<void> _exportCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _exportService.shareCsv();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'CSV READY — CHOOSE AN APP TO SHARE',
            style: HydraTheme.body,
          ),
          backgroundColor: HydraTheme.surfaceElevated,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('CSV EXPORT FAILED: $e', style: HydraTheme.body),
          backgroundColor: HydraTheme.surfaceElevated,
        ),
      );
    }
  }

  Future<void> _exportJson() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _exportService.shareJson();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'JSON BACKUP READY — CHOOSE AN APP',
            style: HydraTheme.body,
          ),
          backgroundColor: HydraTheme.surfaceElevated,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('JSON BACKUP FAILED: $e', style: HydraTheme.body),
          backgroundColor: HydraTheme.surfaceElevated,
        ),
      );
    }
  }

  Future<void> _importJson() async {
    final confirmed = await _confirmImport();
    if (confirmed != true) return;

    if (!mounted) return;
    final json = await _promptForJson();
    if (json == null || json.trim().isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final summary = await _exportService.importFromJson(json);
      widget.state.reloadFromStorage();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'IMPORTED — ${summary.waterLogs} WATER, ${summary.drinkLogs} DRINKS',
            style: HydraTheme.body,
          ),
          backgroundColor: HydraTheme.surfaceElevated,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('IMPORT FAILED: $e', style: HydraTheme.body),
          backgroundColor: HydraTheme.surfaceElevated,
        ),
      );
    }
  }

  Future<bool?> _confirmImport() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HydraTheme.surface,
        title: Text('IMPORT BACKUP?', style: HydraTheme.headline),
        content: Text(
          'This will REPLACE all current data '
          '(water logs, drinks, profile, goal) with the backup.\n\n'
          'Export a recent backup before continuing.',
          style: HydraTheme.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('CANCEL', style: HydraTheme.label),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('CONTINUE',
                style: HydraTheme.label.copyWith(color: HydraTheme.accent)),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptForJson() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HydraTheme.surface,
        title: Text('PASTE BACKUP JSON', style: HydraTheme.headline),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tip: use "Export JSON Backup" on the source device, '
                'save the file, then paste its contents here.',
                style: HydraTheme.bodySecondary.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 12,
                style: HydraTheme.dataSmall.copyWith(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: '{ "app": "hydra", ... }',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCEL', style: HydraTheme.label),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text('RESTORE',
                style: HydraTheme.label.copyWith(color: HydraTheme.accent)),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

// ── Local widgets ───────────────────────────────────────────

class _NothingToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NothingToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: HydraTheme.background,
          border: Border.all(
            color: value ? HydraTheme.accent : HydraTheme.borderStrong,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            color: value
                ? HydraTheme.accent
                : HydraTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _SettingRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: HydraTheme.label),
        trailing,
      ],
    );
  }
}

class _UnderlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;
  final ValueChanged<String>? onChanged;

  const _UnderlineField({
    required this.label,
    required this.controller,
    required this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HydraTheme.label),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: HydraTheme.dataLarge.copyWith(fontSize: 26),
                cursorColor: HydraTheme.textPrimary,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                suffix,
                style: HydraTheme.label.copyWith(
                  color: HydraTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ExportButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HydraTheme.background,
          border: Border.all(color: HydraTheme.borderStrong, width: 1),
        ),
        child: Text(
          label,
          style: HydraTheme.body.copyWith(
            fontSize: 12,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

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

              // Data section
              _SectionTitle(title: 'Données'),
              const SizedBox(height: 12),
              _SettingTile(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ExportButton(
                        icon: Icons.table_chart_outlined,
                        label: 'Exporter les données (CSV)',
                        color: HydraTheme.accent,
                        onPressed: _exportCsv,
                      ),
                      const SizedBox(height: 10),
                      _ExportButton(
                        icon: Icons.backup_outlined,
                        label: 'Exporter les données (JSON)',
                        color: HydraTheme.primary,
                        onPressed: _exportJson,
                      ),
                      const SizedBox(height: 10),
                      _ExportButton(
                        icon: Icons.upload_file_outlined,
                        label: 'Importer un backup (JSON)',
                        color: HydraTheme.warning,
                        onPressed: _importJson,
                      ),
                    ],
                  ),
                ),
              ),

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

  // ── Export / Import handlers ─────────────────────────────────

  final ExportService _exportService = ExportService();

  Future<void> _exportCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _exportService.shareCsv();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Export CSV prêt — choisis une app pour partager.'),
          backgroundColor: HydraTheme.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Échec de l\'export CSV : $e'),
          backgroundColor: HydraTheme.danger,
        ),
      );
    }
  }

  Future<void> _exportJson() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _exportService.shareJson();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Backup JSON généré — choisis une app pour le partager.'),
          backgroundColor: HydraTheme.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Échec du backup JSON : $e'),
          backgroundColor: HydraTheme.danger,
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
            'Import réussi — ${summary.waterLogs} verre(s), '
            '${summary.drinkLogs} boisson(s) chargée(s).',
          ),
          backgroundColor: HydraTheme.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Échec de l\'import : $e'),
          backgroundColor: HydraTheme.danger,
        ),
      );
    }
  }

  Future<bool?> _confirmImport() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HydraTheme.surfaceLight,
        title: const Text(
          'Importer un backup ?',
          style: TextStyle(color: HydraTheme.textPrimary),
        ),
        content: const Text(
          'Cette action va REMPLACER toutes tes données actuelles '
          '(verres bus, boissons, profil, objectif) par celles du backup.\n\n'
          'Pense à exporter un backup récent avant de continuer.',
          style: TextStyle(color: HydraTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: HydraTheme.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: HydraTheme.warning,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continuer'),
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
        backgroundColor: HydraTheme.surfaceLight,
        title: const Text(
          'Colle le JSON du backup',
          style: TextStyle(color: HydraTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Astuce : utilise « Exporter les données (JSON) » sur '
                'l\'appareil source, sauvegarde le fichier, puis colle '
                'son contenu ici.',
                style: TextStyle(color: HydraTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 12,
                style: const TextStyle(
                  color: HydraTheme.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                decoration: const InputDecoration(
                  hintText: '{ "app": "hydra", ... }',
                  hintStyle: TextStyle(color: HydraTheme.textSecondary),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(color: HydraTheme.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: TextStyle(color: HydraTheme.textPrimary, fontSize: 14),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
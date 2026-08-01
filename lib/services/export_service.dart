import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/drink_ratio.dart';
import '../models/user_profile.dart';
import '../models/water_log.dart';
import 'storage_service.dart';

/// Export & import of Hydra data — CSV (logs) and JSON (full backup).
class ExportService {
  ExportService({StorageService? storage})
      : _storage = storage ?? StorageService();

  final StorageService _storage;

  // ── CSV ─────────────────────────────────────────────────────

  /// Build a CSV string of every water log and drink log.
  ///
  /// Columns: date,type,amount,source
  ///   date   → ISO 8601 timestamp (UTC offset preserved)
  ///   type   → `water` or the drink id (e.g. `coca`, `coffee`)
  ///   amount → millilitres (drink logs use the raw drink volume)
  ///   source → for water: `tap`/`widget`/`reminder`; for drinks: the
  ///            drink name, or `compensated:<name>` once marked paid back
  String exportToCsv() {
    final waterLogs = _storage.getWaterLogs();
    final drinkLogs = _storage.getDrinkLogs();

    final rows = <List<String>>[];
    rows.add(const ['date', 'type', 'amount', 'source']);

    for (final w in waterLogs) {
      rows.add([
        w.timestamp.toIso8601String(),
        'water',
        w.amountMl.toString(),
        w.source.name,
      ]);
    }

    for (final d in drinkLogs) {
      final drink = DrinkPresets.byId(d.drinkTypeId);
      final name = drink?.name ?? d.drinkTypeId;
      rows.add([
        d.timestamp.toIso8601String(),
        d.drinkTypeId,
        d.volumeMl.toString(),
        d.compensated ? 'compensated:$name' : name,
      ]);
    }

    return const _CsvEncoder().encode(rows);
  }

  /// Write the CSV to a file in the temp dir and trigger the OS share sheet.
  /// Returns the produced file for callers that want to log/display it.
  Future<File> shareCsv() async {
    final csv = exportToCsv();
    final dir = await getTemporaryDirectory();
    final stamp = _timestampForFilename();
    final file = File('${dir.path}/hydra_export_$stamp.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv', name: file.uri.pathSegments.last)],
      subject: 'Hydra — données CSV',
      text: 'Export CSV Hydra',
    );
    return file;
  }

  // ── JSON ────────────────────────────────────────────────────

  /// Full snapshot — water logs, drink logs, profile, daily goal.
  Map<String, dynamic> _buildJsonPayload() {
    return {
      'app': 'hydra',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'dailyGoalMl': _storage.getDailyGoalMl(),
      'profile': _storage.getProfile().toJson(),
      'waterLogs':
          _storage.getWaterLogs().map((e) => e.toJson()).toList(),
      'drinkLogs':
          _storage.getDrinkLogs().map((e) => e.toJson()).toList(),
    };
  }

  String exportToJson() {
    return const JsonEncoder.withIndent('  ').convert(_buildJsonPayload());
  }

  /// Write the JSON backup to a file and trigger the OS share sheet.
  Future<File> shareJson() async {
    final json = exportToJson();
    final dir = await getTemporaryDirectory();
    final stamp = _timestampForFilename();
    final file = File('${dir.path}/hydra_backup_$stamp.json');
    await file.writeAsString(json);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json', name: file.uri.pathSegments.last)],
      subject: 'Hydra — backup JSON',
      text: 'Backup Hydra',
    );
    return file;
  }

  // ── Import ──────────────────────────────────────────────────

  /// Restore from a JSON backup. Throws [FormatException] on invalid input,
  /// or [StateError] if the payload is recognised JSON but not a Hydra backup.
  Future<ImportSummary> importFromJson(String raw) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e) {
      throw const FormatException('Fichier JSON invalide.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Le fichier ne contient pas un objet JSON.');
    }
    if (decoded['app'] != 'hydra') {
      throw const FormatException(
          'Ce fichier n\'est pas une sauvegarde Hydra.');
    }

    final waterRaw = decoded['waterLogs'];
    final drinkRaw = decoded['drinkLogs'];
    final profileRaw = decoded['profile'];
    final goalRaw = decoded['dailyGoalMl'];

    final waterLogs = <WaterLog>[];
    if (waterRaw is List) {
      for (final entry in waterRaw) {
        if (entry is Map<String, dynamic>) {
          waterLogs.add(WaterLog.fromJson(entry));
        }
      }
    }
    final drinkLogs = <DrinkLog>[];
    if (drinkRaw is List) {
      for (final entry in drinkRaw) {
        if (entry is Map<String, dynamic>) {
          drinkLogs.add(DrinkLog.fromJson(entry));
        }
      }
    }

    await _storage.replaceWaterLogs(waterLogs);
    await _storage.replaceDrinkLogs(drinkLogs);

    if (profileRaw is Map<String, dynamic>) {
      await _storage.saveProfile(UserProfile.fromJson(profileRaw));
    }
    if (goalRaw is int) {
      await _storage.setDailyGoalMl(goalRaw);
    }

    return ImportSummary(
      waterLogs: waterLogs.length,
      drinkLogs: drinkLogs.length,
      hadProfile: profileRaw is Map<String, dynamic>,
      hadGoal: goalRaw is int,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  String _timestampForFilename() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}_${two(n.hour)}${two(n.minute)}${two(n.second)}';
  }
}

/// Minimal CSV row encoder — wraps fields containing comma/quote/newline.
class _CsvEncoder {
  const _CsvEncoder();

  String encode(List<List<String>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.write(row.map(_escape).join(','));
      buffer.write('\r\n');
    }
    return buffer.toString();
  }

  String _escape(String field) {
    final needsQuotes = field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r');
    if (!needsQuotes) return field;
    final escaped = field.replaceAll('"', '""');
    return '"$escaped"';
  }
}

/// Summary of what an import wrote — handy for a snackbar message.
class ImportSummary {
  final int waterLogs;
  final int drinkLogs;
  final bool hadProfile;
  final bool hadGoal;

  const ImportSummary({
    required this.waterLogs,
    required this.drinkLogs,
    required this.hadProfile,
    required this.hadGoal,
  });
}

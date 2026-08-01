import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_log.dart';
import '../models/drink_ratio.dart';
import '../models/user_profile.dart';

/// Central storage service using SharedPreferences + JSON encoding.
class StorageService {
  static const _waterLogsKey = 'hydra_water_logs';
  static const _drinkLogsKey = 'hydra_drink_logs';
  static const _profileKey = 'hydra_profile';
  static const _dailyGoalKey = 'hydra_daily_goal_ml';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Water Logs ──────────────────────────────────────────────

  List<WaterLog> getWaterLogs() {
    final raw = _prefs.getString(_waterLogsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => WaterLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addWaterLog(WaterLog log) async {
    final logs = getWaterLogs();
    logs.add(log);
    await _prefs.setString(_waterLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  Future<void> removeWaterLog(String id) async {
    final logs = getWaterLogs().where((e) => e.id != id).toList();
    await _prefs.setString(_waterLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  Future<void> clearTodayWaterLogs() async {
    final now = DateTime.now();
    final logs = getWaterLogs().where((e) {
      final t = e.timestamp;
      return !(t.year == now.year && t.month == now.month && t.day == now.day);
    }).toList();
    await _prefs.setString(_waterLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  // ── Drink Logs ──────────────────────────────────────────────

  List<DrinkLog> getDrinkLogs() {
    final raw = _prefs.getString(_drinkLogsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => DrinkLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addDrinkLog(DrinkLog log) async {
    final logs = getDrinkLogs();
    logs.add(log);
    await _prefs.setString(_drinkLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  Future<void> markDrinkCompensated(String id) async {
    final logs = getDrinkLogs();
    for (final l in logs) {
      if (l.id == id) {
        final idx = logs.indexOf(l);
        logs[idx] = DrinkLog(
          id: l.id,
          timestamp: l.timestamp,
          drinkTypeId: l.drinkTypeId,
          volumeMl: l.volumeMl,
          waterRatio: l.waterRatio,
          compensated: true,
        );
        break;
      }
    }
    await _prefs.setString(_drinkLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  // ── User Profile ────────────────────────────────────────────

  UserProfile getProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) return const UserProfile();
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // ── Daily Goal ──────────────────────────────────────────────

  int getDailyGoalMl() {
    return _prefs.getInt(_dailyGoalKey) ?? 2500;
  }

  Future<void> setDailyGoalMl(int ml) async {
    await _prefs.setInt(_dailyGoalKey, ml);
  }

  // ── Bulk replace (used by import) ───────────────────────────

  Future<void> replaceWaterLogs(List<WaterLog> logs) async {
    await _prefs.setString(
      _waterLogsKey,
      jsonEncode(logs.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> replaceDrinkLogs(List<DrinkLog> logs) async {
    await _prefs.setString(
      _drinkLogsKey,
      jsonEncode(logs.map((e) => e.toJson()).toList()),
    );
  }

  // ── Today helpers ───────────────────────────────────────────

  int getTodayWaterMl() {
    final now = DateTime.now();
    return getWaterLogs()
        .where((e) =>
            e.timestamp.year == now.year &&
            e.timestamp.month == now.month &&
            e.timestamp.day == now.day)
        .fold(0, (sum, e) => sum + e.amountMl);
  }

  List<WaterLog> getTodayWaterLogs() {
    final now = DateTime.now();
    return getWaterLogs()
        .where((e) =>
            e.timestamp.year == now.year &&
            e.timestamp.month == now.month &&
            e.timestamp.day == now.day)
        .toList();
  }

  List<DrinkLog> getTodayDrinkLogs() {
    final now = DateTime.now();
    return getDrinkLogs()
        .where((e) =>
            e.timestamp.year == now.year &&
            e.timestamp.month == now.month &&
            e.timestamp.day == now.day)
        .toList();
  }

  /// Total water debt from uncompensated drinks today.
  int getTodayWaterDebtMl() {
    return getTodayDrinkLogs()
        .where((e) => !e.compensated)
        .fold(0, (sum, e) => sum + e.requiredWaterMl);
  }

  /// Last 7 days water totals (oldest first).
  List<DailyTotal> getLast7Days() {
    final now = DateTime.now();
    final result = <DailyTotal>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final total = getWaterLogs()
          .where((e) =>
              e.timestamp.year == day.year &&
              e.timestamp.month == day.month &&
              e.timestamp.day == day.day)
          .fold(0, (sum, e) => sum + e.amountMl);
      result.add(DailyTotal(date: day, totalMl: total));
    }
    return result;
  }
}

class DailyTotal {
  final DateTime date;
  final int totalMl;
  DailyTotal({required this.date, required this.totalMl});
}
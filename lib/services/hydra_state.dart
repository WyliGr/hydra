import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/water_log.dart';
import '../models/drink_ratio.dart';
import '../models/user_profile.dart';
import '../models/streak.dart';

/// Central app state — hydration tracking + drink ratio regulation.
class HydraState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool _ready = false;
  int _todayWaterMl = 0;
  int _dailyGoalMl = 2500;
  int _waterDebtMl = 0;
  List<DrinkLog> _todayDrinks = [];
  List<DailyTotal> _last7Days = [];
  UserProfile _profile = const UserProfile();
  Streak _streak = Streak.empty;

  bool get ready => _ready;
  int get todayWaterMl => _todayWaterMl;
  int get dailyGoalMl => _dailyGoalMl;
  int get waterDebtMl => _waterDebtMl;
  List<DrinkLog> get todayDrinks => _todayDrinks;
  List<DailyTotal> get last7Days => _last7Days;
  UserProfile get profile => _profile;
  int get currentStreak => _streak.currentStreak;
  int get longestStreak => _streak.longestStreak;
  List<bool> get streakHistory => _streak.history;

  /// Total goal = base goal + water debt from uncompensated drinks.
  int get effectiveGoalMl => _dailyGoalMl + _waterDebtMl;
  double get progress => _dailyGoalMl == 0 ? 0 : (_todayWaterMl / effectiveGoalMl).clamp(0.0, 1.0);
  double get baseProgress => _dailyGoalMl == 0 ? 0 : (_todayWaterMl / _dailyGoalMl).clamp(0.0, 1.0);
  int get remainingMl => (effectiveGoalMl - _todayWaterMl).clamp(0, effectiveGoalMl);

  Future<void> init() async {
    await _storage.init();
    _refresh();
    _ready = true;
    notifyListeners();
  }

  void _refresh() {
    _todayWaterMl = _storage.getTodayWaterMl();
    _dailyGoalMl = _storage.getDailyGoalMl();
    _waterDebtMl = _storage.getTodayWaterDebtMl();
    _todayDrinks = _storage.getTodayDrinkLogs();
    _last7Days = _storage.getLast7Days();
    _profile = _storage.getProfile();
    _streak = _storage.getStreakData();
  }

  // ── Water actions ───────────────────────────────────────────

  Future<void> addWater(int ml, {LogSource source = LogSource.tap}) async {
    final log = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      amountMl: ml,
      source: source,
    );
    await _storage.addWaterLog(log);
    _refresh();
    notifyListeners();
  }

  Future<void> removeLastWaterLog() async {
    final todayLogs = _storage.getTodayWaterLogs();
    if (todayLogs.isEmpty) return;
    await _storage.removeWaterLog(todayLogs.last.id);
    _refresh();
    notifyListeners();
  }

  // ── Drink actions ───────────────────────────────────────────

  Future<void> logDrink(DrinkType drink) async {
    final log = DrinkLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      drinkTypeId: drink.id,
      volumeMl: drink.volumeMl,
      waterRatio: drink.waterRatio,
    );
    await _storage.addDrinkLog(log);
    _refresh();
    notifyListeners();
  }

  Future<void> compensateDrink(String drinkLogId) async {
    await _storage.markDrinkCompensated(drinkLogId);
    _refresh();
    notifyListeners();
  }

  // ── Settings ────────────────────────────────────────────────

  Future<void> setDailyGoal(int ml) async {
    await _storage.setDailyGoalMl(ml);
    _refresh();
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _storage.saveProfile(profile);
    if (profile.autoGoal) {
      await _storage.setDailyGoalMl(profile.recommendedDailyMl);
    }
    _refresh();
    notifyListeners();
  }
}
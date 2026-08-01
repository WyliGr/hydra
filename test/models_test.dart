import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/models/water_log.dart';
import 'package:hydra/models/drink_ratio.dart';
import 'package:hydra/models/user_profile.dart';

void main() {
  group('WaterLog', () {
    test('serializes to JSON and back', () {
      final log = WaterLog(
        id: 'test1',
        timestamp: DateTime(2026, 8, 1, 10, 30),
        amountMl: 250,
        source: LogSource.tap,
      );
      final json = log.toJson();
      final restored = WaterLog.fromJson(json);

      expect(restored.id, 'test1');
      expect(restored.amountMl, 250);
      expect(restored.source, LogSource.tap);
    });
  });

  group('DrinkPresets', () {
    test('Coca ratio is 2:1', () {
      final coca = DrinkPresets.byId('coca')!;
      expect(coca.waterRatio, 2.0);
      expect(coca.requiredWaterMl, 660); // 330 * 2
    });

    test('Red Bull ratio is 3:1', () {
      final rb = DrinkPresets.byId('redbull')!;
      expect(rb.waterRatio, 3.0);
      expect(rb.requiredWaterMl, 750); // 250 * 3
    });

    test('Holy ratio is 3:1', () {
      final holy = DrinkPresets.byId('holy')!;
      expect(holy.waterRatio, 3.0);
      expect(holy.requiredWaterMl, 990); // 330 * 3
    });

    test('unknown id returns null', () {
      expect(DrinkPresets.byId('nonexistent'), isNull);
    });
  });

  group('UserProfile', () {
    test('recommended daily intake is 35ml/kg', () {
      const profile = UserProfile(weightKg: 70);
      expect(profile.recommendedDailyMl, 2450); // 70 * 35
    });

    test('copyWith preserves unchanged fields', () {
      const profile = UserProfile(weightKg: 80, wakeHour: 6);
      final updated = profile.copyWith(weightKg: 75);
      expect(updated.weightKg, 75);
      expect(updated.wakeHour, 6); // unchanged
    });
  });

  group('DrinkLog', () {
    test('requiredWaterMl calculates correctly', () {
      final log = DrinkLog(
        id: 'd1',
        timestamp: DateTime.now(),
        drinkTypeId: 'coca',
        volumeMl: 330,
        waterRatio: 2.0,
      );
      expect(log.requiredWaterMl, 660);
      expect(log.compensated, false);
    });
  });
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preset accent color swatch — a single immutable color + label pair.
class AccentPreset {
  final String name;
  final Color color;
  final Color dimColor;

  const AccentPreset({
    required this.name,
    required this.color,
    required this.dimColor,
  });
}

/// Persists the user's accent color selection in [SharedPreferences]
/// and exposes the preset list. The selected color is applied to
/// [HydraTheme] at boot and whenever the user picks a new swatch.
class AccentColorService {
  static const String _prefsKey = 'hydra_accent_color';

  /// Nothing Red is the brand default.
  static const int defaultIndex = 0;

  /// The hand-tuned preset palette. Order is part of the storage
  /// contract — appending new entries is safe, but do not reorder.
  static const List<AccentPreset> presets = [
    AccentPreset(
      name: 'NOTHING RED',
      color: Color(0xFFFF2D2D),
      dimColor: Color(0xFFB81E1E),
    ),
    AccentPreset(
      name: 'ELECTRIC BLUE',
      color: Color(0xFF007AFF),
      dimColor: Color(0xFF004EA8),
    ),
    AccentPreset(
      name: 'MATRIX GREEN',
      color: Color(0xFF00FF41),
      dimColor: Color(0xFF00A829),
    ),
    AccentPreset(
      name: 'SOLAR AMBER',
      color: Color(0xFFFFB703),
      dimColor: Color(0xFFA87800),
    ),
    AccentPreset(
      name: 'DEEP PURPLE',
      color: Color(0xFF9D4EDD),
      dimColor: Color(0xFF6B2BA0),
    ),
    AccentPreset(
      name: 'HOT PINK',
      color: Color(0xFFFF006E),
      dimColor: Color(0xFFA80049),
    ),
  ];

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Currently selected preset index. Falls back to [defaultIndex] when
  /// the key is missing or points at an out-of-range value (e.g. after
  /// we add a new swatch and an old build wrote index 5).
  static int getAccentIndex() {
    final v = _prefs?.getInt(_prefsKey) ?? defaultIndex;
    if (v < 0 || v >= presets.length) return defaultIndex;
    return v;
  }

  /// Look up the selected [Color], or the default preset's color.
  static Color getAccentColor() =>
      presets[getAccentIndex()].color;

  /// Dim companion of the selected color.
  static Color getAccentDimColor() =>
      presets[getAccentIndex()].dimColor;

  static Future<void> setAccentIndex(int index) async {
    if (index < 0 || index >= presets.length) return;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_prefsKey, index);
  }
}

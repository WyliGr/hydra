import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Quick-add water buttons (25cl, 33cl, 50cl).
class QuickAddButtons extends StatelessWidget {
  final void Function(int ml) onAdd;

  const QuickAddButtons({super.key, required this.onAdd});

  static const _options = [
    (ml: 250, label: '25cl', icon: Icons.water_drop_outlined),
    (ml: 330, label: '33cl', icon: Icons.local_drink_outlined),
    (ml: 500, label: '50cl', icon: Icons.water_drop),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _options.map((o) {
        return GestureDetector(
          onTap: () => onAdd(o.ml),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: HydraTheme.surfaceLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: HydraTheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(o.icon, color: HydraTheme.primary, size: 28),
                const SizedBox(height: 6),
                Text(
                  o.label,
                  style: const TextStyle(
                    color: HydraTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
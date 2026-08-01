import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Quick-add water buttons — three text-only tiles, 1px borders.
/// Nothing OS: no icons, no fills, industrial labels in Space Mono.
class QuickAddButtons extends StatelessWidget {
  final void Function(int ml) onAdd;

  const QuickAddButtons({super.key, required this.onAdd});

  static const _options = [
    (ml: 250, label: '250ML'),
    (ml: 330, label: '330ML'),
    (ml: 500, label: '500ML'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((o) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onAdd(o.ml),
              child: Container(
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HydraTheme.surface,
                  border: Border.all(
                    color: HydraTheme.borderStrong,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      o.label,
                      style: HydraTheme.dataMedium.copyWith(
                        color: HydraTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ADD',
                      style: HydraTheme.label.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

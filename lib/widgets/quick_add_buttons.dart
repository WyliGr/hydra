import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Quick-add water buttons — three text-only tiles, 1px borders.
/// Nothing OS: no icons, no fills, industrial labels in Space Mono.
/// Briefly flashes the accent border on tap as user feedback.
class QuickAddButtons extends StatefulWidget {
  final void Function(int ml) onAdd;

  const QuickAddButtons({super.key, required this.onAdd});

  @override
  State<QuickAddButtons> createState() => _QuickAddButtonsState();
}

class _QuickAddButtonsState extends State<QuickAddButtons> {
  int? _flashedIndex;

  void _flashTap(int index) {
    widget.onAdd(_options[index].ml);
    setState(() => _flashedIndex = index);
    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      if (_flashedIndex == index) {
        setState(() => _flashedIndex = null);
      }
    });
  }

  static const _options = [
    (ml: 250, label: '250ML'),
    (ml: 330, label: '330ML'),
    (ml: 500, label: '500ML'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_options.length, (i) {
        final o = _options[i];
        final flashed = _flashedIndex == i;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _flashTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HydraTheme.surface,
                  border: Border.all(
                    color: flashed
                        ? HydraTheme.accent
                        : HydraTheme.borderStrong,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      o.label,
                      style: HydraTheme.dataMedium.copyWith(
                        color: flashed
                            ? HydraTheme.accent
                            : HydraTheme.textPrimary,
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
      }),
    );
  }
}

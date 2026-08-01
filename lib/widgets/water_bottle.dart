import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Animated water bottle that fills up based on progress.
class WaterBottle extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final int currentMl;
  final int goalMl;
  final int debtMl;

  const WaterBottle({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    this.debtMl = 0,
  });

  @override
  State<WaterBottle> createState() => _WaterBottleState();
}

class _WaterBottleState extends State<WaterBottle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fillAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.value = widget.progress;
  }

  @override
  void didUpdateWidget(WaterBottle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animController.animateTo(widget.progress);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _waterColor {
    if (widget.debtMl > 0 && widget.currentMl < widget.goalMl) {
      return HydraTheme.warning; // amber when in debt
    }
    if (widget.progress >= 1.0) {
      return HydraTheme.success; // green when complete
    }
    return HydraTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bottle outline
          CustomPaint(
            size: const Size(180, 280),
            painter: _BottlePainter(
              fillProgress: _fillAnimation.value,
              waterColor: _waterColor,
            ),
          ),
          // ML text overlay
          Positioned(
            top: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(widget.progress * 100).round()}%',
                  style: const TextStyle(
                    color: HydraTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmtMl(widget.currentMl)} / ${_fmtMl(widget.goalMl + widget.debtMl)}',
                  style: const TextStyle(
                    color: HydraTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.debtMl > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: HydraTheme.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${_fmtMl(widget.debtMl)} dette',
                      style: const TextStyle(
                        color: HydraTheme.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtMl(int ml) {
    if (ml >= 1000) {
      final l = ml / 1000;
      return '${l.toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }
}

class _BottlePainter extends CustomPainter {
  final double fillProgress;
  final Color waterColor;

  _BottlePainter({required this.fillProgress, required this.waterColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    // Bottle path — narrow neck, wide body
    final bottlePath = Path()
      ..moveTo(centerX - 25, 10) // top left of cap area
      ..lineTo(centerX - 25, 35) // neck left
      ..quadraticBezierTo(centerX - 35, 50, centerX - 45, 65) // shoulder
      ..lineTo(centerX - 45, h - 30) // body left
      ..quadraticBezierTo(centerX - 45, h - 10, centerX - 25, h - 10) // bottom left curve
      ..lineTo(centerX + 25, h - 10) // bottom right
      ..quadraticBezierTo(centerX + 45, h - 10, centerX + 45, h - 30) // bottom right curve
      ..lineTo(centerX + 45, 65) // body right
      ..quadraticBezierTo(centerX + 35, 50, centerX + 25, 35) // shoulder right
      ..lineTo(centerX + 25, 10) // neck right
      ..close();

    // Bottle outline
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = HydraTheme.textSecondary;
    canvas.drawPath(bottlePath, outlinePaint);

    // Clip to bottle shape for water fill
    canvas.save();
    canvas.clipPath(bottlePath);

    // Water fill from bottom
    final waterHeight = (h - 20) * fillProgress;
    final waterTop = h - 10 - waterHeight;

    final waterPath = Path()
      ..moveTo(0, h - 10)
      ..lineTo(w, h - 10)
      ..lineTo(w, waterTop)
      ..lineTo(0, waterTop)
      ..close();

    final waterPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = waterColor.withValues(alpha: 0.7);
    canvas.drawPath(waterPath, waterPaint);

    // Wavy water surface
    if (fillProgress > 0.01) {
      final wavePath = Path()
        ..moveTo(0, waterTop)
        ..quadraticBezierTo(w * 0.25, waterTop - 6, w * 0.5, waterTop)
        ..quadraticBezierTo(w * 0.75, waterTop + 6, w, waterTop)
        ..lineTo(w, waterTop + 15)
        ..lineTo(0, waterTop + 15)
        ..close();

      final wavePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = waterColor.withValues(alpha: 0.3);
      canvas.drawPath(wavePath, wavePaint);
    }

    canvas.restore();

    // Cap
    final capPath = Path()
      ..moveTo(centerX - 22, 5)
      ..lineTo(centerX - 22, 18)
      ..lineTo(centerX + 22, 18)
      ..lineTo(centerX + 22, 5)
      ..close();
    final capPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = HydraTheme.primaryDark;
    canvas.drawPath(capPath, capPaint);
  }

  @override
  bool shouldRepaint(_BottlePainter oldDelegate) =>
      oldDelegate.fillProgress != fillProgress ||
      oldDelegate.waterColor != waterColor;
}
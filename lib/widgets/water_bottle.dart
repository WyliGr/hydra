import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Wireframe water bottle with a dot-matrix fill — Nothing OS aesthetic.
/// Dots become denser as progress grows; at 100% the dots turn red.
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fillAnimation,
      builder: (context, _) {
        return SizedBox(
          width: 180,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(180, 280),
                painter: _BottleDotPainter(
                  fillProgress: _fillAnimation.value,
                  debtMl: widget.debtMl,
                  currentMl: widget.currentMl,
                  goalMl: widget.goalMl,
                ),
              ),
              // Data overlay
              Positioned(
                top: 130,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _fmtMl(widget.currentMl),
                      style: HydraTheme.dataLarge.copyWith(
                        color: widget.progress >= 1.0
                            ? HydraTheme.accent
                            : HydraTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '/ ${_fmtMl(widget.goalMl + widget.debtMl)}',
                      style: HydraTheme.dataSmall.copyWith(
                        color: HydraTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmtMl(int ml) {
    if (ml >= 1000) {
      final l = ml / 1000;
      return '${l.toStringAsFixed(1)}L';
    }
    return '${ml}ML';
  }
}

class _BottleDotPainter extends CustomPainter {
  final double fillProgress;
  final int debtMl;
  final int currentMl;
  final int goalMl;

  _BottleDotPainter({
    required this.fillProgress,
    required this.debtMl,
    required this.currentMl,
    required this.goalMl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    // Bottle path — narrow neck, wide body (wireframe only)
    final bottlePath = Path()
      ..moveTo(centerX - 22, 8)
      ..lineTo(centerX - 22, 32)
      ..quadraticBezierTo(centerX - 32, 48, centerX - 42, 64)
      ..lineTo(centerX - 42, h - 30)
      ..quadraticBezierTo(centerX - 42, h - 12, centerX - 24, h - 12)
      ..lineTo(centerX + 24, h - 12)
      ..quadraticBezierTo(centerX + 42, h - 12, centerX + 42, h - 30)
      ..lineTo(centerX + 42, 64)
      ..quadraticBezierTo(centerX + 32, 48, centerX + 22, 32)
      ..lineTo(centerX + 22, 8)
      ..close();

    // ── 1) Dot matrix fill (clipped to bottle shape) ──────────
    canvas.save();
    canvas.clipPath(bottlePath);

    final fillHeight = (h - 20) * fillProgress.clamp(0.0, 1.0);
    final fillTopY = h - 12 - fillHeight;

    final dotSize = 2.0;
    final spacing = 7.0;
    final isComplete = fillProgress >= 0.999;

    // Faint background dot pattern (entire bottle body) — very subtle
    final bgPaint = Paint()..color = HydraTheme.border.withValues(alpha: 0.6);
    for (double y = 70; y <= h - 14; y += spacing) {
      for (double x = centerX - 38; x <= centerX + 38; x += spacing) {
        if (y < 64) continue;
        canvas.drawCircle(Offset(x, y), dotSize * 0.6, bgPaint);
      }
    }

    // Foreground fill dots: only draw those within the fill zone.
    final dotColor = isComplete ? HydraTheme.accent : HydraTheme.textPrimary;
    final dotPaint = Paint()..color = dotColor;

    final left = centerX - 42 + 4;
    final right = centerX + 42 - 4;
    final top = 70.0; // below the neck
    final bottom = h - 14;

    for (double y = top; y <= bottom; y += spacing) {
      final inFillZone = y >= fillTopY;
      for (double x = left; x <= right; x += spacing) {
        if (y < 64) continue;
        if (!inFillZone) continue;
        canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
      }
    }

    canvas.restore();

    // ── 2) Wireframe outline (1.5px white) ────────────────────
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = HydraTheme.textPrimary;
    canvas.drawPath(bottlePath, outlinePaint);

    // ── 3) Cap outline (no fill) ───────────────────────────────
    final capRect = Rect.fromLTRB(centerX - 20, 4, centerX + 20, 16);
    final capPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = HydraTheme.textPrimary;
    canvas.drawRect(capRect, capPaint);

    // Tick marks (industrial scale)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = HydraTheme.textTertiary;
    for (int i = 1; i < 4; i++) {
      final ty = h - 12 - ((h - 80) * i / 4);
      canvas.drawLine(
        Offset(centerX + 44, ty),
        Offset(centerX + 50, ty),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BottleDotPainter oldDelegate) =>
      oldDelegate.fillProgress != fillProgress ||
      oldDelegate.debtMl != debtMl ||
      oldDelegate.currentMl != currentMl ||
      oldDelegate.goalMl != goalMl;
}

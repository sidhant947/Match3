import 'dart:math';
import 'package:flutter/material.dart';
import 'package:match3/domain/models/gem.dart';

class CustomGemPainter extends CustomPainter {
  const CustomGemPainter({
    required this.gemType,
    required this.special,
    required this.isSelected,
    required this.isMatched,
    required this.isBlocker,
    required this.isIce,
  });

  final GemType gemType;
  final SpecialGem special;
  final bool isSelected;
  final bool isMatched;
  final bool isBlocker;
  final bool isIce;

  static const Map<GemType, String> _fruitEmojis = {
    GemType.circle: '🍎',
    GemType.diamond: '🫐',
    GemType.square: '🍐',
    GemType.triangle: '🍋',
    GemType.hexagon: '🍇',
    GemType.star: '🍊',
    GemType.pentagon: '🍒',
    GemType.heart: '🍉',
    GemType.oval: '🍌',
    GemType.rhombus: '🍍',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = min(w, h) / 2 * 0.95;

    if (isBlocker) {
      _paintBlocker(canvas, w, h, cx, cy, r);
      return;
    }

    final emoji = _fruitEmojis[gemType] ?? '🍎';
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: r * 1.55),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    if (special != SpecialGem.none) {
      _paintSpecialIndicator(canvas, cx, cy, r);
    }

    if (isMatched) {
      final matchPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(cx, cy), r + 2, matchPaint);
    }

    if (isIce) {
      _paintIceOverlay(canvas, w, h, r);
    }
  }

  void _paintBlocker(Canvas canvas, double w, double h, double cx, double cy, double r) {
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8E9AA6), Color(0xFF5A6673), Color(0xFF353D45)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 1.6, height: r * 1.6),
        const Radius.circular(12),
      ));
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = const Color(0xFF2C3238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, borderPaint);

    final crackPaint = Paint()
      ..color = const Color(0xFF1E2226)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - r * 0.4, cy - r * 0.4), Offset(cx - r * 0.1, cy - r * 0.1), crackPaint);
    canvas.drawLine(Offset(cx - r * 0.1, cy - r * 0.1), Offset(cx - r * 0.5, cy + r * 0.2), crackPaint);
    canvas.drawLine(Offset(cx + r * 0.3, cy - r * 0.2), Offset(cx + r * 0.1, cy + r * 0.3), crackPaint);
  }

  void _paintSpecialIndicator(Canvas canvas, double cx, double cy, double r) {
    final indicatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white;

    switch (special) {
      case SpecialGem.stripedH:
        for (int i = -1; i <= 1; i += 2) {
          final y = cy + i * r * 0.35;
          canvas.drawLine(Offset(cx - r * 0.6, y), Offset(cx + r * 0.6, y), indicatorPaint);
        }
        break;
      case SpecialGem.stripedV:
        for (int i = -1; i <= 1; i += 2) {
          final x = cx + i * r * 0.35;
          canvas.drawLine(Offset(x, cy - r * 0.6), Offset(x, cy + r * 0.6), indicatorPaint);
        }
        break;
      case SpecialGem.wrapped:
        final wrapPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        canvas.drawCircle(Offset(cx, cy), r * 0.7, wrapPaint);
        break;
      case SpecialGem.colorBomb:
        final bombPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.95)
          ..style = PaintingStyle.fill;
        final starPath = Path();
        for (int i = 0; i < 8; i++) {
          final angle = (i * 45) * pi / 180;
          final radius = i.isEven ? r * 0.35 : r * 0.15;
          final px = cx + radius * cos(angle);
          final py = cy + radius * sin(angle);
          if (i == 0) {
            starPath.moveTo(px, py);
          } else {
            starPath.lineTo(px, py);
          }
        }
        starPath.close();
        canvas.drawPath(starPath, bombPaint);
        break;
      case SpecialGem.none:
        break;
    }
  }

  void _paintIceOverlay(Canvas canvas, double w, double h, double r) {
    final rect = Rect.fromCircle(center: Offset(w / 2, h / 2), radius: r);
    final icePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyanAccent.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.25),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawCircle(Offset(w / 2, h / 2), r + 2, icePaint);

    final iceBorderPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(w / 2, h / 2), r + 2, iceBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomGemPainter oldDelegate) {
    return oldDelegate.gemType != gemType ||
        oldDelegate.special != special ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isMatched != isMatched ||
        oldDelegate.isBlocker != isBlocker ||
        oldDelegate.isIce != isIce;
  }
}

class GemWidget extends StatelessWidget {
  const GemWidget({
    super.key,
    required this.gemType,
    this.special = SpecialGem.none,
    this.isSelected = false,
    this.isMatched = false,
    this.isBlocker = false,
    this.isIce = false,
  });

  final GemType gemType;
  final SpecialGem special;
  final bool isSelected;
  final bool isMatched;
  final bool isBlocker;
  final bool isIce;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CustomGemPainter(
        gemType: gemType,
        special: special,
        isSelected: isSelected,
        isMatched: isMatched,
        isBlocker: isBlocker,
        isIce: isIce,
      ),
    );
  }
}

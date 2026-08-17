import 'dart:math';
import 'package:flutter/material.dart';
import 'package:match3/domain/models/gem.dart';

class CustomGemPainter extends CustomPainter {
  const CustomGemPainter({
    required this.gemType,
  });

  final GemType gemType;

  static const Map<GemType, String> _fruitEmojis = {
    GemType.circle: '🍎',
    GemType.diamond: '🫐',
    GemType.square: '🍐',
    GemType.triangle: '🍋',
    GemType.hexagon: '🍇',
    GemType.star: '🍊',
    GemType.pentagon: '🍒',
    GemType.heart: '🍉',
    GemType.oval: '🍋',
    GemType.rhombus: '🍍',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = min(w, h) / 2 * 0.95;

    final emoji = _fruitEmojis[gemType] ?? '🍎';
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: r * 1.55,
          fontFamilyFallback: const [
            'Noto Color Emoji',
            'Apple Color Emoji',
            'Segoe UI Emoji',
            'JoyPixels',
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomGemPainter oldDelegate) {
    return oldDelegate.gemType != gemType;
  }
}

class GemWidget extends StatelessWidget {
  const GemWidget({
    super.key,
    required this.gemType,
  });

  final GemType gemType;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CustomGemPainter(
        gemType: gemType,
      ),
    );
  }
}

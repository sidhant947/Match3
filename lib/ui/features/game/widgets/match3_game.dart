import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:match3/domain/models/tile_model.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import 'package:match3/ui/features/game/view_models/game_view_model.dart';

class Match3Game extends FlameGame {
  final GameViewModel viewModel;
  final Map<String, FruitComponent> _components = {};
  final List<ParticleComponent> _particles = [];

  double cellSize = 0;
  double startX = 0;
  double startY = 0;
  int? selectedRow;
  int? selectedCol;

  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;
  final Random _random = Random();

  Match3Game({required this.viewModel});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _layoutGrid();
    _syncWithViewModel();
    viewModel.addListener(_syncWithViewModel);
  }

  @override
  void onRemove() {
    viewModel.removeListener(_syncWithViewModel);
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layoutGrid();
  }

  void _layoutGrid() {
    if (size.x <= 0 || size.y <= 0) return;
    final boardSize = max(0.0, min(size.x, size.y) - 16);
    final rows = viewModel.state.rows > 0 ? viewModel.state.rows : 8;
    cellSize = boardSize / rows;
    startX = (size.x - boardSize) / 2;
    startY = (size.y - boardSize) / 2;

    for (final comp in _components.values) {
      comp.size = Vector2(cellSize, cellSize);
    }
  }

  void triggerShake(double intensity) {
    _shakeIntensity = intensity;
    _shakeTimer = 0.25;
    if (intensity >= 4.5) {
      HapticService.heavyImpact();
    } else {
      HapticService.mediumImpact();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      if (_shakeTimer <= 0) {
        camera.viewfinder.position = Vector2.zero();
      } else {
        final offsetX = (_random.nextDouble() * 2 - 1) * _shakeIntensity;
        final offsetY = (_random.nextDouble() * 2 - 1) * _shakeIntensity;
        camera.viewfinder.position = Vector2(offsetX, offsetY);
      }
    }
  }

  void _syncWithViewModel() {
    final currentTiles = viewModel.state.tiles;
    final activeIds = currentTiles.map((t) => t.id).toSet();

    final toRemove = _components.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in toRemove) {
      final comp = _components[id];
      if (comp != null) {
        comp.isDestroying = true;
        _spawnMatchParticles(comp.position.x + cellSize / 2, comp.position.y + cellSize / 2, comp.emoji);
        _spawnScorePopup(comp.position.x + cellSize / 2, comp.position.y + cellSize / 2);

        if (comp.type == TileType.stripedHorizontal) {
          add(LaserBeamComponent(
            x: startX + (cellSize * viewModel.state.cols) / 2,
            y: startY + comp.row * cellSize + cellSize / 2,
            width: cellSize * viewModel.state.cols,
            height: cellSize * 0.45,
            isHorizontal: true,
          ));
          triggerShake(3.0);
        } else if (comp.type == TileType.stripedVertical) {
          add(LaserBeamComponent(
            x: startX + comp.col * cellSize + cellSize / 2,
            y: startY + (cellSize * viewModel.state.rows) / 2,
            width: cellSize * 0.45,
            height: cellSize * viewModel.state.rows,
            isHorizontal: false,
          ));
          triggerShake(3.0);
        } else if (comp.type == TileType.wrapped) {
          add(ShockwaveComponent(
            x: comp.position.x + cellSize / 2,
            y: comp.position.y + cellSize / 2,
            maxRadius: cellSize * 1.8,
          ));
          triggerShake(4.5);
        } else if (comp.type == TileType.colorBomb) {
          triggerShake(6.0);
        }
      }
    }

    for (final tile in currentTiles) {
      final existing = _components[tile.id];
      if (existing != null) {
        existing.row = tile.row;
        existing.col = tile.col;
        existing.type = tile.type;
        existing.emoji = tile.emoji;
        existing.isFrozen = tile.isFrozen;
        existing.crateHealth = tile.crateHealth;
      } else {
        final spawnY = startY - cellSize * 2;
        final spawnX = startX + tile.col * cellSize;
        final comp = FruitComponent(
          id: tile.id,
          emoji: tile.emoji,
          row: tile.row,
          col: tile.col,
          initialX: spawnX,
          initialY: spawnY,
          sizeVal: cellSize,
          type: tile.type,
          isFrozen: tile.isFrozen,
          crateHealth: tile.crateHealth,
        );
        _components[tile.id] = comp;
        add(comp);
      }
    }
  }

  void _spawnMatchParticles(double x, double y, String emoji) {
    if (cellSize <= 0) return;
    for (int i = 0; i < 8; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 100.0 + _random.nextDouble() * 120.0;
      final vx = cos(angle) * speed;
      final vy = sin(angle) * speed;
      final p = ParticleComponent(
        x: x,
        y: y,
        vx: vx,
        vy: vy,
        emoji: emoji,
        size: cellSize * 0.4,
      );
      _particles.add(p);
      add(p);
    }
  }

  void _spawnScorePopup(double x, double y) {
    if (cellSize <= 0) return;
    add(ScorePopupComponent(x: x, y: y, size: cellSize));
  }

  void handleTapAt(Offset localPosition) {
    if (cellSize <= 0 || viewModel.isProcessing || viewModel.state.isGameOver) return;
    viewModel.clearHints();

    final col = ((localPosition.dx - startX) / cellSize).floor();
    final row = ((localPosition.dy - startY) / cellSize).floor();

    if (row >= 0 && row < viewModel.state.rows && col >= 0 && col < viewModel.state.cols) {
      if (selectedRow == null || selectedCol == null) {
        selectedRow = row;
        selectedCol = col;
        HapticService.selectionClick();
      } else if (selectedRow == row && selectedCol == col) {
        selectedRow = null;
        selectedCol = null;
        HapticService.selectionClick();
      } else {
        final diffRow = (row - selectedRow!).abs();
        final diffCol = (col - selectedCol!).abs();
        if ((diffRow == 1 && diffCol == 0) || (diffRow == 0 && diffCol == 1)) {
          HapticService.lightImpact();
          viewModel.swapTiles(selectedRow!, selectedCol!, row, col);
          selectedRow = null;
          selectedCol = null;
        } else {
          selectedRow = row;
          selectedCol = col;
          HapticService.selectionClick();
        }
      }
    } else {
      selectedRow = null;
      selectedCol = null;
    }
  }

  void handleSwipeAt(Offset startPos, Offset endPos) {
    if (cellSize <= 0 || viewModel.isProcessing || viewModel.state.isGameOver) return;
    viewModel.clearHints();

    selectedRow = null;
    selectedCol = null;

    final col = ((startPos.dx - startX) / cellSize).floor();
    final row = ((startPos.dy - startY) / cellSize).floor();

    if (row < 0 || row >= viewModel.state.rows || col < 0 || col >= viewModel.state.cols) return;

    final dx = endPos.dx - startPos.dx;
    final dy = endPos.dy - startPos.dy;

    int targetRow = row;
    int targetCol = col;

    if (dx.abs() > dy.abs()) {
      targetCol += dx > 0 ? 1 : -1;
    } else {
      targetRow += dy > 0 ? 1 : -1;
    }

    if (targetRow >= 0 && targetRow < viewModel.state.rows && targetCol >= 0 && targetCol < viewModel.state.cols) {
      HapticService.lightImpact();
      viewModel.swapTiles(row, col, targetRow, targetCol);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (cellSize <= 0) return;

    final cellBgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final cellBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final selectedCellPaint = Paint()
      ..color = const Color(0xFFFFCE31).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final selectedBorderPaint = Paint()
      ..color = const Color(0xFFFFCE31)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final jellyBgPaint = Paint()
      ..color = const Color(0xFF64D2FF).withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    final jellyBorderPaint = Paint()
      ..color = const Color(0xFF8CE0FF).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int r = 0; r < viewModel.state.rows; r++) {
      for (int c = 0; c < viewModel.state.cols; c++) {
        final cellRect = Rect.fromLTWH(
          startX + c * cellSize + 2,
          startY + r * cellSize + 2,
          cellSize - 4,
          cellSize - 4,
        );
        final isSelected = selectedRow == r && selectedCol == c;
        final hasJelly = viewModel.state.jellyTiles.contains('${r}_$c');

        canvas.drawRRect(
          RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
          isSelected ? selectedCellPaint : (hasJelly ? jellyBgPaint : cellBgPaint),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
          isSelected ? selectedBorderPaint : (hasJelly ? jellyBorderPaint : cellBorderPaint),
        );

        if (hasJelly) {
          final frostStarPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.45)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(cellRect.left + 7, cellRect.top + 7),
            2.5,
            frostStarPaint,
          );
        }
      }
    }
  }
}

class FruitComponent extends PositionComponent {
  final String id;
  String emoji;
  int row;
  int col;
  TileType type;
  bool isFrozen;
  int crateHealth;
  bool isDestroying = false;
  double scaleVal = 0.0;
  double opacity = 1.0;

  double _bounceTimer = 0.0;
  bool _isBouncing = false;
  bool _needsBounce = false;
  int _lastRow = -1;
  double _hintPulseTimer = 0.0;

  FruitComponent({
    required this.id,
    required this.emoji,
    required this.row,
    required this.col,
    required double initialX,
    required double initialY,
    required double sizeVal,
    required this.type,
    this.isFrozen = false,
    this.crateHealth = 0,
  }) {
    position = Vector2(initialX, initialY);
    size = Vector2(sizeVal, sizeVal);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (parent == null || parent is! Match3Game) return;
    final game = parent as Match3Game;
    if (game.cellSize <= 0) return;

    if (isDestroying) {
      scaleVal -= dt * 6.0;
      opacity -= dt * 5.0;
      if (scaleVal <= 0.0 || opacity <= 0.0) {
        game._components.remove(id);
        removeFromParent();
      }
      return;
    }

    final isHinted = game.viewModel.state.hintTileIds.contains(id);
    if (isHinted) {
      _hintPulseTimer += dt;
      scaleVal = 1.0 + sin(_hintPulseTimer * 7.0) * 0.12;
    } else {
      _hintPulseTimer = 0.0;
      if (scaleVal < 1.0) {
        scaleVal += dt * 6.0;
        if (scaleVal > 1.0) scaleVal = 1.0;
      } else if (scaleVal > 1.0) {
        scaleVal = max(1.0, scaleVal - dt * 4.0);
      }
    }

    final targetX = game.startX + col * game.cellSize;
    final targetY = game.startY + row * game.cellSize;

    if (row != _lastRow) {
      if (row > _lastRow) {
        _needsBounce = true;
      } else {
        _needsBounce = false;
      }
      _lastRow = row;
      _isBouncing = false;
      _bounceTimer = 0.0;
    }

    final dist = position.distanceTo(Vector2(targetX, targetY));
    if (_needsBounce && (dist < 1.5 || position.y >= targetY)) {
      _isBouncing = true;
      _needsBounce = false;
      _bounceTimer = 0.0;
    }

    if (_isBouncing) {
      _bounceTimer += dt;
      final bounceOffset = sin(_bounceTimer * 18.0) * 12.0 * exp(-_bounceTimer * 6.0);
      position = Vector2(targetX, targetY + bounceOffset);
      if (_bounceTimer >= 0.8) {
        _isBouncing = false;
        _bounceTimer = 0.0;
        position = Vector2(targetX, targetY);
      }
    } else {
      if (dist < 0.5) {
        position = Vector2(targetX, targetY);
      } else {
        position.lerp(Vector2(targetX, targetY), 0.22);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (scaleVal <= 0.0 || size.x <= 0 || size.y <= 0) return;
    final game = parent is Match3Game ? (parent as Match3Game) : null;
    final isHinted = game?.viewModel.state.hintTileIds.contains(id) ?? false;

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scaleVal);

    if (isHinted) {
      final hintGlowPaint = Paint()
        ..color = const Color(0xFFFFD56B).withValues(alpha: 0.55 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawCircle(Offset.zero, size.x * 0.46, hintGlowPaint);
    }

    if (type == TileType.wrapped) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFCE31).withValues(alpha: 0.55 * opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, size.x * 0.44, glowPaint);
    }

    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: max(1.0, size.x * 0.72),
          fontFamilyFallback: const [
            'Noto Color Emoji',
            'Apple Color Emoji',
            'Segoe UI Emoji',
            'JoyPixels',
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

    if (isFrozen) {
      final iceFill = Paint()
        ..color = const Color(0xFFB0ECFF).withValues(alpha: 0.45 * opacity)
        ..style = PaintingStyle.fill;
      final iceBorder = Paint()
        ..color = const Color(0xFFE0F7FF).withValues(alpha: 0.9 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      final iceRect = Rect.fromCenter(center: Offset.zero, width: size.x * 0.88, height: size.y * 0.88);
      canvas.drawRRect(RRect.fromRectAndRadius(iceRect, const Radius.circular(8)), iceFill);
      canvas.drawRRect(RRect.fromRectAndRadius(iceRect, const Radius.circular(8)), iceBorder);
    }

    if (type == TileType.crate) {
      final cratePaint = Paint()
        ..color = const Color(0xFF8D6E63).withValues(alpha: 0.85 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      final crateRect = Rect.fromCenter(center: Offset.zero, width: size.x * 0.82, height: size.y * 0.82);
      canvas.drawRRect(RRect.fromRectAndRadius(crateRect, const Radius.circular(6)), cratePaint);
    }

    if (type == TileType.stripedHorizontal) {
      final stripePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawLine(Offset(-size.x * 0.38, 0), Offset(size.x * 0.38, 0), stripePaint);
    } else if (type == TileType.stripedVertical) {
      final stripePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawLine(Offset(0, -size.y * 0.38), Offset(0, size.y * 0.38), stripePaint);
    }

    canvas.restore();
  }
}

class LaserBeamComponent extends PositionComponent {
  final double widthVal;
  final double heightVal;
  final bool isHorizontal;
  double opacity = 1.0;
  double progress = 0.0;

  LaserBeamComponent({
    required double x,
    required double y,
    required double width,
    required double height,
    required this.isHorizontal,
  })  : widthVal = width,
        heightVal = height {
    position = Vector2(x, y);
    size = Vector2(width, height);
    priority = 80;
  }

  @override
  void update(double dt) {
    super.update(dt);
    progress += dt * 3.5;
    opacity = (1.0 - progress).clamp(0.0, 1.0);
    if (progress >= 1.0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0.0) return;
    final beamPaint = Paint()
      ..color = const Color(0xFFFFD56B).withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(center: Offset.zero, width: widthVal, height: heightVal);
    canvas.drawRect(rect, beamPaint);
    final coreRect = Rect.fromCenter(
      center: Offset.zero,
      width: isHorizontal ? widthVal : widthVal * 0.4,
      height: isHorizontal ? heightVal * 0.4 : heightVal,
    );
    canvas.drawRect(coreRect, glowPaint);
  }
}

class ShockwaveComponent extends PositionComponent {
  final double maxRadius;
  double currentRadius = 0.0;
  double opacity = 1.0;

  ShockwaveComponent({
    required double x,
    required double y,
    required this.maxRadius,
  }) {
    position = Vector2(x, y);
    priority = 80;
  }

  @override
  void update(double dt) {
    super.update(dt);
    currentRadius += dt * maxRadius * 3.5;
    opacity = (1.0 - (currentRadius / maxRadius)).clamp(0.0, 1.0);
    if (currentRadius >= maxRadius) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0.0) return;
    final wavePaint = Paint()
      ..color = const Color(0xFFFFCE31).withValues(alpha: opacity * 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(Offset.zero, currentRadius, wavePaint);
  }
}

class ParticleComponent extends PositionComponent {
  final double vx;
  final double vy;
  final String emoji;
  double opacity = 1.0;
  double scaleVal = 1.0;

  ParticleComponent({
    required double x,
    required double y,
    required this.vx,
    required this.vy,
    required this.emoji,
    required double size,
  }) {
    position = Vector2(x, y);
    this.size = Vector2(size, size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += vx * dt;
    position.y += vy * dt;
    opacity -= dt * 2.0;
    scaleVal -= dt * 1.5;

    if (opacity <= 0 || scaleVal <= 0) {
      if (parent != null && parent is Match3Game) {
        final game = parent as Match3Game;
        game._particles.remove(this);
      }
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0 || scaleVal <= 0 || size.x <= 0) return;
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: max(1.0, size.x * scaleVal),
          fontFamilyFallback: const [
            'Noto Color Emoji',
            'Apple Color Emoji',
            'Segoe UI Emoji',
            'JoyPixels',
          ],
          color: Colors.white.withValues(alpha: opacity.clamp(0.0, 1.0)),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}

class ScorePopupComponent extends PositionComponent {
  double opacity = 1.0;
  double speedY = -40.0;

  ScorePopupComponent({
    required double x,
    required double y,
    required double size,
  }) {
    position = Vector2(x, y);
    this.size = Vector2(size, size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speedY * dt;
    opacity -= dt * 1.6;
    if (opacity <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0 || size.x <= 0) return;
    final tp = TextPainter(
      text: TextSpan(
        text: '+50',
        style: TextStyle(
          fontFamily: 'BebasNeue',
          fontSize: max(1.0, size.x * 0.35),
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFCE31).withValues(alpha: opacity.clamp(0.0, 1.0)),
          shadows: const [
            Shadow(
              blurRadius: 3,
              color: Colors.black54,
              offset: Offset(1, 1),
            )
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}


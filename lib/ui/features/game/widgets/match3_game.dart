import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:match3/domain/models/tile_model.dart';
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
      }
    }

    for (final tile in currentTiles) {
      final existing = _components[tile.id];
      if (existing != null) {
        existing.row = tile.row;
        existing.col = tile.col;
        existing.type = tile.type;
        existing.emoji = tile.emoji;
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
        );
        _components[tile.id] = comp;
        add(comp);
      }
    }
  }

  void _spawnMatchParticles(double x, double y, String emoji) {
    if (cellSize <= 0) return;
    final random = Random();
    for (int i = 0; i < 8; i++) {
      final angle = random.nextDouble() * pi * 2;
      final speed = 100.0 + random.nextDouble() * 120.0;
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

    final col = ((localPosition.dx - startX) / cellSize).floor();
    final row = ((localPosition.dy - startY) / cellSize).floor();

    if (row >= 0 && row < viewModel.state.rows && col >= 0 && col < viewModel.state.cols) {
      if (selectedRow == null || selectedCol == null) {
        selectedRow = row;
        selectedCol = col;
      } else if (selectedRow == row && selectedCol == col) {
        selectedRow = null;
        selectedCol = null;
      } else {
        final diffRow = (row - selectedRow!).abs();
        final diffCol = (col - selectedCol!).abs();
        if ((diffRow == 1 && diffCol == 0) || (diffRow == 0 && diffCol == 1)) {
          viewModel.swapTiles(selectedRow!, selectedCol!, row, col);
          selectedRow = null;
          selectedCol = null;
        } else {
          selectedRow = row;
          selectedCol = col;
        }
      }
    } else {
      selectedRow = null;
      selectedCol = null;
    }
  }

  void handleSwipeAt(Offset startPos, Offset endPos) {
    if (cellSize <= 0 || viewModel.isProcessing || viewModel.state.isGameOver) return;

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

    for (int r = 0; r < viewModel.state.rows; r++) {
      for (int c = 0; c < viewModel.state.cols; c++) {
        final cellRect = Rect.fromLTWH(
          startX + c * cellSize + 2,
          startY + r * cellSize + 2,
          cellSize - 4,
          cellSize - 4,
        );
        final isSelected = selectedRow == r && selectedCol == c;
        canvas.drawRRect(
          RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
          isSelected ? selectedCellPaint : cellBgPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
          isSelected ? selectedBorderPaint : cellBorderPaint,
        );
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
  bool isDestroying = false;
  double scaleVal = 0.0;
  double opacity = 1.0;

  double _bounceTimer = 0.0;
  bool _isBouncing = false;
  bool _needsBounce = false;
  int _lastRow = -1;

  FruitComponent({
    required this.id,
    required this.emoji,
    required this.row,
    required this.col,
    required double initialX,
    required double initialY,
    required double sizeVal,
    required this.type,
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

    if (scaleVal < 1.0) {
      scaleVal += dt * 6.0;
      if (scaleVal > 1.0) scaleVal = 1.0;
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

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scaleVal);

    if (type == TileType.wrapped) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFCE31).withValues(alpha: 0.5 * opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, size.x * 0.42, glowPaint);
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


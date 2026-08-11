import 'dart:math';
import 'package:match3/domain/models/gem.dart';
import 'package:match3/domain/models/level_config.dart';

class Match3BoardGenerator {
  List<BoardGem> generateBoard({
    required LevelConfig level,
    required int seed,
    int depth = 0,
  }) {
    const maxRetries = 100;
    final rand = Random(seed);
    final board = List.generate(
      level.rows,
      (r) => List<BoardGem?>.filled(level.cols, null),
    );

    // Fill board ensuring no initial matches
    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        if (level.hasBlockers && level.blockerPositions.any((p) => p.row == r && p.col == c)) {
          board[r][c] = BoardGem(
            id: 'b_${r}_$c',
            position: BoardPosition(row: r, col: c),
            gem: const Gem(type: GemType.circle, special: SpecialGem.none),
          );
          continue;
        }

        GemType type;
        int attempts = 0;
        do {
          type = GemType.values[rand.nextInt(level.numGemTypes.clamp(1, GemType.values.length))];
          attempts++;
        } while (attempts < 50 && _wouldCreateMatch(board, r, c, type, level));

        board[r][c] = BoardGem(
          id: 'g_${r}_$c',
          position: BoardPosition(row: r, col: c),
          gem: Gem(type: type),
        );
      }
    }

    // Flatten to list
    final result = <BoardGem>[];
    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        if (board[r][c] != null) result.add(board[r][c]!);
      }
    }

    // Ensure at least one valid move exists
    if (depth < maxRetries && !_hasValidMoves(result, level)) {
      return generateBoard(level: level, seed: seed + 1, depth: depth + 1);
    }

    return result;
  }

  bool _wouldCreateMatch(
    List<List<BoardGem?>> board,
    int row,
    int col,
    GemType type,
    LevelConfig level,
  ) {
    if (col >= 2) {
      final left1 = board[row][col - 1]?.gem.type;
      final left2 = board[row][col - 2]?.gem.type;
      if (left1 == type && left2 == type && !_isBlockerPos(row, col - 1, level) && !_isBlockerPos(row, col - 2, level)) return true;
    }

    if (row >= 2) {
      final up1 = board[row - 1][col]?.gem.type;
      final up2 = board[row - 2][col]?.gem.type;
      if (up1 == type && up2 == type && !_isBlockerPos(row - 1, col, level) && !_isBlockerPos(row - 2, col, level)) return true;
    }

    return false;
  }

  bool _hasValidMoves(List<BoardGem> gems, LevelConfig level) {
    for (final gem in gems) {
      if (level.hasBlockers && level.blockerPositions.any((p) => p.row == gem.position.row && p.col == gem.position.col)) {
        continue;
      }

      if (gem.position.col < level.cols - 1) {
        final right = gems.firstWhere(
          (g) => g.position.row == gem.position.row && g.position.col == gem.position.col + 1,
          orElse: () => gem,
        );
        if (right != gem && !_isBlocker(right, level)) {
          if (_wouldCreateMatchAfterSwap(gems, gem, right, level)) return true;
        }
      }

      if (gem.position.row < level.rows - 1) {
        final down = gems.firstWhere(
          (g) => g.position.row == gem.position.row + 1 && g.position.col == gem.position.col,
          orElse: () => gem,
        );
        if (down != gem && !_isBlocker(down, level)) {
          if (_wouldCreateMatchAfterSwap(gems, gem, down, level)) return true;
        }
      }
    }
    return false;
  }

  bool _isBlocker(BoardGem gem, LevelConfig level) {
    return level.hasBlockers && level.blockerPositions.any((p) => p.row == gem.position.row && p.col == gem.position.col);
  }

  bool _isBlockerPos(int r, int c, LevelConfig level) {
    return level.hasBlockers && level.blockerPositions.any((p) => p.row == r && p.col == c);
  }

  bool _wouldCreateMatchAfterSwap(List<BoardGem> gems, BoardGem a, BoardGem b, LevelConfig level) {
    final board = List.generate(
      level.rows,
      (r) => List<Gem?>.filled(level.cols, null),
    );
    for (final g in gems) {
      board[g.position.row][g.position.col] = g.gem;
    }

    final temp = board[a.position.row][a.position.col];
    board[a.position.row][a.position.col] = board[b.position.row][b.position.col];
    board[b.position.row][b.position.col] = temp;

    return _hasMatchAt(board, a.position.row, a.position.col, level) ||
        _hasMatchAt(board, b.position.row, b.position.col, level);
  }

  bool _hasMatchAt(List<List<Gem?>> board, int row, int col, LevelConfig level) {
    final type = board[row][col]?.type;
    if (type == null || _isBlockerPos(row, col, level)) return false;

    int count = 1;
    int c = col - 1;
    while (c >= 0 && board[row][c]?.type == type && !_isBlockerPos(row, c, level)) {
      count++;
      c--;
    }
    c = col + 1;
    while (c < level.cols && board[row][c]?.type == type && !_isBlockerPos(row, c, level)) {
      count++;
      c++;
    }
    if (count >= 3) return true;

    count = 1;
    int r = row - 1;
    while (r >= 0 && board[r][col]?.type == type && !_isBlockerPos(r, col, level)) {
      count++;
      r--;
    }
    r = row + 1;
    while (r < level.rows && board[r][col]?.type == type && !_isBlockerPos(r, col, level)) {
      count++;
      r++;
    }
    return count >= 3;
  }
}

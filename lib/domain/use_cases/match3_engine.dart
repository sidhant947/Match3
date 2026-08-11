import 'dart:math';
import 'package:match3/domain/models/gem.dart';
import 'package:match3/domain/models/level_config.dart';

class MatchResult {
  const MatchResult({
    required this.matchedPositions,
    required this.matchLengths,
    this.specialGemPosition,
    this.specialGemType,
  });

  final List<BoardPosition> matchedPositions;
  final List<int> matchLengths;
  final BoardPosition? specialGemPosition;
  final SpecialGem? specialGemType;
}

class SwapResult {
  const SwapResult({
    required this.newBoard,
    required this.matches,
    required this.scoreGained,
    this.cascaded = false,
  });

  final List<BoardGem> newBoard;
  final List<MatchResult> matches;
  final int scoreGained;
  final bool cascaded;
}

class Match3Engine {
  SwapResult processSwap({
    required List<BoardGem> currentBoard,
    required BoardPosition pos1,
    required BoardPosition pos2,
    required LevelConfig level,
  }) {
    // Find gems at positions
    final gem1 = currentBoard.where(
      (g) => g.position.row == pos1.row && g.position.col == pos1.col,
    ).firstOrNull;
    final gem2 = currentBoard.where(
      (g) => g.position.row == pos2.row && g.position.col == pos2.col,
    ).firstOrNull;

    if (gem1 == null || gem2 == null) {
      return SwapResult(newBoard: currentBoard, matches: [], scoreGained: 0);
    }

    // Swap gems
    final newBoard = List<BoardGem>.from(currentBoard);
    final idx1 = newBoard.indexWhere((g) => g.id == gem1.id);
    final idx2 = newBoard.indexWhere((g) => g.id == gem2.id);

    newBoard[idx1] = gem1.copyWith(position: pos2);
    newBoard[idx2] = gem2.copyWith(position: pos1);

    // Find matches
    final matches = findAllMatches(newBoard, level);

    if (matches.isEmpty) {
      return SwapResult(newBoard: currentBoard, matches: [], scoreGained: 0);
    }

    // Process matches and cascade
    return _processCascade(newBoard, matches, level, true);
  }

  List<MatchResult> findAllMatches(List<BoardGem> board, LevelConfig level) {
    final grid = _buildGrid(board, level);
    final matches = <MatchResult>[];
    final processed = <BoardPosition>{};

    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols - 2; c++) {
        final type = grid[r][c]?.gem.type;
        if (type == null || _isBlockerPos2(r, c, level)) continue;

        int end = c + 1;
        while (end < level.cols && grid[r][end]?.gem.type == type && !_isBlockerPos2(r, end, level)) {
          end++;
        }

        final length = end - c;
        if (length >= 3) {
          final positions = <BoardPosition>[];
          final lengths = <int>[];
          for (int i = c; i < end; i++) {
            final pos = BoardPosition(row: r, col: i);
            if (!processed.contains(pos)) {
              positions.add(pos);
              processed.add(pos);
            }
          }
          if (positions.isNotEmpty) {
            lengths.add(length);

            BoardPosition? specialPos;
            SpecialGem? specialType;
            if (length >= 5) {
              specialPos = BoardPosition(row: r, col: c + length ~/ 2);
              specialType = SpecialGem.colorBomb;
            } else if (length == 4) {
              specialPos = BoardPosition(row: r, col: c + 1);
              specialType = SpecialGem.stripedV;
            }

            matches.add(MatchResult(
              matchedPositions: positions,
              matchLengths: lengths,
              specialGemPosition: specialPos,
              specialGemType: specialType,
            ));
          }
          c = end - 1;
        }
      }
    }

    processed.clear();
    for (int c = 0; c < level.cols; c++) {
      for (int r = 0; r < level.rows - 2; r++) {
        final type = grid[r][c]?.gem.type;
        if (type == null || _isBlockerPos2(r, c, level)) continue;

        int end = r + 1;
        while (end < level.rows && grid[end][c]?.gem.type == type && !_isBlockerPos2(end, c, level)) {
          end++;
        }

        final length = end - r;
        if (length >= 3) {
          final positions = <BoardPosition>[];
          final lengths = <int>[];
          for (int i = r; i < end; i++) {
            final pos = BoardPosition(row: i, col: c);
            if (!processed.contains(pos)) {
              positions.add(pos);
              processed.add(pos);
            }
          }
          if (positions.isNotEmpty) {
            lengths.add(length);

            BoardPosition? specialPos;
            SpecialGem? specialType;
            if (length >= 5) {
              specialPos = BoardPosition(row: r + length ~/ 2, col: c);
              specialType = SpecialGem.colorBomb;
            } else if (length == 4) {
              specialPos = BoardPosition(row: r + 1, col: c);
              specialType = SpecialGem.stripedH;
            }

            matches.add(MatchResult(
              matchedPositions: positions,
              matchLengths: lengths,
              specialGemPosition: specialPos,
              specialGemType: specialType,
            ));
          }
          r = end - 1;
        }
      }
    }

    return matches;
  }

  SwapResult _processCascade(
    List<BoardGem> board,
    List<MatchResult> matches,
    LevelConfig level,
    bool isInitial,
  ) {
    int totalScore = 0;
    final allMatches = <MatchResult>[];
    var currentBoard = List<BoardGem>.from(board);
    bool cascade = false;

    var currentMatches = matches;
    while (currentMatches.isNotEmpty) {
      if (cascade) {
        allMatches.addAll(currentMatches);
      } else {
        allMatches.addAll(currentMatches);
      }

      // Calculate score for matches
      for (final match in currentMatches) {
        for (final pos in match.matchedPositions) {
          final gem = currentBoard.where(
            (g) => g.position.row == pos.row && g.position.col == pos.col,
          ).firstOrNull;
          if (gem != null) {
            totalScore += scoreForGem(gem);
          }
        }
      }

      // Remove matched gems
      final matchedIds = <String>{};
      for (final match in currentMatches) {
        for (final pos in match.matchedPositions) {
          final gem = currentBoard.where(
            (g) => g.position.row == pos.row && g.position.col == pos.col,
          ).firstOrNull;
          if (gem == null) continue;
          matchedIds.add(gem.id);

          // Create special gems if applicable
          if (match.specialGemPosition != null &&
              match.specialGemType != null &&
              pos.row == match.specialGemPosition!.row &&
              pos.col == match.specialGemPosition!.col) {
            matchedIds.remove(gem.id);
          }
        }
      }

      currentBoard = currentBoard.where((g) => !matchedIds.contains(g.id)).toList();

      // Place special gems
      for (final match in currentMatches) {
        if (match.specialGemPosition != null && match.specialGemType != null) {
          final pos = match.specialGemPosition!;
          final existingIdx = currentBoard.indexWhere(
            (g) => g.position.row == pos.row && g.position.col == pos.col,
          );
          if (existingIdx >= 0) {
            final existing = currentBoard[existingIdx];
            currentBoard[existingIdx] = existing.copyWith(
              gem: Gem(type: existing.gem.type, special: match.specialGemType ?? SpecialGem.none),
            );
          } else {
            currentBoard.add(BoardGem(
              id: 's_${pos.row}_${pos.col}_${DateTime.now().millisecondsSinceEpoch}',
              position: pos,
              gem: Gem(type: GemType.circle, special: match.specialGemType ?? SpecialGem.none),
            ));
          }
        }
      }

      // Apply gravity
      currentBoard = applyGravity(currentBoard, level);

      // Fill empty spaces
      currentBoard = fillEmptySpaces(currentBoard, level, currentBoard.length);

      // Check for new matches
      currentMatches = findAllMatches(currentBoard, level);
      if (currentMatches.isNotEmpty) cascade = true;
    }

    return SwapResult(
      newBoard: currentBoard,
      matches: allMatches,
      scoreGained: totalScore,
      cascaded: cascade,
    );
  }

  List<BoardGem> applyGravity(List<BoardGem> board, LevelConfig level) {
    final grid = _buildGrid(board, level);
    final result = <BoardGem>[];

    for (int c = 0; c < level.cols; c++) {
      // Collect non-blocker gems in this column (top to bottom order)
      final movableGems = <BoardGem>[];
      final blockerPositions = <int>[];

      for (int r = 0; r < level.rows; r++) {
        final gem = grid[r][c];
        if (gem != null) {
          if (_isBlockerPos2(r, c, level)) {
            blockerPositions.add(r);
          } else {
            movableGems.add(gem);
          }
        }
      }

      // Place gems from bottom, skipping blocker positions
      int gemIdx = movableGems.length - 1;
      for (int r = level.rows - 1; r >= 0; r--) {
        if (blockerPositions.contains(r)) {
          final blockerGem = grid[r][c];
          if (blockerGem != null) {
            result.add(blockerGem);
          } else {
            result.add(BoardGem(
              id: 'b_${r}_$c',
              position: BoardPosition(row: r, col: c),
              gem: const Gem(type: GemType.circle, special: SpecialGem.none),
            ));
          }
        } else if (gemIdx >= 0) {
          // Place falling gem
          result.add(movableGems[gemIdx].copyWith(
            position: BoardPosition(row: r, col: c),
          ));
          gemIdx--;
        }
      }
    }

    return result;
  }

  List<BoardGem> fillEmptySpaces(List<BoardGem> board, LevelConfig level, int existingCount) {
    final result = List<BoardGem>.from(board);
    final rand = Random();
    int index = 0;

    final occupiedPositions = <String>{};
    for (final gem in result) {
      occupiedPositions.add('${gem.position.row},${gem.position.col}');
    }

    final numTypes = level.numGemTypes.clamp(1, GemType.values.length);

    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        final key = '$r,$c';
        if (!occupiedPositions.contains(key) && !_isBlockerPos2(r, c, level)) {
          final type = GemType.values[rand.nextInt(numTypes)];
          result.add(BoardGem(
            id: 'new_${DateTime.now().microsecondsSinceEpoch}_${index++}',
            position: BoardPosition(row: r, col: c),
            gem: Gem(type: type),
          ));
        }
      }
    }

    return result;
  }

  bool _isBlockerPos(BoardGem gem, LevelConfig level) {
    return level.hasBlockers && level.blockerPositions.any(
      (p) => p.row == gem.position.row && p.col == gem.position.col,
    );
  }

  bool _isBlockerPos2(int r, int c, LevelConfig level) {
    return level.hasBlockers && level.blockerPositions.any(
      (p) => p.row == r && p.col == c,
    );
  }

  List<List<BoardGem?>> _buildGrid(List<BoardGem> board, LevelConfig level) {
    final grid = List.generate(
      level.rows,
      (r) => List<BoardGem?>.filled(level.cols, null),
    );
    for (final gem in board) {
      if (gem.position.row < level.rows && gem.position.col < level.cols) {
        grid[gem.position.row][gem.position.col] = gem;
      }
    }
    return grid;
  }

  int scoreForGem(BoardGem gem) {
    int base = 10;
    if (gem.gem.isSpecial) base *= 3;
    return base;
  }

  bool hasValidMoves(List<BoardGem> board, LevelConfig level) {
    for (final gem in board) {
      if (_isBlockerPos(gem, level)) continue;

      // Try swap right
      if (gem.position.col < level.cols - 1) {
        final right = board.where(
          (g) => g.position.row == gem.position.row && g.position.col == gem.position.col + 1,
        ).firstOrNull;
        if (right != null && !_isBlockerPos(right, level)) {
          if (_wouldMatchAfterSwap(board, gem, right, level)) return true;
        }
      }

      // Try swap down
      if (gem.position.row < level.rows - 1) {
        final down = board.where(
          (g) => g.position.row == gem.position.row + 1 && g.position.col == gem.position.col,
        ).firstOrNull;
        if (down != null && !_isBlockerPos(down, level)) {
          if (_wouldMatchAfterSwap(board, gem, down, level)) return true;
        }
      }
    }
    return false;
  }

  bool _wouldMatchAfterSwap(List<BoardGem> board, BoardGem a, BoardGem b, LevelConfig level) {
    final grid = _buildGrid(board, level);

    // Swap in grid
    final temp = grid[a.position.row][a.position.col];
    grid[a.position.row][a.position.col] = grid[b.position.row][b.position.col];
    grid[b.position.row][b.position.col] = temp;

    // Check if either position has a match
    return _hasMatchAt(grid, a.position.row, a.position.col, level) ||
        _hasMatchAt(grid, b.position.row, b.position.col, level);
  }

  bool _hasMatchAt(List<List<BoardGem?>> grid, int row, int col, LevelConfig level) {
    final type = grid[row][col]?.gem.type;
    if (type == null) return false;

    // Horizontal
    int count = 1;
    int c = col - 1;
    while (c >= 0 && grid[row][c]?.gem.type == type) { count++; c--; }
    c = col + 1;
    while (c < level.cols && grid[row][c]?.gem.type == type) { count++; c++; }
    if (count >= 3) return true;

    // Vertical
    count = 1;
    int r = row - 1;
    while (r >= 0 && grid[r][col]?.gem.type == type) { count++; r--; }
    r = row + 1;
    while (r < level.rows && grid[r][col]?.gem.type == type) { count++; r++; }
    return count >= 3;
  }

  List<BoardGem> shuffleBoard(List<BoardGem> board, LevelConfig level, int seed, {int depth = 0}) {
    const maxRetries = 100;
    final rand = Random(seed);
    final gems = board.where((g) => !_isBlockerPos(g, level)).toList();
    final types = gems.map((g) => g.gem.type).toList()..shuffle(rand);

    final result = List<BoardGem>.from(board);
    for (int i = 0; i < gems.length; i++) {
      final idx = result.indexWhere((g) => g.id == gems[i].id);
      result[idx] = result[idx].copyWith(
        gem: Gem(type: types[i]),
      );
    }

    // Ensure no initial matches and valid moves exist
    if (depth < maxRetries && (_hasInitialMatches(result, level) || !hasValidMoves(result, level))) {
      return shuffleBoard(board, level, seed + 1, depth: depth + 1);
    }

    return result;
  }

  bool _hasInitialMatches(List<BoardGem> board, LevelConfig level) {
    final matches = findAllMatches(board, level);
    return matches.isNotEmpty;
  }
}

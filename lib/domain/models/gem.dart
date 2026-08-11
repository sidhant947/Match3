import 'package:flutter/foundation.dart';

enum GemType {
  circle,
  diamond,
  square,
  triangle,
  hexagon,
  star,
  pentagon,
  heart,
  oval,
  rhombus,
}

enum SpecialGem {
  none,
  stripedH,
  stripedV,
  wrapped,
  colorBomb,
}

@immutable
class Gem {
  const Gem({
    required this.type,
    this.special = SpecialGem.none,
  });

  final GemType type;
  final SpecialGem special;

  Gem copyWith({
    GemType? type,
    SpecialGem? special,
  }) {
    return Gem(
      type: type ?? this.type,
      special: special ?? this.special,
    );
  }

  bool matches(Gem other) => type == other.type;

  bool get isSpecial => special != SpecialGem.none;
}

@immutable
class BoardPosition {
  const BoardPosition({
    required this.row,
    required this.col,
  });

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  bool isAdjacentTo(BoardPosition other) {
    final dr = (row - other.row).abs();
    final dc = (col - other.col).abs();
    return (dr == 1 && dc == 0) || (dr == 0 && dc == 1);
  }
}

@immutable
class BoardGem {
  const BoardGem({
    required this.id,
    required this.position,
    required this.gem,
  });

  final String id;
  final BoardPosition position;
  final Gem gem;

  BoardGem copyWith({
    String? id,
    BoardPosition? position,
    Gem? gem,
  }) {
    return BoardGem(
      id: id ?? this.id,
      position: position ?? this.position,
      gem: gem ?? this.gem,
    );
  }
}

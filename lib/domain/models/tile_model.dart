import 'package:flutter/foundation.dart';

enum TileType {
  normal,
  stripedHorizontal,
  stripedVertical,
  wrapped,
  colorBomb,
}

@immutable
class TileModel {
  final String id;
  final int row;
  final int col;
  final String emoji;
  final TileType type;

  const TileModel({
    required this.id,
    required this.row,
    required this.col,
    required this.emoji,
    this.type = TileType.normal,
  });

  TileModel copyWith({
    String? id,
    int? row,
    int? col,
    String? emoji,
    TileType? type,
  }) {
    return TileModel(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          row == other.row &&
          col == other.col &&
          emoji == other.emoji &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^ row.hashCode ^ col.hashCode ^ emoji.hashCode ^ type.hashCode;
}

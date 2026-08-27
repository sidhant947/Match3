import 'package:flutter/foundation.dart';

enum TileType {
  normal,
  stripedHorizontal,
  stripedVertical,
  wrapped,
  colorBomb,
  crate,
}

@immutable
class TileModel {
  final String id;
  final int row;
  final int col;
  final String emoji;
  final TileType type;
  final bool isFrozen;
  final int crateHealth;

  const TileModel({
    required this.id,
    required this.row,
    required this.col,
    required this.emoji,
    this.type = TileType.normal,
    this.isFrozen = false,
    this.crateHealth = 0,
  });

  bool get isObstacle => type == TileType.crate;
  bool get canSwap => !isFrozen && !isObstacle;

  TileModel copyWith({
    String? id,
    int? row,
    int? col,
    String? emoji,
    TileType? type,
    bool? isFrozen,
    int? crateHealth,
  }) {
    return TileModel(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      isFrozen: isFrozen ?? this.isFrozen,
      crateHealth: crateHealth ?? this.crateHealth,
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

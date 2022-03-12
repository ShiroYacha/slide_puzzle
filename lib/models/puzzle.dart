import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:very_good_slide_puzzle/chess/chess_piece.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

// A 3x3 puzzle board visualization:
//
//   ┌─────1───────2───────3────► x
//   │  ┌─────┐ ┌─────┐ ┌─────┐
//   1  │  1  │ │  2  │ │  3  │
//   │  └─────┘ └─────┘ └─────┘
//   │  ┌─────┐ ┌─────┐ ┌─────┐
//   2  │  4  │ │  5  │ │  6  │
//   │  └─────┘ └─────┘ └─────┘
//   │  ┌─────┐ ┌─────┐
//   3  │  7  │ │  8  │
//   │  └─────┘ └─────┘
//   ▼
//   y
//
// This puzzle is in its completed state (i.e. the tiles are arranged in
// ascending order by value from top to bottom, left to right).
//
// Each tile has a value (1-8 on example above), and a correct and current
// position.
//
// The correct position is where the tile should be in the completed
// puzzle. As seen from example above, tile 2's correct position is (2, 1).
// The current position is where the tile is currently located on the board.

/// {@template puzzle}
/// Model for a puzzle.
/// {@endtemplate}
class Puzzle extends Equatable {
  /// {@macro puzzle}
  const Puzzle({
    required this.tiles,
  });

  /// List of [Tile]s representing the puzzle's current arrangement.
  final List<Tile> tiles;

  /// Get the dimension of a puzzle given its tile arrangement.
  ///
  /// Ex: A 4x4 puzzle has a dimension of 4.
  int getDimension() {
    return sqrt(tiles.length).toInt();
  }

  /// Gets the single whitespace tile object in the puzzle.
  Tile getWhitespaceTile() {
    return tiles.singleWhere((tile) => tile.isWhitespace);
  }

  /// Gets the tile relative to the whitespace tile in the puzzle
  /// defined by [relativeOffset].
  Tile? getTileRelativeToWhitespaceTile(Offset relativeOffset) {
    final whitespaceTile = getWhitespaceTile();
    return tiles.singleWhereOrNull(
      (tile) =>
          tile.currentPosition.x ==
              whitespaceTile.currentPosition.x + relativeOffset.dx &&
          tile.currentPosition.y ==
              whitespaceTile.currentPosition.y + relativeOffset.dy,
    );
  }

  /// Determines if the puzzle is completed.
  bool isComplete() {
    if (tiles.every((e) => [ChessPieceType.empty, ChessPieceType.king]
        .contains(e.chessPiece.type))) {
      return true;
    }
    return false;
  }

  /// Determines if the tapped tile can move in the direction of the whitespace
  /// tile.
  bool isTileMovable(Tile tile) {
    final whitespaceTile = getWhitespaceTile();
    if (tile == whitespaceTile) {
      return false;
    }

    // A tile must be in the same row or column as the whitespace to move.
    if (whitespaceTile.currentPosition.x != tile.currentPosition.x &&
        whitespaceTile.currentPosition.y != tile.currentPosition.y) {
      return false;
    }
    return true;
  }

  /// Determines if the puzzle is solvable.
  bool isSolvable() {
    return true;
  }

  /// Shifts one or many tiles in a row/column with the whitespace and returns
  /// the modified puzzle.
  ///
  // Recursively stores a list of all tiles that need to be moved and passes the
  // list to _swapTiles to individually swap them.
  Puzzle moveTiles(Tile tile, List<Tile> tilesToSwap) {
    final whitespaceTile = getWhitespaceTile();
    final deltaX = whitespaceTile.currentPosition.x - tile.currentPosition.x;
    final deltaY = whitespaceTile.currentPosition.y - tile.currentPosition.y;

    if ((deltaX.abs() + deltaY.abs()) > 1) {
      final shiftPointX = tile.currentPosition.x + deltaX.sign;
      final shiftPointY = tile.currentPosition.y + deltaY.sign;
      final tileToSwapWith = tiles.singleWhere(
        (tile) =>
            tile.currentPosition.x == shiftPointX &&
            tile.currentPosition.y == shiftPointY,
      );
      tilesToSwap.add(tile);
      return moveTiles(tileToSwapWith, tilesToSwap);
    } else {
      tilesToSwap.add(tile);
      return _swapTiles(tilesToSwap);
    }
  }

  /// Returns puzzle with new tile arrangement after individually swapping each
  /// tile in tilesToSwap with the whitespace.
  Puzzle _swapTiles(List<Tile> tilesToSwap) {
    for (final tileToSwap in tilesToSwap.reversed) {
      final tileIndex = tiles.indexOf(tileToSwap);
      final tile = tiles[tileIndex];
      final whitespaceTile = getWhitespaceTile();
      final whitespaceTileIndex = tiles.indexOf(whitespaceTile);

      // Swap current board positions of the moving tile and the whitespace.
      tiles[tileIndex] = tile.copyWith(
        currentPosition: whitespaceTile.currentPosition,
      );
      tiles[whitespaceTileIndex] = whitespaceTile.copyWith(
        currentPosition: tile.currentPosition,
      );
    }

    return Puzzle(tiles: tiles);
  }

  /// Sorts puzzle tiles so they are in order of their current position.
  Puzzle sort() {
    final sortedTiles = tiles.toList()
      ..sort((tileA, tileB) {
        return tileA.currentPosition.compareTo(tileB.currentPosition);
      });
    return Puzzle(tiles: sortedTiles);
  }

  // /// Sorts puzzle tiles so they are in order of their current position.
  // Puzzle sortByChessPieceId() {
  //   final sortedTiles = tiles.toList()
  //     ..sort((tileA, tileB) {
  //       return tileA.chessPiece.id.compareTo(tileB.chessPiece.id);
  //     });
  //   return Puzzle(tiles: sortedTiles);
  // }

  @override
  List<Object> get props => [tiles];
}

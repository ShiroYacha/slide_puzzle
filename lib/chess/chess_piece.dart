// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';

/// TODO: improve this for now use a global state
final moveMapCache = <String, bool>{};

/// A chess piece
class ChessPiece {
  /// Default constructor
  const ChessPiece(
    this.id, {
    required this.color,
    required this.type,
  });

  factory ChessPiece.fromString(String string) {
    return ChessPiece.fromJson(
      Map<String, dynamic>.from(jsonDecode(string) as Map),
    );
  }

  factory ChessPiece.fromJson(Map<String, dynamic> json) {
    return ChessPiece(
      json['id'] as int,
      color: ChessPieceColor.values.firstWhere((e) => e.name == json['color']),
      type: ChessPieceType.values.firstWhere((e) => e.name == json['type']),
    );
  }

  factory ChessPiece.empty(int id) {
    return ChessPiece(
      id,
      color: ChessPieceColor.none,
      type: ChessPieceType.empty,
    );
  }

  ChessPiece copyWith({
    int? id,
    ChessPieceColor? color,
    ChessPieceType? type,
  }) =>
      ChessPiece(
        id ?? this.id,
        color: color ?? this.color,
        type: type ?? this.type,
      );

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  Widget build(BuildContext context) {
    final size =
        context.select((PuzzleBloc bloc) => bloc.state.puzzle.tiles.length);
    return Center(
      child: SvgPicture.asset(
        'assets/images/chess/Chess_$pieceSymbol${colorCode}t45.svg',
        width: 60 / sqrt(size).floor() * 3,
      ),
    );
  }

  String get pieceSymbol => type == ChessPieceType.knight ? 'n' : type.name[0];
  String get colorCode =>
      {
        ChessPieceColor.black: 'd',
        ChessPieceColor.white: 'l',
      }[color] ??
      '?';

  int get pieceValue =>
      {
        ChessPieceType.pawn: 1,
        ChessPieceType.knight: 3,
        ChessPieceType.bishop: 3,
        ChessPieceType.rook: 5,
        ChessPieceType.queen: 9,
      }[type] ??
      0;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'color': color.name,
      'type': type.name,
    };
  }

  /// This is a hack to make each piece unique in the puzzle
  final int id;

  /// Color of the piece
  final ChessPieceColor color;

  /// Type of the piece
  final ChessPieceType type;

  bool canCapture(
    PuzzleState puzzleState, {
    required Tile fromTile,
    required Tile toTile,
    bool checkKingSafety = true,
    bool checkPiece = true,
    bool checkTurn = true,
  }) {
    // Check hash
    final hash = [
      puzzleState.tileHash,
      fromTile.value,
      toTile.value,
      checkKingSafety,
      checkPiece,
      checkTurn
    ].join(',');
    if (moveMapCache.containsKey(hash)) {
      return moveMapCache[hash]!;
    }
    // Compute
    final from = fromTile.currentPosition;
    final to = toTile.currentPosition;
    if (checkTurn && puzzleState.colorToMove != fromTile.chessPiece.color) {
      // Cannot capture if it's not your turn
      moveMapCache[hash] = false;
      return false;
    }
    if ((checkPiece &&
            (toTile.chessPiece.color == fromTile.chessPiece.color)) ||
        from == to) {
      // Cannot capture same color piece or not move
      moveMapCache[hash] = false;
      return false;
    }
    if (type == ChessPieceType.pawn) {
      final result = (to.x - from.x).abs() == 1 &&
          (to.y - from.y) == (color == ChessPieceColor.white ? -1 : 1) &&
          (!checkPiece ||
              (toTile.chessPiece.type != ChessPieceType.empty &&
                  toTile.chessPiece.color != color));
      moveMapCache[hash] = result;
      return result;
    }
    final result = canMove(
      puzzleState,
      fromTile: fromTile,
      toTile: toTile,
      checkKingSafety: checkKingSafety,
      checkPiece: checkPiece,
      checkTurn: checkTurn,
    );
    moveMapCache[hash] = result;
    return result;
  }

  ChessPieceColor get oppositeColor => color == ChessPieceColor.white
      ? ChessPieceColor.black
      : ChessPieceColor.white;

  bool checkIfMoveGetsOutOfCheck(
    PuzzleState puzzleState, {
    required Tile fromTile,
    required Tile toTile,
  }) {
    final newState = puzzleState.copyWith(
      puzzle: Puzzle(
        tiles: [
          ...puzzleState.puzzle.tiles.where(
            (e) => ![fromTile.chessPiece.id, toTile.chessPiece.id]
                .contains(e.chessPiece.id),
          ),
          toTile.copyWith(
            currentPosition: toTile.currentPosition,
            chessPiece: //promotedPiece ??
                fromTile.chessPiece.copyWith(id: toTile.chessPiece.id),
          ),
          fromTile.copyWith(
            currentPosition: fromTile.currentPosition,
            chessPiece: fromTile.chessPiece.copyWith(
              type: ChessPieceType.empty,
              color: ChessPieceColor.none,
            ),
          ),
        ],
      ),
    );
    return !newState.isCurrentMoveColorKingInCheck;
  }

  bool canMove(
    PuzzleState puzzleState, {
    required Tile fromTile,
    required Tile toTile,
    bool checkKingSafety = true,
    bool checkPiece = true,
    bool checkTurn = true,
  }) {
    // Check hash
    final hash = [
      puzzleState.tileHash,
      fromTile.value,
      toTile.value,
      checkKingSafety,
      checkPiece,
      checkTurn
    ].join(',');
    if (moveMapCache.containsKey(hash)) {
      return moveMapCache[hash]!;
    }
    // Compute
    final from = fromTile.currentPosition;
    final to = toTile.currentPosition;
    if (checkTurn && puzzleState.colorToMove != fromTile.chessPiece.color) {
      // Cannot move if it's not your turn
      moveMapCache[hash] = false;
      return false;
    }
    if (checkPiece &&
        (toTile.chessPiece.color == fromTile.chessPiece.color || from == to)) {
      // Cannot move/capture same color piece or not move
      moveMapCache[hash] = false;
      return false;
    }
    if (!checkPiece ||
        (!puzzleState.isCurrentMoveColorKingInCheck ||
            checkIfMoveGetsOutOfCheck(
              puzzleState,
              fromTile: fromTile,
              toTile: toTile,
            ))) {
      final attackVector = color == ChessPieceColor.white ? -1 : 1;
      final attackingInStraightLine =
          ((to.x - from.x).abs() == 0 || (to.y - from.y).abs() == 0) &&
              !puzzleState.hasAnyTileBetweenStraightOrDiagonaleLine(
                toTile: toTile,
                fromTile: fromTile,
              );
      final attackingInDiagonaleLine =
          (to.x - from.x).abs() == (to.y - from.y).abs() &&
              !puzzleState.hasAnyTileBetweenStraightOrDiagonaleLine(
                toTile: toTile,
                fromTile: fromTile,
              );
      var result = false;
      switch (type) {
        case ChessPieceType.king:
          result = (to.x - from.x).abs() <= 1 && (to.y - from.y).abs() <= 1;
          break;
        case ChessPieceType.pawn:
          result = canCapture(
                puzzleState,
                fromTile: fromTile,
                toTile: toTile,
              ) ||
              (to.y - from.y) == attackVector &&
                  from.x == to.x &&
                  toTile.chessPiece.type == ChessPieceType.empty;
          break;
        case ChessPieceType.knight:
          result = ((to.x - from.x).abs() == 2 && (to.y - from.y).abs() == 1) ||
              ((to.x - from.x).abs() == 1 && (to.y - from.y).abs() == 2);
          break;
        case ChessPieceType.bishop:
          result = attackingInDiagonaleLine;
          break;
        case ChessPieceType.rook:
          result = attackingInStraightLine;
          break;
        case ChessPieceType.queen:
          result = attackingInDiagonaleLine || attackingInStraightLine;
          break;
        case ChessPieceType.empty:
          result = false;
          break;
      }
      if (result &&
          checkKingSafety &&
          !checkIfMoveGetsOutOfCheck(
            puzzleState,
            fromTile: fromTile,
            toTile: toTile,
          )) {
        // Cannot move and make your own king checked
        moveMapCache[hash] = false;
        return false;
      }
      moveMapCache[hash] = result;
      return result;
    }
    moveMapCache[hash] = false;
    return false;
  }
}

enum ChessPieceColor {
  white,
  black,
  none,
}

enum ChessPieceType {
  pawn,
  knight,
  bishop,
  rook,
  queen,
  king,
  empty,
}

abstract class ChessPieceFactory {
  const ChessPieceFactory();
  String get name;
  int get boardSize;

  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  });
}

const chessPieceFactories = [
  ChessPieceLevel1Factory(),
  ChessPieceLevel2Factory(),
  ChessPieceLevel3Factory(),
  ChessPieceLevel4Factory(),
  ChessPieceLevel5Factory(),
  ChessPieceLevel6Factory(),
  ChessPieceLevel7Factory(),
  ChessPieceLevel8Factory(),
  // ChessPieceNormalBoardFactory(),
];

const defaultFactory = ChessPieceLevel1Factory();

class ChessPieceLevel1Factory extends ChessPieceFactory {
  const ChessPieceLevel1Factory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 1 || index == maxIndex) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if (index <= 2 || index > maxIndex - 2) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.bishop,
      );
    } else if ((index > size && index <= size * 2) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => 'Board 1';

  @override
  int get boardSize => 3;
}

class ChessPieceLevel2Factory extends ChessPieceFactory {
  const ChessPieceLevel2Factory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 1 || index == maxIndex) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if (index <= 2 || index > maxIndex - 2) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.queen,
      );
    } else if ((index > size && index <= size * 2) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => 'Board 2';

  @override
  int get boardSize => 3;
}

class ChessPieceLevel3Factory extends ChessPieceFactory {
  const ChessPieceLevel3Factory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 1 || index == maxIndex) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if (index <= 2 || index > maxIndex - 2) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.rook,
      );
    } else if ((index > size && index <= size * 2) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => 'Board 3';

  @override
  int get boardSize => 3;
}

class ChessPieceLevel4Factory extends ChessPieceFactory {
  const ChessPieceLevel4Factory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 1 || index == maxIndex) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if (index <= 2 || index > maxIndex - 2) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.rook,
      );
    } else if ((index > size && index <= size * 2 - 1) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => 'Board 4';

  @override
  int get boardSize => 4;
}

class ChessPieceLevel5Factory extends ChessPieceFactory {
  const ChessPieceLevel5Factory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 3 || index == maxIndex - 2) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if ([1, 4, maxIndex, maxIndex - 3].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.rook,
      );
    } else if (index <= 4) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.bishop,
      );
    } else if (index > maxIndex - 4) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.knight,
      );
    } else if ((index > size && index <= size * 2) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => 'Board 5';

  @override
  int get boardSize => 4;
}

class ChessPieceLevel6Factory extends ChessPieceFactory {
  const ChessPieceLevel6Factory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 3 || index == maxIndex - 2) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if ([1, 5, maxIndex, maxIndex - 4].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.rook,
      );
    } else if (index <= 4 || index > maxIndex - 4) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.bishop,
      );
    } else if ((index > size && index <= size * 2) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => 'Board 6';

  @override
  int get boardSize => 5;
}

class ChessPieceLevel7Factory extends ChessPieceFactory {
  const ChessPieceLevel7Factory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 3 || index == maxIndex - 2) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if ([1, 5, maxIndex, maxIndex - 4].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.rook,
      );
    } else if (index <= 4 || index > maxIndex - 4) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.bishop,
      );
    } else if ([8, 18].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.knight,
      );
    } else if ((index > size && index <= size * 2) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => 'Board 7';

  @override
  int get boardSize => 5;
}

class ChessPieceLevel8Factory extends ChessPieceFactory {
  const ChessPieceLevel8Factory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 3 || index == maxIndex - 2) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if ([1, 5, maxIndex, maxIndex - 4].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.rook,
      );
    } else if ([8, 18].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.bishop,
      );
    } else if (index <= 4 || index > maxIndex - 4) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.knight,
      );
    } else if ((index > size && index <= size * 2) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => 'Board 8';

  @override
  int get boardSize => 5;
}

class ChessPieceNormalBoardFactory extends ChessPieceFactory {
  const ChessPieceNormalBoardFactory();

  @override
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    final size = sqrt(maxIndex).floor();
    if (index == 5 || index == maxIndex - 3) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    }
    if (index == 4 || index == maxIndex - 4) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.queen,
      );
    } else if ([1, 8, maxIndex, maxIndex - 7].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.rook,
      );
    } else if ([2, 7, maxIndex - 1, maxIndex - 6].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.knight,
      );
    } else if ([3, 6, maxIndex - 2, maxIndex - 5].contains(index)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.bishop,
      );
    } else if ((index > size && index <= size * 2) ||
        (index > maxIndex - size * 2 && index <= maxIndex - size)) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.pawn,
      );
    }
    return ChessPiece.empty(index);
  }

  @override
  String get name => '"Normal" board';

  @override
  int get boardSize => 8;
}

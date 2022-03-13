// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

import 'package:very_good_slide_puzzle/models/tile.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';

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
    final puzzleState = context.select((PuzzleBloc bloc) => bloc.state);
    return Center(
      child: SvgPicture.asset(
        'images/chess/Chess_$pieceSymbol${colorCode}t45.svg',
        width: 60 / sqrt(puzzleState.puzzle.tiles.length).floor() * 3,
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
    final from = fromTile.currentPosition;
    final to = toTile.currentPosition;
    if (checkTurn && puzzleState.colorToMove != fromTile.chessPiece.color) {
      // Cannot capture if it's not your turn
      return false;
    }
    if ((checkPiece &&
            (toTile.chessPiece.color == fromTile.chessPiece.color)) ||
        from == to) {
      // Cannot capture same color piece or not move
      return false;
    }
    if (type == ChessPieceType.pawn) {
      return (to.x - from.x).abs() == 1 &&
          (to.y - from.y) == (color == ChessPieceColor.white ? 1 : -1) &&
          (!checkPiece ||
              (toTile.chessPiece.type != ChessPieceType.empty &&
                  toTile.chessPiece.color != color));
    }
    return canMove(
      puzzleState,
      fromTile: fromTile,
      toTile: toTile,
      checkKingSafety: checkKingSafety,
      checkPiece: checkPiece,
      checkTurn: checkTurn,
    );
  }

  ChessPieceColor get oppositeColor => color == ChessPieceColor.white
      ? ChessPieceColor.black
      : ChessPieceColor.white;

  bool canMove(
    PuzzleState puzzleState, {
    required Tile fromTile,
    required Tile toTile,
    bool checkKingSafety = true,
    bool checkPiece = true,
    bool checkTurn = true,
  }) {
    final from = fromTile.currentPosition;
    final to = toTile.currentPosition;
    if (checkTurn && puzzleState.colorToMove != fromTile.chessPiece.color) {
      // Cannot move if it's not your turn
      return false;
    }
    if (checkPiece &&
        (toTile.chessPiece.color == fromTile.chessPiece.color || from == to)) {
      // Cannot move/capture same color piece or not move
      return false;
    }
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
    switch (type) {
      case ChessPieceType.king:
        return (to.x - from.x).abs() <= 1 &&
            (to.y - from.y).abs() <= 1 &&
            // King cannot move into check
            (!checkKingSafety ||
                !puzzleState.isTileAttackedByAnyPiece(
                  toTile: toTile,
                  color: color,
                ));
      case ChessPieceType.pawn:
        return canCapture(
              puzzleState,
              fromTile: fromTile,
              toTile: toTile,
            ) ||
            (to.y - from.y) == attackVector &&
                from.x == to.x &&
                toTile.chessPiece.type == ChessPieceType.empty;
      case ChessPieceType.knight:
        return ((to.x - from.x).abs() == 2 && (to.y - from.y).abs() == 1) ||
            ((to.x - from.x).abs() == 1 && (to.y - from.y).abs() == 2);
      case ChessPieceType.bishop:
        return attackingInDiagonaleLine;
      case ChessPieceType.rook:
        return attackingInStraightLine;
      case ChessPieceType.queen:
        return attackingInDiagonaleLine || attackingInStraightLine;
      case ChessPieceType.empty:
        return false;
    }
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

class ChessPieceFactory {
  ChessPiece getPiece({
    required int index,
    required int maxIndex,
  }) {
    final color =
        index > maxIndex / 2 ? ChessPieceColor.white : ChessPieceColor.black;
    if (index == 1 || index == maxIndex) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.king,
      );
    } else if (index <= 10 || index >= maxIndex - 10) {
      return ChessPiece(
        index,
        color: color,
        type: ChessPieceType.bishop,
      );
    }
    // if (index == 2 || index == maxIndex - 1) {
    //   return ChessPiece(
    //     index,
    //     color: color,
    //     type: ChessPieceType.rook,
    //   );
    // }
    return ChessPiece.empty(index);
  }
}

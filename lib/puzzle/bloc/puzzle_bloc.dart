// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:very_good_slide_puzzle/app/app.dart';
import 'package:very_good_slide_puzzle/chess/chess_piece.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

import 'package:very_good_slide_puzzle/utils.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc(
    this._size, {
    this.random,
  }) : super(const PuzzleState()) {
    on<PuzzleInitialized>(_onPuzzleInitialized);
    on<TileTapped>(_onTileTapped);
    on<PuzzleReset>(_onPuzzleReset);
    on<TileDragStarted>(_onTileDragStarted);
    on<TileDragEnded>(_onTileDragEnded);
    on<TileDropped>(_onTileDropped);
    on<PuzzleEnded>(_onPuzzleEnded);
  }
  final int _size;

  final Random? random;

  void _onPuzzleInitialized(
    PuzzleInitialized event,
    Emitter<PuzzleState> emit,
  ) {
    final puzzle = _generatePuzzle(_size);
    emit(
      PuzzleState(
        puzzle: puzzle.sort(),
      ),
    );
  }

  void _onTileDragStarted(TileDragStarted event, Emitter<PuzzleState> emit) {
    emit(
      state.copyWith(
        draggingTile: NullableCopy(event.tile),
        tileMovementStatus: TileMovementStatus.nothingTapped,
      ),
    );
  }

  void _onTileDragEnded(TileDragEnded event, Emitter<PuzzleState> emit) {
    emit(
      state.copyWith(
        draggingTile: const NullableCopy(null),
        tileMovementStatus: TileMovementStatus.nothingTapped,
      ),
    );
  }

  Future<ChessPiece?> promotePawn({
    required ChessPieceColor color,
    required int id,
  }) {
    return showDialog<ChessPiece>(
      context: navKey.currentContext!,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          actionsPadding: const EdgeInsets.all(8),
          actions: [
            ChessPiece(id, color: color, type: ChessPieceType.queen),
            ChessPiece(id, color: color, type: ChessPieceType.rook),
            ChessPiece(id, color: color, type: ChessPieceType.knight),
            ChessPiece(id, color: color, type: ChessPieceType.bishop),
          ]
              .map(
                (e) => TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(e);
                  },
                  child: SvgPicture.asset(
                      'images/chess/Chess_${e.pieceSymbol}${e.colorCode}t45.svg'),
                ),
              )
              .toList(),
        );
      },
    );
  }

  void _onPuzzleEnded(
    PuzzleEnded event,
    Emitter<PuzzleState> emit,
  ) {
    emit(state.copyWith(puzzleResult: event.result));
  }

  Future<void> _onTileDropped(
    TileDropped event,
    Emitter<PuzzleState> emit,
  ) async {
    ChessPiece? promotedPiece;
    final boardSize = sqrt(state.puzzle.tiles.length).floor();
    if (event.fromTile.chessPiece.type == ChessPieceType.pawn) {
      if (event.fromTile.chessPiece.color == ChessPieceColor.white &&
          event.toTile.currentPosition.y == 1) {
        promotedPiece = await promotePawn(
          color: ChessPieceColor.white,
          id: event.toTile.chessPiece.id,
        );
      }
      if (event.fromTile.chessPiece.color == ChessPieceColor.black &&
          event.toTile.currentPosition.y == boardSize) {
        promotedPiece = await promotePawn(
          color: ChessPieceColor.black,
          id: event.toTile.chessPiece.id,
        );
      }
    }
    final newState = state.copyWith(
      colorToMove: state.colorToMove == ChessPieceColor.white
          ? ChessPieceColor.black
          : ChessPieceColor.white,
      tileMovementStatus: TileMovementStatus.dropped,
      puzzle: Puzzle(
        tiles: [
          ...state.puzzle.tiles.where(
            (e) => ![event.fromTile.chessPiece.id, event.toTile.chessPiece.id]
                .contains(e.chessPiece.id),
          ),
          event.toTile.copyWith(
            currentPosition: event.toTile.currentPosition,
            chessPiece: promotedPiece ??
                event.fromTile.chessPiece
                    .copyWith(id: event.toTile.chessPiece.id),
          ),
          event.fromTile.copyWith(
            currentPosition: event.fromTile.currentPosition,
            chessPiece: event.fromTile.chessPiece.copyWith(
              type: ChessPieceType.empty,
              color: ChessPieceColor.none,
            ),
          ),
        ],
      ),
      draggingTile: const NullableCopy(null),
    );
    emit(
      newState.copyWith(
        puzzle: newState.puzzle.sort(),
      ),
    );
  }

  void _onTileTapped(TileTapped event, Emitter<PuzzleState> emit) {
    final tappedTile = event.tile;
    if (state.puzzleResult == PuzzleResult.undecided) {
      if (state.puzzle.isTileMovable(tappedTile)) {
        // Cannot slide tile to get out of checks
        if (state.isCurrentMoveColorKingInCheck) {
          showMessage('Cannot slide to get out of checks!');
          return;
        }
        final mutablePuzzle = Puzzle(tiles: [...state.puzzle.tiles]);
        final puzzle = mutablePuzzle.moveTiles(tappedTile, []);
        final colorToMove = state.colorToMove == ChessPieceColor.white
            ? ChessPieceColor.black
            : ChessPieceColor.white;
        emit(
          state.copyWith(
            puzzle: puzzle.sort(),
            tileMovementStatus: TileMovementStatus.moved,
            colorToMove: colorToMove,
            lastTappedTile: tappedTile,
          ),
        );
      } else {
        emit(
          state.copyWith(tileMovementStatus: TileMovementStatus.cannotBeMoved),
        );
      }
    } else {
      emit(
        state.copyWith(tileMovementStatus: TileMovementStatus.cannotBeMoved),
      );
    }
  }

  void _onPuzzleReset(PuzzleReset event, Emitter<PuzzleState> emit) {
    final puzzle = _generatePuzzle(_size);
    emit(
      PuzzleState(
        puzzle: puzzle.sort(),
      ),
    );
  }

  /// Build a randomized, solvable puzzle of the given size.
  Puzzle _generatePuzzle(int size) {
    final correctPositions = <Position>[];
    final currentPositions = <Position>[];
    final whitespaceCoordinate = (size / 2).floor() + 1;
    final whitespacePosition =
        Position(x: whitespaceCoordinate, y: whitespaceCoordinate);

    // Create all possible board positions.
    for (var y = 1; y <= size; y++) {
      for (var x = 1; x <= size; x++) {
        if (x == whitespaceCoordinate && y == whitespaceCoordinate) {
          correctPositions.add(whitespacePosition);
          currentPositions.add(whitespacePosition);
        } else {
          final position = Position(x: x, y: y);
          correctPositions.add(position);
          currentPositions.add(position);
        }
      }
    }

    final tiles = _getTileListFromPositions(
      size,
      correctPositions,
    );

    final puzzle = Puzzle(tiles: tiles);

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<Tile> _getTileListFromPositions(
    int size,
    List<Position> currentPositions,
  ) {
    final whitespaceCoordinate = (size / 2).floor() + 1;
    final chessPieceFactory = ChessPieceFactory();
    return [
      for (int i = 1; i <= size * size; i++)
        if (i == size * (whitespaceCoordinate - 1) + whitespaceCoordinate)
          Tile(
            value: ChessPiece.empty(i).toString(),
            currentPosition: currentPositions[i - 1],
            isWhitespace: true,
          )
        else
          Tile(
            value: chessPieceFactory
                .getPiece(index: i, maxIndex: size * size)
                .toString(),
            currentPosition: currentPositions[i - 1],
          )
    ];
  }
}

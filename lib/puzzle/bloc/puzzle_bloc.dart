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
  PuzzleBloc({
    this.random,
  }) : super(const PuzzleState()) {
    on<PuzzleInitialized>(_onPuzzleInitialized);
    on<TileTapped>(_onTileTapped);
    on<PuzzleReset>(_onPuzzleReset);
    on<TileDragStarted>(_onTileDragStarted);
    on<TileDragEnded>(_onTileDragEnded);
    on<TileDropped>(_onTileDropped);
    on<PuzzleEnded>(_onPuzzleEnded);
    on<PuzzleChangeLevel>(_onPuzzleNextLevel);
    on<PuzzleNewMode>(_onPuzzleNewMode);
  }

  final Random? random;

  void _onPuzzleInitialized(
    PuzzleInitialized event,
    Emitter<PuzzleState> emit,
  ) {
    final puzzle = _generatePuzzle(state.factory.boardSize);
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
    bool autoPromote = false,
  }) {
    if (autoPromote) {
      return Future.value(
        ChessPiece(id, color: color, type: ChessPieceType.queen),
      );
    }
    return showDialog<ChessPiece>(
      context: navKey.currentContext!,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          content: Row(
            children: [
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
                      'assets/images/chess/Chess_${e.pieceSymbol}${e.colorCode}t45.svg',
                    ),
                  ),
                )
                .toList(),
          ),
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

  void _onPuzzleNextLevel(
    PuzzleChangeLevel event,
    Emitter<PuzzleState> emit,
  ) {
    final newFactory = event.factory;
    final puzzle = _generatePuzzle(newFactory.boardSize, factory: newFactory);
    emit(
      PuzzleState(
        factory: newFactory,
        puzzle: puzzle.sort(),
      ),
    );
  }

  void _onPuzzleNewMode(
    PuzzleNewMode event,
    Emitter<PuzzleState> emit,
  ) {
    final puzzle = _generatePuzzle(state.factory.boardSize);
    emit(
      PuzzleState(
        mode: event.mode,
        factory: state.factory,
        puzzle: puzzle.sort(),
      ),
    );
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
          autoPromote: event.autoPromote,
        );
      }
      if (event.fromTile.chessPiece.color == ChessPieceColor.black &&
          event.toTile.currentPosition.y == boardSize) {
        promotedPiece = await promotePawn(
          color: ChessPieceColor.black,
          id: event.toTile.chessPiece.id,
          autoPromote: event.autoPromote,
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
    moveMapCache.clear();
    emit(
      newState.copyWith(
        puzzle: newState.puzzle.sort(),
      ),
    );
    if (state.mode == PuzzleMode.puzzle) {
      _engineMoveForBlack();
    }
  }

  void _onTileTapped(TileTapped event, Emitter<PuzzleState> emit) {
    final tappedTile = event.tile;
    if (state.puzzleResult == PuzzleResult.undecided) {
      if (state.puzzle.isTileMovable(tappedTile)) {
        // Cannot slide tile to get out of checks
        if (state.isCurrentMoveColorKingInCheck) {
          showMessage('Cannot slide to get out of a check!');
          return;
        }
        final mutablePuzzle = Puzzle(tiles: [...state.puzzle.tiles]);
        final puzzle = mutablePuzzle.moveTiles(tappedTile, []);
        final colorToMove = state.colorToMove == ChessPieceColor.white
            ? ChessPieceColor.black
            : ChessPieceColor.white;
        final newState = state.copyWith(
          puzzle: puzzle.sort(),
        );
        if (newState.isCurrentMoveColorKingInCheck) {
          showMessage('Cannot slide into a check!');
          return;
        }
        moveMapCache.clear();
        emit(
          newState.copyWith(
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
    if (state.mode == PuzzleMode.puzzle) {
      _engineMoveForBlack();
    }
  }

  bool checkInsufficientMaterial() {
    if (state.puzzleResult != PuzzleResult.undecided) {
      return false;
    }
    if (state.puzzle.tiles.every(
      (e) => [ChessPieceType.empty, ChessPieceType.king]
          .contains(e.chessPiece.type),
    )) {
      return true;
    }
    return false;
  }

  int timesTheTileIsDefended(Tile tile, ChessPieceColor color) {
    return state.puzzle.tiles
        .where(
          (e) =>
              e.chessPiece.color == color &&
              e.chessPiece.canMove(
                state,
                fromTile: e,
                toTile: e,
                checkPiece: false,
                checkTurn: false,
              ),
        )
        .length;
  }

  // TODO: improve engine
  void _engineMoveForBlack() {
    if (state.puzzleResult != PuzzleResult.undecided ||
        state.colorToMove != ChessPieceColor.black) {
      return;
    }
    if (checkInsufficientMaterial()) {
      add(const PuzzleEnded(PuzzleResult.draw));
      return;
    }

    final moveCandidates = <TileDropped, int>{};
    // Take the legal drop move that wins the most material
    // or undefended check
    for (final fromTile in state.puzzle.tiles
        .where((e) => e.chessPiece.color == state.colorToMove)) {
      for (final toTile in state.puzzle.tiles.where(
        (e) => !e.isWhitespace && e.chessPiece.color != state.colorToMove,
      )) {
        if (fromTile.chessPiece.canMove(
          state,
          fromTile: fromTile,
          toTile: toTile,
        )) {
          moveCandidates[TileDropped(
            fromTile,
            toTile,
            autoPromote: true,
          )] = toTile.chessPiece.pieceValue;
        }
      }
    }
    if (moveCandidates.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        final maxValue = moveCandidates.values.fold(0, max);
        add(
          moveCandidates.entries.firstWhere((e) => e.value == maxValue).key,
        );
      });
    } else {
      var result = PuzzleResult.draw;
      if (state.isCurrentMoveColorKingInCheck) {
        result = state.colorJustMoved == ChessPieceColor.white
            ? PuzzleResult.whiteWin
            : PuzzleResult.blackWin;
      }
      add(PuzzleEnded(result));
    }
  }

  void _onPuzzleReset(PuzzleReset event, Emitter<PuzzleState> emit) {
    final puzzle = _generatePuzzle(
      state.factory.boardSize,
    );
    emit(
      PuzzleState(
        factory: state.factory,
        puzzle: puzzle.sort(),
        mode: state.mode,
      ),
    );
  }

  /// Build a randomized, solvable puzzle of the given size.
  Puzzle _generatePuzzle(
    int size, {
    ChessPieceFactory? factory,
  }) {
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
      factory: factory,
    );

    final puzzle = Puzzle(tiles: tiles);

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<Tile> _getTileListFromPositions(
    int size,
    List<Position> currentPositions, {
    ChessPieceFactory? factory,
  }) {
    final whitespaceCoordinate = (size / 2).floor() + 1;
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
            value: (factory ?? state.factory)
                .getPiece(index: i, maxIndex: size * size)
                .toString(),
            currentPosition: currentPositions[i - 1],
          )
    ];
  }
}

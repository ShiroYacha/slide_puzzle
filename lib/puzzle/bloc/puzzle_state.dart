// ignore_for_file: public_member_api_docs

part of 'puzzle_bloc.dart';

enum PuzzleStatus { incomplete, complete }

enum TileMovementStatus { nothingTapped, cannotBeMoved, moved }

enum PuzzleMoveOrder {
  white,
  black,
}

enum PuzzleResult {
  undecided,
  whiteWin,
  blackWin,
  drawByStalement,
  drawByInsufficientMaterial,
}

class PuzzleState extends Equatable {
  const PuzzleState({
    this.puzzle = const Puzzle(tiles: []),
    this.puzzleStatus = PuzzleStatus.incomplete,
    this.puzzleResult = PuzzleResult.undecided,
    this.tileMovementStatus = TileMovementStatus.nothingTapped,
    this.colorToMove = ChessPieceColor.white,
    this.lastTappedTile,
    this.draggingTile,
  });

  /// [Puzzle] containing the current tile arrangement.
  final Puzzle puzzle;

  /// Status indicating the current state of the puzzle.
  final PuzzleStatus puzzleStatus;

  /// Status indicating if a [Tile] was moved or why a [Tile] was not moved.
  final TileMovementStatus tileMovementStatus;

  final Tile? draggingTile;

  /// Represents the last tapped tile of the puzzle.
  ///
  /// The value is `null` if the user has not interacted with
  /// the puzzle yet.
  final Tile? lastTappedTile;

  /// Current color to move
  final ChessPieceColor colorToMove;

  /// Result of the puzzle
  final PuzzleResult puzzleResult;

  PuzzleState copyWith({
    Puzzle? puzzle,
    PuzzleStatus? puzzleStatus,
    PuzzleResult? puzzleResult,
    TileMovementStatus? tileMovementStatus,
    ChessPieceColor? colorToMove,
    Tile? lastTappedTile,
    NullableCopy<Tile>? draggingTile,
  }) {
    return PuzzleState(
      puzzle: puzzle ?? this.puzzle,
      puzzleStatus: puzzleStatus ?? this.puzzleStatus,
      puzzleResult: puzzleResult ?? this.puzzleResult,
      tileMovementStatus: tileMovementStatus ?? this.tileMovementStatus,
      colorToMove: colorToMove ?? this.colorToMove,
      lastTappedTile: lastTappedTile ?? this.lastTappedTile,
      draggingTile: NullableCopy.resolve(
        draggingTile,
        orElse: this.draggingTile,
      ),
    );
  }

  @override
  List<Object?> get props => [
        puzzle,
        puzzleStatus,
        tileMovementStatus,
        colorToMove,
        lastTappedTile,
        draggingTile,
      ];

  bool isTileAttackedByAnyPiece({
    required Tile toTile,
    required ChessPieceColor color,
  }) {
    return puzzle.tiles.any(
      (e) =>
          e.chessPiece.color != color &&
          e.chessPiece.type != ChessPieceType.empty &&
          e.chessPiece.canCapture(
            this,
            fromTile: e,
            toTile: toTile,
            checkKingSafety: false,
            checkPiece: false,
            checkTurn: false,
          ),
    );
  }
}

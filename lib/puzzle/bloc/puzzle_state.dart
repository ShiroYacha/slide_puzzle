// ignore_for_file: public_member_api_docs

part of 'puzzle_bloc.dart';

enum PuzzleStatus { incomplete, complete }

enum TileMovementStatus { nothingTapped, cannotBeMoved, moved, dropped }

enum PuzzleMoveOrder {
  white,
  black,
}

enum PuzzleResult {
  undecided,
  whiteWin,
  blackWin,
  draw,
}

enum PuzzleMode {
  puzzle,
  pvpRandom,
  pvpLocal,
  pvpInvite,
}

class PuzzleState extends Equatable {
  const PuzzleState({
    this.puzzle = const Puzzle(tiles: []),
    this.puzzleResult = PuzzleResult.undecided,
    this.tileMovementStatus = TileMovementStatus.nothingTapped,
    this.colorToMove = ChessPieceColor.white,
    this.lastTappedTile,
    this.draggingTile,
    this.factory = defaultFactory,
    this.mode = PuzzleMode.puzzle,
  });

  /// [Puzzle] containing the current tile arrangement.
  final Puzzle puzzle;

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

  /// Current factory
  final ChessPieceFactory factory;

  /// The current mode
  final PuzzleMode mode;

  PuzzleState copyWith({
    Puzzle? puzzle,
    PuzzleResult? puzzleResult,
    TileMovementStatus? tileMovementStatus,
    ChessPieceColor? colorToMove,
    Tile? lastTappedTile,
    NullableCopy<Tile>? draggingTile,
    ChessPieceFactory? factory,
    PuzzleMode? mode,
  }) {
    return PuzzleState(
      puzzle: puzzle ?? this.puzzle,
      puzzleResult: puzzleResult ?? this.puzzleResult,
      tileMovementStatus: tileMovementStatus ?? this.tileMovementStatus,
      colorToMove: colorToMove ?? this.colorToMove,
      lastTappedTile: lastTappedTile ?? this.lastTappedTile,
      factory: factory ?? this.factory,
      draggingTile: NullableCopy.resolve(
        draggingTile,
        orElse: this.draggingTile,
      ),
      mode: mode ?? this.mode,
    );
  }

  bool get canGotoPreviousFactory => chessPieceFactories.first != factory;
  bool get canGotoNextFactory => chessPieceFactories.last != factory;
  ChessPieceFactory get previousFactory =>
      chessPieceFactories[chessPieceFactories.indexOf(factory) - 1];
  ChessPieceFactory get nextFactory =>
      chessPieceFactories[chessPieceFactories.indexOf(factory) + 1];
  String get tileHash => puzzle.tiles.map((e) => e.value).join(',');

  @override
  List<Object?> get props => [
        puzzle,
        puzzleResult,
        tileMovementStatus,
        colorToMove,
        lastTappedTile,
        draggingTile,
        factory,
        mode,
      ];

  ChessPieceColor get colorJustMoved => colorToMove == ChessPieceColor.white
      ? ChessPieceColor.black
      : ChessPieceColor.white;

  bool get isCurrentMoveColorKingInCheck {
    final currentKingTile = puzzle.tiles.singleWhere(
      (e) =>
          e.chessPiece.type == ChessPieceType.king &&
          e.chessPiece.color == colorToMove,
    );
    return isTileAttackedByAnyPiece(
      toTile: currentKingTile,
      color: colorToMove,
    );
  }

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

  bool hasAnyTileBetweenStraightOrDiagonaleLine({
    required Tile fromTile,
    required Tile toTile,
  }) {
    if (fromTile.currentPosition.x == toTile.currentPosition.x) {
      final minY = min(fromTile.currentPosition.y, toTile.currentPosition.y);
      final maxY = max(fromTile.currentPosition.y, toTile.currentPosition.y);
      return puzzle.tiles.any(
        (e) =>
            (e.isWhitespace || e.chessPiece.type != ChessPieceType.empty) &&
            e.currentPosition.x == fromTile.currentPosition.x &&
            e.currentPosition.y > minY &&
            e.currentPosition.y < maxY,
      );
    } else if (fromTile.currentPosition.y == toTile.currentPosition.y) {
      final minX = min(fromTile.currentPosition.x, toTile.currentPosition.x);
      final maxX = max(fromTile.currentPosition.x, toTile.currentPosition.x);
      return puzzle.tiles.any(
        (e) =>
            (e.isWhitespace || e.chessPiece.type != ChessPieceType.empty) &&
            e.currentPosition.y == fromTile.currentPosition.y &&
            e.currentPosition.x > minX &&
            e.currentPosition.x < maxX,
      );
    } else if ((fromTile.currentPosition.x - toTile.currentPosition.x).abs() ==
        (fromTile.currentPosition.y - toTile.currentPosition.y).abs()) {
      final minY = min(fromTile.currentPosition.y, toTile.currentPosition.y);
      final maxY = max(fromTile.currentPosition.y, toTile.currentPosition.y);
      final minX = min(fromTile.currentPosition.x, toTile.currentPosition.x);
      final maxX = max(fromTile.currentPosition.x, toTile.currentPosition.x);
      return puzzle.tiles.any(
        (e) =>
            (e.isWhitespace || e.chessPiece.type != ChessPieceType.empty) &&
            e.currentPosition.x > minX &&
            e.currentPosition.x < maxX &&
            e.currentPosition.y > minY &&
            e.currentPosition.y < maxY &&
            ((e.currentPosition.x - minX) / (e.currentPosition.y - minY))
                    .abs() ==
                ((maxX - minX) / (maxY - minY)).abs(),
      );
    }
    return false;
  }
}

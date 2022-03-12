// ignore_for_file: public_member_api_docs

part of 'puzzle_bloc.dart';

abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object> get props => [];
}

class PuzzleInitialized extends PuzzleEvent {
  const PuzzleInitialized();

  @override
  List<Object> get props => [];
}

class TileTapped extends PuzzleEvent {
  const TileTapped(this.tile);

  final Tile tile;

  @override
  List<Object> get props => [tile];
}

class TileDragStarted extends PuzzleEvent {
  const TileDragStarted(this.tile);

  final Tile tile;

  @override
  List<Object> get props => [tile];
}

class TileDropped extends PuzzleEvent {
  const TileDropped(
    this.fromTile,
    this.toTile,
    this.boardSize,
  );

  final int boardSize;
  final Tile fromTile;
  final Tile toTile;

  @override
  List<Object> get props => [fromTile, toTile, boardSize];
}

class TileDragEnded extends PuzzleEvent {
  const TileDragEnded(this.tile);

  final Tile tile;

  @override
  List<Object> get props => [tile];
}

class PuzzleReset extends PuzzleEvent {
  const PuzzleReset();
}

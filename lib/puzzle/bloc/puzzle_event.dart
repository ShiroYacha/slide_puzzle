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

class PuzzleEnded extends PuzzleEvent {
  const PuzzleEnded(this.result);

  final PuzzleResult result;

  @override
  List<Object> get props => [result];
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
    this.toTile, {
    this.autoPromote = false,
  });

  final Tile fromTile;
  final Tile toTile;
  final bool autoPromote;

  @override
  List<Object> get props => [fromTile, toTile, autoPromote];
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

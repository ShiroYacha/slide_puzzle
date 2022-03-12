import 'package:equatable/equatable.dart';
import 'package:very_good_slide_puzzle/chess/chess_piece.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

/// {@template tile}
/// Model for a puzzle tile.
/// {@endtemplate}
class Tile extends Equatable {
  /// {@macro tile}
  const Tile({
    required this.value,
    required this.currentPosition,
    this.isWhitespace = false,
  });

  /// Value representing the correct position of [Tile] in a list.
  final String value;

  /// The current 2D [Position] of the [Tile].
  final Position currentPosition;

  /// Denotes if the [Tile] is the whitespace tile or not.
  final bool isWhitespace;

  /// Create a copy of this [Tile] with updated current position.
  Tile copyWith({
    Position? currentPosition,
    ChessPiece? chessPiece,
  }) {
    return Tile(
      value: chessPiece?.toString() ?? value,
      currentPosition: currentPosition ?? this.currentPosition,
      isWhitespace: isWhitespace,
    );
  }

  @override
  List<Object> get props => [
        value,
        currentPosition,
        isWhitespace,
      ];

  /// If the tile represents a number
  bool get isInt => int.tryParse(value) != null;

  /// The tiles int value
  int get intValue => int.parse(value);

  /// The underlying chess piece
  ChessPiece get chessPiece => ChessPiece.fromString(value);
}

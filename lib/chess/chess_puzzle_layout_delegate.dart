import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:very_good_slide_puzzle/chess/chess.dart';
import 'package:very_good_slide_puzzle/chess/chess_piece.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';

/// {@template chess_puzzle_layout_delegate}
/// A delegate for computing the layout of the puzzle UI
/// that uses a [ChessTheme].
/// {@endtemplate}
class ChessPuzzleLayoutDelegate extends PuzzleLayoutDelegate {
  /// {@macro chess_puzzle_layout_delegate}
  const ChessPuzzleLayoutDelegate();

  @override
  Widget startSectionBuilder(PuzzleState state) {
    return ResponsiveLayoutBuilder(
      small: (_, child) => child!,
      medium: (_, child) => child!,
      large: (_, child) => Padding(
        padding: const EdgeInsets.only(left: 50, right: 32),
        child: child,
      ),
      child: (_) => ChessStartSection(state: state),
    );
  }

  @override
  Widget endSectionBuilder(PuzzleState state) {
    return Column(
      children: [
        const ResponsiveGap(
          small: 32,
          medium: 48,
        ),
        ResponsiveLayoutBuilder(
          small: (_, child) => const ChessPuzzleShuffleButton(),
          medium: (_, child) => const ChessPuzzleShuffleButton(),
          large: (_, __) => const SizedBox(),
        ),
        const ResponsiveGap(
          small: 32,
          medium: 48,
        ),
      ],
    );
  }

  @override
  Widget backgroundBuilder(PuzzleState state) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: ResponsiveLayoutBuilder(
        small: (_, __) => SizedBox(
          width: 184,
          height: 118,
          child: Image.asset(
            'assets/images/simple_dash_small.png',
            key: const Key('chess_puzzle_dash_small'),
          ),
        ),
        medium: (_, __) => SizedBox(
          width: 380.44,
          height: 214,
          child: Image.asset(
            'assets/images/simple_dash_medium.png',
            key: const Key('chess_puzzle_dash_medium'),
          ),
        ),
        large: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 53),
          child: SizedBox(
            width: 568.99,
            height: 320,
            child: Image.asset(
              'assets/images/simple_dash_large.png',
              key: const Key('chess_puzzle_dash_large'),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget boardBuilder(int size, List<Widget> tiles) {
    return Column(
      children: [
        const ResponsiveGap(
          small: 32,
          medium: 48,
          large: 96,
        ),
        ResponsiveLayoutBuilder(
          small: (_, __) => SizedBox.square(
            dimension: _BoardSize.small,
            child: ChessPuzzleBoard(
              key: const Key('chess_puzzle_board_small'),
              size: size,
              tiles: tiles,
              spacing: 5,
            ),
          ),
          medium: (_, __) => SizedBox.square(
            dimension: _BoardSize.medium,
            child: ChessPuzzleBoard(
              key: const Key('chess_puzzle_board_medium'),
              size: size,
              tiles: tiles,
            ),
          ),
          large: (_, __) => SizedBox.square(
            dimension: _BoardSize.large,
            child: ChessPuzzleBoard(
              key: const Key('chess_puzzle_board_large'),
              size: size,
              tiles: tiles,
            ),
          ),
        ),
        const ResponsiveGap(
          large: 96,
        ),
      ],
    );
  }

  @override
  Widget tileBuilder(Tile tile, PuzzleState state) {
    return ResponsiveLayoutBuilder(
      small: (_, __) => ChessPuzzleTile(
        key: Key('chess_puzzle_tile_${tile.value}_small'),
        tile: tile,
        tileFontSize: _TileFontSize.small,
        state: state,
      ),
      medium: (_, __) => ChessPuzzleTile(
        key: Key('chess_puzzle_tile_${tile.value}_medium'),
        tile: tile,
        tileFontSize: _TileFontSize.medium,
        state: state,
      ),
      large: (_, __) => ChessPuzzleTile(
        key: Key('chess_puzzle_tile_${tile.value}_large'),
        tile: tile,
        tileFontSize: _TileFontSize.large,
        state: state,
      ),
    );
  }

  @override
  Widget whitespaceTileBuilder() {
    return const SizedBox();
  }

  @override
  List<Object?> get props => [];
}

/// {@template chess_start_section}
/// Displays the start section of the puzzle based on [state].
/// {@endtemplate}
@visibleForTesting
class ChessStartSection extends StatelessWidget {
  /// {@macro chess_start_section}
  const ChessStartSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  /// The state of the puzzle.
  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveGap(
          small: 20,
          medium: 83,
          large: 151,
        ),
        PuzzleName(
          key: puzzleNameKey,
        ),
        const ResponsiveGap(large: 16),
        ChessPuzzleTitle(
          status: state.puzzleStatus,
        ),
        const ResponsiveGap(
          small: 12,
          medium: 16,
          large: 32,
        ),
        ColorToMoveAndResult(
          key: ColorToMoveAndResultKey,
          colorToMove: state.colorToMove,
        ),
        const ResponsiveGap(
          large: 32,
          small: 16,
        ),
        ResponsiveLayoutBuilder(
          small: (_, __) => const SizedBox(),
          medium: (_, __) => const SizedBox(),
          large: (_, __) => const ChessPuzzleShuffleButton(),
        ),
      ],
    );
  }
}

/// {@template chess_puzzle_title}
/// Displays the title of the puzzle based on [status].
///
/// Shows the success state when the puzzle is completed,
/// otherwise defaults to the Puzzle Challenge title.
/// {@endtemplate}
@visibleForTesting
class ChessPuzzleTitle extends StatelessWidget {
  /// {@macro chess_puzzle_title}
  const ChessPuzzleTitle({
    Key? key,
    required this.status,
  }) : super(key: key);

  /// The status of the puzzle.
  final PuzzleStatus status;

  @override
  Widget build(BuildContext context) {
    return PuzzleTitle(
      key: puzzleTitleKey,
      title: status == PuzzleStatus.complete
          ? context.l10n.puzzleCompleted
          : context.l10n.puzzleChallengeTitle,
    );
  }
}

abstract class _BoardSize {
  static double small = 312;
  static double medium = 424;
  static double large = 472;
}

/// {@template chess_puzzle_board}
/// Display the board of the puzzle in a [size]x[size] layout
/// filled with [tiles]. Each tile is spaced with [spacing].
/// {@endtemplate}
@visibleForTesting
class ChessPuzzleBoard extends StatelessWidget {
  /// {@macro chess_puzzle_board}
  const ChessPuzzleBoard({
    Key? key,
    required this.size,
    required this.tiles,
    this.spacing = 8,
  }) : super(key: key);

  /// The size of the board.
  final int size;

  /// The tiles to be displayed on the board.
  final List<Widget> tiles;

  /// The spacing between each tile from [tiles].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: size,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: tiles,
    );
  }
}

abstract class _TileFontSize {
  static double small = 36;
  static double medium = 50;
  static double large = 54;
}

/// {@template chess_puzzle_tile}
/// Displays the puzzle tile associated with [tile] and
/// the font size of [tileFontSize] based on the puzzle [state].
/// {@endtemplate}
@visibleForTesting
class ChessPuzzleTile extends StatelessWidget {
  /// {@macro chess_puzzle_tile}
  const ChessPuzzleTile({
    Key? key,
    required this.tile,
    required this.tileFontSize,
    required this.state,
  }) : super(key: key);

  /// The tile to be displayed.
  final Tile tile;

  /// The font size of the tile to be displayed.
  final double tileFontSize;

  /// The state of the puzzle.
  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final puzzleState = context.select((PuzzleBloc bloc) => bloc.state);
    final chessPiece = tile.chessPiece;
    final size = sqrt(puzzleState.puzzle.tiles.length).floor();
    return LayoutBuilder(
      builder: (context, constraints) {
        return DragTarget<Tile>(
          onWillAccept: (draggingTile) {
            return draggingTile?.chessPiece.canMove(puzzleState,
                    fromTile: draggingTile, toTile: tile) ==
                true;
          },
          onAccept: (draggingTile) {
            context.read<PuzzleBloc>().add(
                  TileDropped(
                    draggingTile,
                    tile,
                    size,
                  ),
                );
          },
          builder: (context, candidateItems, rejectedItems) {
            return LongPressDraggable<Tile>(
              data: tile,
              delay: const Duration(milliseconds: 250),
              dragAnchorStrategy: childDragAnchorStrategy,
              feedback: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: chessPiece.build(context),
              ),
              onDragStarted: () {
                context.read<PuzzleBloc>().add(TileDragStarted(tile));
              },
              onDragEnd: (d) {
                context.read<PuzzleBloc>().add(TileDragEnded(tile));
              },
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: PuzzleColors.white,
                  textStyle: PuzzleTextStyle.headline2.copyWith(
                    fontSize: tileFontSize,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                ).copyWith(
                  foregroundColor:
                      MaterialStateProperty.all(PuzzleColors.white),
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      Color color;
                      if (tile.chessPiece.type == ChessPieceType.king &&
                          state.isTileAttackedByAnyPiece(
                            toTile: tile,
                            color: tile.chessPiece.color,
                          )) {
                        return PuzzleColors.yellow50;
                      }
                      if (state.draggingTile?.chessPiece.canMove(
                            puzzleState,
                            fromTile: state.draggingTile!,
                            toTile: tile,
                          ) ==
                          true) {
                        return theme.secondaryColor;
                      }
                      if (states.contains(MaterialState.hovered)) {
                        return theme.hoverColor;
                      } else {
                        color = theme.defaultColor;
                      }
                      if (tile.currentPosition.toCoordinate(size).isOdd) {
                        return color;
                      } else {
                        return _lighten(color, 0.2);
                      }
                    },
                  ),
                ),
                onPressed: state.puzzleStatus == PuzzleStatus.incomplete
                    ? () => context.read<PuzzleBloc>().add(TileTapped(tile))
                    : null,
                child: chessPiece.type == ChessPieceType.empty
                    ? Container()
                    : chessPiece.build(context),
              ),
            );
          },
        );
      },
    );
  }
}

Color _darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1, 'amount should be between 0 and 1');

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color _lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1, 'amount should be between 0 and 1');

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

/// {@template puzzle_shuffle_button}
/// Displays the button to shuffle the puzzle.
/// {@endtemplate}
@visibleForTesting
class ChessPuzzleShuffleButton extends StatelessWidget {
  /// {@macro puzzle_shuffle_button}
  const ChessPuzzleShuffleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PuzzleButton(
      textColor: PuzzleColors.primary0,
      backgroundColor: PuzzleColors.primary6,
      onPressed: () => context.read<PuzzleBloc>().add(const PuzzleReset()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/shuffle_icon.png',
            width: 17,
            height: 17,
          ),
          const Gap(10),
          Text(context.l10n.puzzleReset),
        ],
      ),
    );
  }
}
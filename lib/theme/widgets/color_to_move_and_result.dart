import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:very_good_slide_puzzle/chess/chess_piece.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';

/// {@template number_of_moves_and_tiles_left}
/// Displays how many moves have been made on the current puzzle
/// and how many puzzle tiles are not in their correct position.
/// {@endtemplate}
class ColorToMoveAndResult extends StatelessWidget {
  /// {@macro number_of_moves_and_tiles_left}
  const ColorToMoveAndResult({
    Key? key,
    required this.colorToMove,
    this.color,
  }) : super(key: key);

  /// The current color to move
  final ChessPieceColor colorToMove;

  /// The color of texts that display [colorToMove].
  /// Defaults to [PuzzleTheme.defaultColor].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final l10n = context.l10n;
    final textColor = color ?? theme.defaultColor;

    return ResponsiveLayoutBuilder(
      small: (context, child) => Center(child: child),
      medium: (context, child) => Center(child: child),
      large: (context, child) => child!,
      child: (currentSize) {
        final mainAxisAlignment = currentSize == ResponsiveLayoutSize.large
            ? MainAxisAlignment.start
            : MainAxisAlignment.center;

        final bodyTextStyle = currentSize == ResponsiveLayoutSize.small
            ? PuzzleTextStyle.bodySmall
            : PuzzleTextStyle.body;

        return Semantics(
          label: l10n.puzzleColorToMoveAndResultLabelText(
            colorToMove.toString(),
          ),
          child: ExcludeSemantics(
            child: Row(
              key: const Key('color_to_move_row'),
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AnimatedDefaultTextStyle(
                  key: const Key('color_to_move'),
                  style: PuzzleTextStyle.headline4.copyWith(
                    color: textColor,
                  ),
                  duration: PuzzleThemeAnimationDuration.textStyle,
                  child: Text(toBeginningOfSentenceCase(colorToMove.name)!),
                ),
                AnimatedDefaultTextStyle(
                  style: bodyTextStyle.copyWith(
                    color: textColor,
                  ),
                  duration: PuzzleThemeAnimationDuration.textStyle,
                  child: const Text(' to move'),
                ),
                // AnimatedDefaultTextStyle(
                //   style: bodyTextStyle.copyWith(
                //     color: textColor,
                //   ),
                //   duration: PuzzleThemeAnimationDuration.textStyle,
                //   child: Text(' ${l10n.puzzleNumberOfTilesLeft}'),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';

/// {@template puzzle_name}
/// Displays the name of the current puzzle theme.
/// Visible only on a large layout.
/// {@endtemplate}
class PuzzleName extends StatelessWidget {
  /// {@macro puzzle_name}
  const PuzzleName({
    Key? key,
    this.color,
  }) : super(key: key);

  /// The color of this name, defaults to [PuzzleTheme.nameColor].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);
    final bloc = context.read<PuzzleBloc>();
    final nameColor = color ?? theme.nameColor;
    final text = AnimatedDefaultTextStyle(
      style: PuzzleTextStyle.headline5.copyWith(
        color: nameColor,
      ),
      duration: PuzzleThemeAnimationDuration.textStyle,
      child: RichText(
        key: const Key('puzzle_name_theme'),
        text: TextSpan(
          style: PuzzleTextStyle.headline5.copyWith(
            color: nameColor,
          ),
          children: [
            if (state.canGotoPreviousFactory)
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2, right: 8),
                  child: GestureDetector(
                    onTap: () {
                      bloc.add(PuzzleChangeLevel(state.previousFactory));
                    },
                    child: const Icon(
                      Icons.arrow_circle_left,
                      size: 18,
                      color: PuzzleColors.white,
                    ),
                  ),
                ),
              ),
            TextSpan(
              text: state.factory.name,
              style: PuzzleTextStyle.headline5.copyWith(
                color: nameColor,
              ),
            ),
            if (state.canGotoNextFactory)
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2, left: 8),
                  child: GestureDetector(
                    onTap: () {
                      bloc.add(PuzzleChangeLevel(state.nextFactory));
                    },
                    child: const Icon(
                      Icons.arrow_circle_right,
                      size: 18,
                      color: PuzzleColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return ResponsiveLayoutBuilder(
      small: (context, child) => Center(child: text),
      medium: (context, child) => Center(child: text),
      large: (context, child) => text,
    );
  }
}

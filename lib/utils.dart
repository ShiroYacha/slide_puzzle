// ignore_for_file: public_member_api_docs

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/app/view/app.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';

class NullableCopy<T> {
  const NullableCopy(this.data);

  final T? data;

  static T? resolve<T>(NullableCopy<T>? value, {T? orElse}) {
    if (value == null) return orElse;
    return value.isNull ? null : value.data;
  }

  bool get isNull => data == null;
}

extension WidgetMouseExtension on Widget {
  Widget get asMouseClickRegion => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: this,
      );
}

void showMessage(String message) {
  BotToast.showNotification(title: (_) => Text(message));
}

Future<void> showTutorial() {
  return showDialog<void>(
    context: navKey.currentContext!,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: RichText(
          text: TextSpan(
            children: [
              const WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 0, right: 12),
                  child: Icon(
                    Icons.help,
                    color: PuzzleColors.white,
                    size: 32,
                  ),
                ),
              ),
              TextSpan(
                text: 'How to play',
                style: theme.textTheme.headline4?.copyWith(
                  color: PuzzleColors.white,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              """
It's basically chess with a small twist: 
""",
              style: theme.textTheme.headline6?.copyWith(
                color: PuzzleColors.white,
              ),
            ),
            ...[
              '''
Instead of moving a piece, you can slide tile(s) as in the sliding puzzle. By
tapping a tile in the same axis as the missing "hole". ''',
              'You cannot slide tile(s) into or out of checks.',
              'No piece can move pass the missing "hole" (except Knight)'
            ].map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 6, right: 12),
                          child: Icon(
                            Icons.circle,
                            color: PuzzleColors.white,
                            size: 12,
                          ),
                        ),
                      ),
                      TextSpan(
                        text: e,
                        style: theme.textTheme.headline5?.copyWith(
                          color: PuzzleColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black45,
        actions: [
          TextButton.icon(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(
              Icons.check_circle,
              color: PuzzleColors.blue50,
            ),
            label: Text(
              'Okay ',
              style: theme.textTheme.headline5?.copyWith(
                color: PuzzleColors.blue50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.all(8),
      );
    },
  );
}

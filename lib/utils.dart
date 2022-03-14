// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ionicons/ionicons.dart';
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
                  padding: EdgeInsets.only(right: 12),
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
        content: SizedBox(
          width: 500,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                """
It's basically chess with a small twist: 
""",
                style: theme.textTheme.headline6?.copyWith(
                  color: PuzzleColors.white,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 300,
                child: Image.asset('assets/images/sliding_chess_tutorial.gif'),
              ),
              ...{
                '''
Instead of moving a piece, you can slide tile(s) as in the sliding puzzle. By tapping a tile in the same axis as the missing "hole". ''':
                    const SizedBox.shrink(),
                'You cannot slide tile(s) into or out of checks.':
                    const SizedBox.shrink(),
                'No piece can move pass the missing "hole" (except Knight)':
                    const SizedBox.shrink(),
              }.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const WidgetSpan(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 2, right: 8),
                                    child: Icon(
                                      Ionicons.bulb,
                                      color: PuzzleColors.yellow90,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: e.key,
                                  style: theme.textTheme.headline6?.copyWith(
                                    color: PuzzleColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            child: e.value,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.symmetric(vertical: 50),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: PuzzleColors.blue50,
                  ),
                  const Gap(10),
                  Text(
                    'Okay',
                    style: theme.textTheme.headline5?.copyWith(
                      color: PuzzleColors.blue50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.all(8),
      );
    },
  );
}

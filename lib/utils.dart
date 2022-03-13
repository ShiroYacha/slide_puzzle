// ignore_for_file: public_member_api_docs

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/app/view/app.dart';

class NullableCopy<T> {
  const NullableCopy(this.data);

  final T? data;

  static T? resolve<T>(NullableCopy<T>? value, {T? orElse}) {
    if (value == null) return orElse;
    return value.isNull ? null : value.data;
  }

  bool get isNull => data == null;
}

void showMessage(String message) {
  final theme = Theme.of(navKey.currentContext!);
  BotToast.showText(text: message);
}

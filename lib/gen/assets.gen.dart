/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// ignore_for_file: directives_ordering,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsAudioGen {
  const $AssetsAudioGen();

  /// File path: assets/audio/click.mp3
  String get click => 'assets/audio/click.mp3';

  /// File path: assets/audio/dumbbell.mp3
  String get dumbbell => 'assets/audio/dumbbell.mp3';

  /// File path: assets/audio/sandwich.mp3
  String get sandwich => 'assets/audio/sandwich.mp3';

  /// File path: assets/audio/shuffle.mp3
  String get shuffle => 'assets/audio/shuffle.mp3';

  /// File path: assets/audio/skateboard.mp3
  String get skateboard => 'assets/audio/skateboard.mp3';

  /// File path: assets/audio/success.mp3
  String get success => 'assets/audio/success.mp3';

  /// File path: assets/audio/tile_move.mp3
  String get tileMove => 'assets/audio/tile_move.mp3';
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  $AssetsImagesAudioControlGen get audioControl =>
      const $AssetsImagesAudioControlGen();
  $AssetsImagesChessGen get chess => const $AssetsImagesChessGen();

  /// File path: assets/images/facebook_icon.png
  AssetGenImage get facebookIcon =>
      const AssetGenImage('assets/images/facebook_icon.png');

  /// File path: assets/images/logo_flutter_color.png
  AssetGenImage get logoFlutterColor =>
      const AssetGenImage('assets/images/logo_flutter_color.png');

  /// File path: assets/images/logo_flutter_white.png
  AssetGenImage get logoFlutterWhite =>
      const AssetGenImage('assets/images/logo_flutter_white.png');

  /// File path: assets/images/shuffle_icon.png
  AssetGenImage get shuffleIcon =>
      const AssetGenImage('assets/images/shuffle_icon.png');

  /// File path: assets/images/simple_dash_large.png
  AssetGenImage get simpleDashLarge =>
      const AssetGenImage('assets/images/simple_dash_large.png');

  /// File path: assets/images/simple_dash_medium.png
  AssetGenImage get simpleDashMedium =>
      const AssetGenImage('assets/images/simple_dash_medium.png');

  /// File path: assets/images/simple_dash_small.png
  AssetGenImage get simpleDashSmall =>
      const AssetGenImage('assets/images/simple_dash_small.png');

  /// File path: assets/images/timer_icon.png
  AssetGenImage get timerIcon =>
      const AssetGenImage('assets/images/timer_icon.png');

  /// File path: assets/images/twitter_icon.png
  AssetGenImage get twitterIcon =>
      const AssetGenImage('assets/images/twitter_icon.png');
}

class $AssetsImagesAudioControlGen {
  const $AssetsImagesAudioControlGen();

  /// File path: assets/images/audio_control/blue_dashatar_off.png
  AssetGenImage get blueDashatarOff =>
      const AssetGenImage('assets/images/audio_control/blue_dashatar_off.png');

  /// File path: assets/images/audio_control/dashatar_on.png
  AssetGenImage get dashatarOn =>
      const AssetGenImage('assets/images/audio_control/dashatar_on.png');

  /// File path: assets/images/audio_control/green_dashatar_off.png
  AssetGenImage get greenDashatarOff =>
      const AssetGenImage('assets/images/audio_control/green_dashatar_off.png');

  /// File path: assets/images/audio_control/simple_off.png
  AssetGenImage get simpleOff =>
      const AssetGenImage('assets/images/audio_control/simple_off.png');

  /// File path: assets/images/audio_control/simple_on.png
  AssetGenImage get simpleOn =>
      const AssetGenImage('assets/images/audio_control/simple_on.png');

  /// File path: assets/images/audio_control/yellow_dashatar_off.png
  AssetGenImage get yellowDashatarOff => const AssetGenImage(
      'assets/images/audio_control/yellow_dashatar_off.png');
}

class $AssetsImagesChessGen {
  const $AssetsImagesChessGen();

  /// File path: assets/images/chess/Chess_bdt45.svg
  String get chessBdt45 => 'assets/images/chess/Chess_bdt45.svg';

  /// File path: assets/images/chess/Chess_blt45.svg
  String get chessBlt45 => 'assets/images/chess/Chess_blt45.svg';

  /// File path: assets/images/chess/Chess_kdt45.svg
  String get chessKdt45 => 'assets/images/chess/Chess_kdt45.svg';

  /// File path: assets/images/chess/Chess_klt45.svg
  String get chessKlt45 => 'assets/images/chess/Chess_klt45.svg';

  /// File path: assets/images/chess/Chess_ndt45.svg
  String get chessNdt45 => 'assets/images/chess/Chess_ndt45.svg';

  /// File path: assets/images/chess/Chess_nlt45.svg
  String get chessNlt45 => 'assets/images/chess/Chess_nlt45.svg';

  /// File path: assets/images/chess/Chess_pdt45.svg
  String get chessPdt45 => 'assets/images/chess/Chess_pdt45.svg';

  /// File path: assets/images/chess/Chess_plt45.svg
  String get chessPlt45 => 'assets/images/chess/Chess_plt45.svg';

  /// File path: assets/images/chess/Chess_qdt45.svg
  String get chessQdt45 => 'assets/images/chess/Chess_qdt45.svg';

  /// File path: assets/images/chess/Chess_qlt45.svg
  String get chessQlt45 => 'assets/images/chess/Chess_qlt45.svg';

  /// File path: assets/images/chess/Chess_rdt45.svg
  String get chessRdt45 => 'assets/images/chess/Chess_rdt45.svg';

  /// File path: assets/images/chess/Chess_rlt45.svg
  String get chessRlt45 => 'assets/images/chess/Chess_rlt45.svg';
}

class Assets {
  Assets._();

  static const $AssetsAudioGen audio = $AssetsAudioGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName) : super(assetName);

  Image image({
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      key: key,
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => assetName;
}

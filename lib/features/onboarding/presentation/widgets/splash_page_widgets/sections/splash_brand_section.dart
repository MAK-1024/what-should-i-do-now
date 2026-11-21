import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wsidappp/core/constants/app_assets.dart';

/// App icon and wordmark positioned per Figma `448:3734` (430×932).
class SplashBrandSection extends StatelessWidget {
  const SplashBrandSection({
    super.key,
    required this.wordmarkSemanticsLabel,
  });

  final String wordmarkSemanticsLabel;

  static const double _frameWidth = 430;
  static const double _frameHeight = 932;

  static const double _iconLeft = 178;
  static const double _iconTop = 312;
  static const double _iconWidth = 75;
  static const double _iconHeight = 71;

  static const double _wordmarkLeft = 123;
  static const double _wordmarkTop = 431;
  static const double _wordmarkWidth = 184;
  static const double _wordmarkHeight = 159.467;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double scaleX = constraints.maxWidth / _frameWidth;
        final double scaleY = constraints.maxHeight / _frameHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: _iconLeft * scaleX,
              top: _iconTop * scaleY,
              width: _iconWidth * scaleX,
              height: _iconHeight * scaleY,
              child: Image.asset(
                AppAssets.splashIcon,
                width: _iconWidth * scaleX,
                height: _iconHeight * scaleY,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              left: _wordmarkLeft * scaleX,
              top: _wordmarkTop * scaleY,
              width: _wordmarkWidth * scaleX,
              height: _wordmarkHeight * scaleY,
              child: SvgPicture.asset(
                AppAssets.splashWordmark,
                width: _wordmarkWidth * scaleX,
                height: _wordmarkHeight * scaleY,
                fit: BoxFit.contain,
                semanticsLabel: wordmarkSemanticsLabel,
              ),
            ),
          ],
        );
      },
    );
  }
}
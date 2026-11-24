import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/app_assets.dart';

/// Reusable soft sage/blue-grey gradient background wrapper for onboarding, auth, and brand screens.
class WsidGradientBackground extends StatelessWidget {
  const WsidGradientBackground({
    super.key,
    required this.child,
    this.imagePath = AppAssets.bgSoftGradient,
    this.safeArea = true,
  });

  final Widget child;
  final String imagePath;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final bool isLight = context.isLightTheme;

    Widget body = child;
    if (safeArea) {
      body = SafeArea(child: body);
    }

    if (!isLight) {
      return ColoredBox(
        color: context.colors.surface,
        child: body,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const ColoredBox(
              color: Color(0xFFEFF3F2),
            ),
          ),
        ),
        body,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/utils/app_motion.dart';

/// Mascot illustration with a centered title and subtitle.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.imagePath,
    required this.imageSize,
    required this.title,
    required this.subtitle,
  });

  final String imagePath;
  final double imageSize;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final Duration duration = AppMotion.of(context, AppMotion.slow);
    final Duration step = AppMotion.of(context, AppMotion.staggerStep);

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              )
                  .animate()
                  .fadeIn(duration: duration, curve: AppMotion.standard)
                  .scaleXY(
                    begin: 0.92,
                    duration: duration,
                    curve: AppMotion.emphasized,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.typo.h3Bold.copyWith(
                color: context.isLightTheme
                    ? context.colors.primary
                    : brand.headlineText,
              ),
            )
                .animate(delay: step)
                .fadeIn(duration: duration, curve: AppMotion.standard)
                .slideY(begin: 0.3, duration: duration, curve: AppMotion.standard),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.screenSubtitleStyle,
            )
                .animate(delay: step * 2)
                .fadeIn(duration: duration, curve: AppMotion.standard)
                .slideY(begin: 0.3, duration: duration, curve: AppMotion.standard),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/utils/app_motion.dart';

/// Pill-shaped page indicator: the active page is a wider, darker pill.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final Duration duration = AppMotion.of(context, AppMotion.medium);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(count, (int index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: duration,
          curve: AppMotion.standard,
          margin: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 4),
          width: isActive ? 24 : 12,
          height: 4,
          decoration: BoxDecoration(
            color: isActive
                ? brand.pageIndicatorActive
                : brand.pageIndicatorInactive,
            borderRadius: context.radius.full,
          ),
        );
      }),
    );
  }
}

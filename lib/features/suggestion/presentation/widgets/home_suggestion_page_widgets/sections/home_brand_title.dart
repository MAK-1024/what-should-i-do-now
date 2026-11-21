import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';

/// Stacked two-line brand title shown in the Home header.
class HomeBrandTitle extends StatelessWidget {
  const HomeBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.brandHeader,
      maxLines: 2,
      style: context.pageTitleStyle.copyWith(height: 1.1),
    )
        .animate()
        .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
        .slideX(
          begin: -0.05,
          end: 0,
          duration: AppMotion.of(context, AppMotion.medium),
          curve: AppMotion.standard,
        );
  }
}

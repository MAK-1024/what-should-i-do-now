import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';

/// Outlined "skip" and filled "next" / "get started" buttons, side by side.
class OnboardingActions extends StatelessWidget {
  const OnboardingActions({
    super.key,
    required this.isLastPage,
    required this.onSkip,
    required this.onNext,
  });

  final bool isLastPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;
    final OutlinedBorder shape =
        RoundedRectangleBorder(borderRadius: context.radius.lg);
    const EdgeInsets padding =
        EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final TextStyle labelStyle = context.typo.title1Bold;

    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: _height,
            child: OutlinedButton(
              onPressed: onSkip,
              style: OutlinedButton.styleFrom(
                foregroundColor: brand.primaryAction,
                side: BorderSide(color: brand.primaryAction),
                shape: shape,
                padding: padding,
                textStyle: labelStyle,
              ),
              child: Text(l10n.skip),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: _height,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: brand.primaryAction,
                foregroundColor: brand.onPrimaryAction,
                shape: shape,
                padding: padding,
                textStyle: labelStyle,
              ),
              child: Text(isLastPage ? l10n.getStarted : l10n.next),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        Expanded(
          child: WsidButton(
            onPressed: onSkip,
            label: l10n.skip,
            variant: WsidButtonVariant.outlined,
            size: WsidButtonSize.large,
            isExpanded: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WsidButton(
            onPressed: onNext,
            label: isLastPage ? l10n.getStarted : l10n.next,
            size: WsidButtonSize.large,
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/shared/widgets/floating_mascot.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';

/// Standard rounded confirmation dialog matching Figma design system.
class WsidConfirmationDialog extends StatelessWidget {
  const WsidConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    this.mascotAsset,
    this.mascotSize = 130.0,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final bool isDestructive;
  final String? mascotAsset;
  final double mascotSize;
  final IconData? icon;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    String? mascotAsset,
    double mascotSize = 130.0,
    IconData? icon,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => WsidConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        mascotAsset: mascotAsset,
        mascotSize: mascotSize,
        icon: icon,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool isLight = context.isLightTheme;
    final bg = isLight ? context.brand.cardFill : context.colors.surface;
    final border = isLight ? context.brand.cardBorder : context.colors.outlineVariant;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
        side: BorderSide(color: border),
      ),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (mascotAsset != null) ...<Widget>[
              FloatingMascot(
                offsetY: 6.0,
                duration: const Duration(milliseconds: 2200),
                child: Image.asset(
                  mascotAsset!,
                  width: mascotSize,
                  height: mascotSize,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
            ] else if (icon != null) ...<Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? context.colors.errorContainer.withValues(alpha: 0.4)
                      : context.colors.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isDestructive
                      ? context.colors.error
                      : context.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.typo.h3Bold.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isLight ? context.colors.primary : context.brand.headlineText,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: context.screenSubtitleStyle.copyWith(
                  fontSize: 14.5,
                  height: 1.45,
                  color: context.brand.bodyText,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: <Widget>[
                Expanded(
                  child: WsidButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    label: cancelLabel ?? l10n.cancel,
                    variant: WsidButtonVariant.outlined,
                    size: WsidButtonSize.medium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isDestructive
                      ? FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.error,
                            foregroundColor: context.colors.onError,
                            shape: RoundedRectangleBorder(
                              borderRadius: context.radius.lg,
                            ),
                            minimumSize: const Size.fromHeight(48),
                            textStyle: context.typo.title1Bold,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(confirmLabel),
                        )
                      : WsidButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          label: confirmLabel,
                          variant: WsidButtonVariant.primary,
                          size: WsidButtonSize.medium,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

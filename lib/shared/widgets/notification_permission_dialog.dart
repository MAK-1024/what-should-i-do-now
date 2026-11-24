import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/shared/widgets/brand_surface_card.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';

/// First-launch explainer before the OS notification permission sheet.
Future<bool?> showNotificationPermissionDialog(BuildContext context) {
  final AppLocalizations l10n = context.l10n;
  final Duration enter = AppMotion.of(context, AppMotion.medium);

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (BuildContext dialogContext) {
      final brand = dialogContext.brand;
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: BrandSurfaceCard(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: brand.chipAddFill,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    size: 32,
                    color: brand.primaryAction,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.notificationPermissionTitle,
                textAlign: TextAlign.center,
                style: dialogContext.screenTitleStyle,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.notificationPermissionBody,
                textAlign: TextAlign.center,
                style: dialogContext.screenSubtitleStyle,
              ),
              const SizedBox(height: 28),
              WsidButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                label: l10n.allowNotifications,
                variant: WsidButtonVariant.primary,
                size: WsidButtonSize.large,
                isExpanded: true,
                icon: Icons.check_rounded,
              ),
              const SizedBox(height: 8),
              WsidButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                label: l10n.notNow,
                variant: WsidButtonVariant.text,
                size: WsidButtonSize.large,
                isExpanded: true,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: enter, curve: AppMotion.standard)
            .scale(
              begin: const Offset(0.92, 0.92),
              duration: enter,
              curve: AppMotion.emphasized,
            ),
      );
    },
  );
}
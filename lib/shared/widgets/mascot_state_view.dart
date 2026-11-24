import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/shared/widgets/floating_mascot.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';

/// Standardized mascot empty / error / offline / custom state view.
class MascotStateView extends StatelessWidget {
  const MascotStateView({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.isActionLoading = false,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.imageSize = 170.0,
    this.isFloating = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
  });

  /// Factory for empty states (e.g., no tasks, empty backlogs).
  const MascotStateView.empty({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.isActionLoading = false,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.imagePath = AppAssets.qustion,
    this.imageSize = 170.0,
    this.isFloating = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
  });

  /// Factory for error states.
  const MascotStateView.error({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.refresh,
    this.isActionLoading = false,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.imagePath = AppAssets.error,
    this.imageSize = 170.0,
    this.isFloating = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
  });

  /// Factory for offline / no-connection states.
  const MascotStateView.offline({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.refresh,
    this.isActionLoading = false,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.imagePath = AppAssets.noconnection,
    this.imageSize = 170.0,
    this.isFloating = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
  });

  final String imagePath;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final bool isActionLoading;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final IconData? secondaryActionIcon;
  final double imageSize;
  final bool isFloating;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = Image.asset(
      imagePath,
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 350))
        .scaleXY(begin: 0.9, duration: const Duration(milliseconds: 350));

    final Widget mascot = isFloating
        ? FloatingMascot(child: imageWidget)
        : imageWidget;

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            mascot,
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.typo.h3Bold.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.isLightTheme
                    ? context.colors.primary
                    : context.brand.headlineText,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: context.screenSubtitleStyle.copyWith(
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: SizedBox(
                  width: double.infinity,
                  child: WsidButton(
                    onPressed: onAction,
                    label: actionLabel!,
                    icon: actionIcon,
                    isLoading: isActionLoading,
                    variant: WsidButtonVariant.primary,
                    size: WsidButtonSize.large,
                  ),
                ),
              ),
            ],
            if (secondaryActionLabel != null &&
                onSecondaryAction != null) ...<Widget>[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: SizedBox(
                  width: double.infinity,
                  child: WsidButton(
                    onPressed: onSecondaryAction,
                    label: secondaryActionLabel!,
                    icon: secondaryActionIcon,
                    variant: WsidButtonVariant.outlined,
                    size: WsidButtonSize.large,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:wsidappp/config/theme/app_colors.dart';

enum WsidIconButtonVariant {
  filled,
  tonal,
  outlined,
  ghost,
  destructive,
}

enum WsidIconButtonSize {
  small,
  medium,
  large,
}

class WsidIconButton extends StatelessWidget {
  const WsidIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = WsidIconButtonVariant.ghost,
    this.size = WsidIconButtonSize.medium,
    this.iconSize,
    this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final WsidIconButtonVariant variant;
  final WsidIconButtonSize size;
  final double? iconSize;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final double buttonSize = switch (size) {
      WsidIconButtonSize.small => 36,
      WsidIconButtonSize.medium => 48,
      WsidIconButtonSize.large => 56,
    };
    final double resolvedIconSize = iconSize ??
        switch (size) {
          WsidIconButtonSize.small => 20,
          WsidIconButtonSize.medium => 24,
          WsidIconButtonSize.large => 26,
        };

    final Color foreground = foregroundColor ?? switch (variant) {
      WsidIconButtonVariant.filled ||
      WsidIconButtonVariant.destructive =>
        AppColors.surface,
      WsidIconButtonVariant.tonal ||
      WsidIconButtonVariant.outlined ||
      WsidIconButtonVariant.ghost =>
        AppColors.green700,
    };

    final ButtonStyle style = switch (variant) {
      WsidIconButtonVariant.filled => IconButton.styleFrom(
          backgroundColor: AppColors.green500,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.green100,
          disabledForegroundColor: AppColors.grey300,
          shape: const CircleBorder(),
        ),
      WsidIconButtonVariant.tonal => IconButton.styleFrom(
          backgroundColor: AppColors.green50,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.grey50,
          disabledForegroundColor: AppColors.grey300,
          shape: const CircleBorder(),
        ),
      WsidIconButtonVariant.outlined => IconButton.styleFrom(
          foregroundColor: foreground,
          disabledForegroundColor: AppColors.grey300,
          side: const BorderSide(color: AppColors.green500),
          shape: const CircleBorder(),
        ),
      WsidIconButtonVariant.ghost => IconButton.styleFrom(
          foregroundColor: foreground,
          disabledForegroundColor: AppColors.grey300,
          shape: const CircleBorder(),
        ),
      WsidIconButtonVariant.destructive => IconButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.errorContainer,
          disabledForegroundColor: AppColors.grey300,
          shape: const CircleBorder(),
        ),
    };

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: style,
      iconSize: resolvedIconSize,
      constraints: BoxConstraints.tightFor(
        width: buttonSize,
        height: buttonSize,
      ),
      icon: Icon(icon),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/app_typography.dart';

enum WsidButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  link,
  destructive,
}

enum WsidButtonSize {
  small,
  medium,
  large,
}

class WsidButton extends StatelessWidget {
  const WsidButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = WsidButtonVariant.primary,
    this.size = WsidButtonSize.medium,
    this.icon,
    this.iconOnLeading = true,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final WsidButtonVariant variant;
  final WsidButtonSize size;
  final IconData? icon;
  final bool iconOnLeading;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final double height = switch (size) {
      WsidButtonSize.small => 36,
      WsidButtonSize.medium => 48,
      WsidButtonSize.large => 56,
    };

    final EdgeInsetsGeometry padding = switch (size) {
      WsidButtonSize.small => const EdgeInsets.symmetric(horizontal: 16),
      WsidButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24),
      WsidButtonSize.large => const EdgeInsets.symmetric(horizontal: 28),
    };

    final Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor(),
            ),
          )
        : Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && iconOnLeading) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (icon != null && !iconOnLeading) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 20),
              ],
            ],
          );

    final ButtonStyle style = switch (variant) {
      WsidButtonVariant.primary => FilledButton.styleFrom(
          backgroundColor: AppColors.green500,
          foregroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.green100,
          disabledForegroundColor: AppColors.grey300,
          textStyle: const ThemeTypography().bodyBold,
          padding: padding,
          minimumSize: Size(isExpanded ? double.infinity : 64, height),
          maximumSize: Size(double.infinity, height),
          shape: const StadiumBorder(),
        ),
      WsidButtonVariant.secondary => FilledButton.styleFrom(
          backgroundColor: AppColors.green50,
          foregroundColor: AppColors.green700,
          disabledBackgroundColor: AppColors.grey50,
          disabledForegroundColor: AppColors.grey300,
          textStyle: const ThemeTypography().bodyBold,
          padding: padding,
          minimumSize: Size(isExpanded ? double.infinity : 64, height),
          maximumSize: Size(double.infinity, height),
          shape: const StadiumBorder(),
        ),
      WsidButtonVariant.outlined => OutlinedButton.styleFrom(
          foregroundColor: AppColors.green700,
          disabledForegroundColor: AppColors.grey300,
          textStyle: const ThemeTypography().bodyBold,
          padding: padding,
          minimumSize: Size(isExpanded ? double.infinity : 64, height),
          maximumSize: Size(double.infinity, height),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.green500),
        ),
      WsidButtonVariant.text => TextButton.styleFrom(
          foregroundColor: AppColors.green700,
          disabledForegroundColor: AppColors.grey300,
          textStyle: const ThemeTypography().bodyBold,
          padding: padding,
          minimumSize: Size(isExpanded ? double.infinity : 64, height),
          maximumSize: Size(double.infinity, height),
          shape: const StadiumBorder(),
        ),
      WsidButtonVariant.link => TextButton.styleFrom(
          foregroundColor: AppColors.green700,
          disabledForegroundColor: AppColors.grey300,
          textStyle: const ThemeTypography().bodyBold.copyWith(
            decoration: TextDecoration.underline,
            decorationThickness: 2,
          ),
          padding: padding,
          minimumSize: Size(isExpanded ? double.infinity : 64, height),
          maximumSize: Size(double.infinity, height),
          shape: const StadiumBorder(),
        ),
      WsidButtonVariant.destructive => FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
          disabledBackgroundColor: AppColors.errorContainer,
          disabledForegroundColor: AppColors.grey300,
          textStyle: const ThemeTypography().bodyBold,
          padding: padding,
          minimumSize: Size(isExpanded ? double.infinity : 64, height),
          maximumSize: Size(double.infinity, height),
          shape: const StadiumBorder(),
        ),
    };

    final VoidCallback? effectiveOnPressed =
        isLoading ? null : onPressed;

    final Widget button = switch (variant) {
      WsidButtonVariant.outlined => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
      WsidButtonVariant.text => TextButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
      WsidButtonVariant.link => TextButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
      _ => FilledButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
    };

    return isExpanded
        ? SizedBox(width: double.infinity, height: height, child: button)
        : button;
  }

  Color _foregroundColor() {
    return switch (variant) {
      WsidButtonVariant.primary ||
      WsidButtonVariant.destructive =>
        AppColors.surface,
      WsidButtonVariant.secondary ||
      WsidButtonVariant.outlined ||
      WsidButtonVariant.text ||
      WsidButtonVariant.link =>
        AppColors.green700,
    };
  }
}

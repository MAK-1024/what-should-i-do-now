import 'package:flutter/material.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/shared/widgets/wsid_confirmation_dialog.dart';

/// Confirmation dialog resolving to `true` only when the user confirms.
abstract final class ConfirmActionDialog {
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
  }) {
    return WsidConfirmationDialog.show(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      mascotAsset: mascotAsset ?? (isDestructive ? AppAssets.hearbreak : AppAssets.leaving),
      mascotSize: mascotSize,
      icon: icon,
    );
  }

  /// Specific helper matching the Figma logout confirmation dialog.
  static Future<bool> showLogout(BuildContext context) {
    final l10n = context.l10n;
    return WsidConfirmationDialog.show(
      context,
      title: l10n.logOutTitle,
      message: l10n.logOutSubtitle,
      confirmLabel: l10n.logoutButton,
      cancelLabel: l10n.cancelButton,
      isDestructive: false,
      mascotAsset: AppAssets.hearbreak,
      mascotSize: 136.0,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';

/// First-launch explainer before the OS notification permission sheet.
Future<bool?> showNotificationPermissionDialog(BuildContext context) {
  final AppLocalizations l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(l10n.notificationPermissionTitle),
        content: Text(
          l10n.notificationPermissionBody,
          style: dialogContext.txt.bodyMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.allowNotifications),
          ),
        ],
      );
    },
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/external_link_launcher.dart';
import 'package:wsidappp/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/dialogs/confirm_action_dialog.dart';

/// Shared about / legal / logout flows used by profile and the side menu.
abstract final class ProfileAccountActions {
  static const String appVersion = '1.0.0';

  static void showAbout(BuildContext context) {
    final l10n = context.l10n;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: appVersion,
      applicationIcon: Icon(
        Icons.casino_outlined,
        size: 40,
        color: context.colors.primary,
      ),
      children: <Widget>[Text(l10n.aboutAppDescription)],
    );
  }

  static Future<void> openLegalPage(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.l10n.couldNotOpenLink;
    final errorColor = context.colors.error;
    if (!await openExternalLink(url)) {
      messenger.showSnackBar(
        SnackBar(content: Text(errorText), backgroundColor: errorColor),
      );
    }
  }

  static Future<void> logOut(BuildContext context) async {
    final AuthCubit authCubit = context.read<AuthCubit>();
    final bool confirmed = await ConfirmActionDialog.showLogout(context);
    if (confirmed) await authCubit.signOut();
  }
}
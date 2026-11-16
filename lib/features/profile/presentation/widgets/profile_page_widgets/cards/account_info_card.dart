import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/environment_config/legal_urls.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/external_link_launcher.dart';
import 'package:wsidappp/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wsidappp/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/dialogs/confirm_action_dialog.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/shared/settings_card.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/shared/settings_tile.dart';

/// About, Log Out and Delete Account actions.
class AccountInfoCard extends StatelessWidget {
  const AccountInfoCard({super.key, required this.isBusy});

  final bool isBusy;

  static const String _appVersion = '1.0.0';

  void _showAbout(BuildContext context) {
    final l10n = context.l10n;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: _appVersion,
      applicationIcon: Icon(
        Icons.casino_outlined,
        size: 40,
        color: context.colors.primary,
      ),
      children: <Widget>[Text(l10n.aboutAppDescription)],
    );
  }

  Future<void> _openLegalPage(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.l10n.couldNotOpenLink;
    final errorColor = context.colors.error;
    if (!await openExternalLink(url)) {
      messenger.showSnackBar(
        SnackBar(content: Text(errorText), backgroundColor: errorColor),
      );
    }
  }

  Future<void> _logOut(BuildContext context) async {
    final l10n = context.l10n;
    final AuthCubit authCubit = context.read<AuthCubit>();
    final bool confirmed = await ConfirmActionDialog.show(
      context,
      title: l10n.logOut,
      message: l10n.logOutConfirm,
      confirmLabel: l10n.logOut,
    );
    if (confirmed) await authCubit.signOut();
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final l10n = context.l10n;
    final ProfileCubit profileCubit = context.read<ProfileCubit>();
    final bool confirmed = await ConfirmActionDialog.show(
      context,
      title: l10n.deleteAccount,
      message: l10n.deleteAccountConfirm,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed) await profileCubit.deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Widget chevron = Icon(
      Icons.chevron_right,
      color: context.colors.onSurfaceVariant,
    );
    final Widget openInNew = Icon(
      Icons.open_in_new,
      size: 20,
      color: context.colors.onSurfaceVariant,
    );

    return SettingsCard(
      title: l10n.accountAndInfo,
      children: <Widget>[
        SettingsTile(
          icon: Icons.info_outline,
          title: l10n.aboutApp,
          trailing: chevron,
          onTap: () => _showAbout(context),
        ),
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: l10n.privacyPolicy,
          trailing: openInNew,
          onTap: () => _openLegalPage(context, LegalUrls.privacyPolicy),
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: l10n.termsOfService,
          trailing: openInNew,
          onTap: () => _openLegalPage(context, LegalUrls.termsOfService),
        ),
        SettingsTile(
          icon: Icons.logout,
          title: l10n.logOut,
          trailing: chevron,
          onTap: isBusy ? null : () => _logOut(context),
        ),
        SettingsTile(
          icon: Icons.delete_forever_outlined,
          title: l10n.deleteAccount,
          subtitle: l10n.deleteAccountSubtitle,
          isDestructive: true,
          onTap: isBusy ? null : () => _deleteAccount(context),
        ),
      ],
    );
  }
}

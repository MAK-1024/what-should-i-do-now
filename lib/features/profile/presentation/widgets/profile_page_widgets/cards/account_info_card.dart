import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/environment_config/legal_urls.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_account_actions.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/dialogs/confirm_action_dialog.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/shared/settings_card.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/shared/settings_tile.dart';

/// About, Log Out and Delete Account actions.
class AccountInfoCard extends StatelessWidget {
  const AccountInfoCard({super.key, required this.isBusy});

  final bool isBusy;

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
          onTap: () => ProfileAccountActions.showAbout(context),
        ),
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: l10n.privacyPolicy,
          trailing: openInNew,
          onTap: () =>
              ProfileAccountActions.openLegalPage(context, LegalUrls.privacyPolicy),
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: l10n.termsOfService,
          trailing: openInNew,
          onTap: () =>
              ProfileAccountActions.openLegalPage(context, LegalUrls.termsOfService),
        ),
        SettingsTile(
          icon: Icons.logout,
          title: l10n.logOut,
          trailing: chevron,
          onTap: isBusy ? null : () => ProfileAccountActions.logOut(context),
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

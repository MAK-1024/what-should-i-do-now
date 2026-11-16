import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/dialogs/edit_display_name_dialog.dart';

/// Avatar, display name, joined date and the edit-name action.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.isSaving,
  });

  final UserProfile profile;
  final bool isSaving;

  String get _initials {
    final List<String> parts = profile.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _editName(BuildContext context) async {
    final ProfileCubit profileCubit = context.read<ProfileCubit>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String successText = context.l10n.profileUpdated;

    final String? newName = await EditDisplayNameDialog.show(
      context,
      initialName: profile.displayName,
    );
    if (newName == null || newName == profile.displayName) return;

    final bool updated = await profileCubit.updateDisplayName(newName);
    if (updated) {
      messenger.showSnackBar(SnackBar(content: Text(successText)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String joined = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(profile.createdAt.toLocal());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                _initials,
                style: context.txt.titleLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    profile.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.txt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.joinedOn(joined),
                    style: context.txt.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(72, 44),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                foregroundColor: context.colors.primary,
                side: BorderSide(color: context.colors.primary),
              ),
              onPressed: isSaving ? null : () => _editName(context),
              child: isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.edit),
            ),
          ],
        ),
      ),
    );
  }
}

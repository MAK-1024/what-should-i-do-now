import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:wsidappp/features/profile/presentation/cubit/profile_state.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/cards/account_info_card.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/cards/preferences_card.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/cards/profile_header_card.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// Profile page: identity, app-wide preferences and account actions.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  String? _actionError(ProfileState state) => state.maybeWhen(
        loaded: (_, _, String? actionError) => actionError,
        orElse: () => null,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.profile, centerTitle: false),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (_, ProfileState current) => _actionError(current) != null,
        listener: (BuildContext context, ProfileState state) {
          final String? message = _actionError(state);
          if (message == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: context.colors.error,
            ),
          );
        },
        buildWhen: (_, ProfileState current) => _actionError(current) == null,
        builder: (BuildContext context, ProfileState state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (UserProfile profile, bool isSaving, _) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: <Widget>[
                ProfileHeaderCard(profile: profile, isSaving: isSaving),
                const SizedBox(height: 24),
                const PreferencesCard(),
                const SizedBox(height: 24),
                AccountInfoCard(isBusy: isSaving),
              ],
            ),
            error: (String message) => _ErrorBody(message: message),
          );
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: context.colors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.txt.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<ProfileCubit>().loadProfile(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

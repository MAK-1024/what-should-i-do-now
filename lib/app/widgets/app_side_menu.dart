import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/app/widgets/shell_drawer_scope.dart';
import 'package:wsidappp/config/environment_config/legal_urls.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wsidappp/features/auth/presentation/cubit/auth_state.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_account_actions.dart';

/// Figma side menu (`364:1973`): ~67% width, rounded on the right, scrim.
class AppSideMenu extends StatelessWidget {
  const AppSideMenu({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  static const double _widthFraction = 0.67;

  void _navigateAfterClose(BuildContext context, VoidCallback action) {
    onClose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) action();
    });
  }

  String _initials(String displayName) {
    final List<String> parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double panelWidth = MediaQuery.sizeOf(context).width * _widthFraction;
    final Duration motion = AppMotion.of(context, AppMotion.medium);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final BorderRadius panelRadius = isRtl
        ? const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: isRtl ? null : 0,
            right: isRtl ? 0 : null,
            width: panelWidth,
            child: SafeArea(
              left: !isRtl,
              right: isRtl,
              child: ClipRRect(
                borderRadius: panelRadius,
                child: Material(
                  color: context.brand.cardFill,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (BuildContext context, AuthState authState) {
                      final UserProfile? profile = authState.maybeWhen(
                        authenticated: (UserProfile p) => p,
                        orElse: () => null,
                      );
                      return _SideMenuPanel(
                        profile: profile,
                        onClose: onClose,
                        onNavigate: (VoidCallback action) =>
                            _navigateAfterClose(context, action),
                        initials: profile == null
                            ? '?'
                            : _initials(profile.displayName),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: motion, curve: AppMotion.standard)
              .slideX(
                begin: isRtl ? 0.08 : -0.08,
                end: 0,
                duration: motion,
                curve: AppMotion.emphasized,
              ),
        ],
      ),
    );
  }
}

class _SideMenuPanel extends StatelessWidget {
  const _SideMenuPanel({
    required this.profile,
    required this.onClose,
    required this.onNavigate,
    required this.initials,
  });

  final UserProfile? profile;
  final VoidCallback onClose;
  final void Function(VoidCallback action) onNavigate;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: <Widget>[
        _ProfileHeaderCard(
          profile: profile,
          initials: initials,
          onTap: () => onNavigate(() => context.go(RouteList.profile)),
          onEdit: () => onNavigate(() => context.go(RouteList.profile)),
        ),
        const SizedBox(height: 20),
        Divider(height: 1, color: brand.divider),
        const SizedBox(height: 8),
        _SideMenuTile(
          icon: Icons.settings_outlined,
          label: l10n.settings,
          onTap: () => onNavigate(() => context.go(RouteList.profile)),
        ),
        _SideMenuTile(
          icon: Icons.shield_outlined,
          label: l10n.privacyPolicy,
          onTap: () => onNavigate(
            () => ProfileAccountActions.openLegalPage(
              context,
              LegalUrls.privacyPolicy,
            ),
          ),
        ),
        _SideMenuTile(
          icon: Icons.description_outlined,
          label: l10n.termsOfService,
          onTap: () => onNavigate(
            () => ProfileAccountActions.openLegalPage(
              context,
              LegalUrls.termsOfService,
            ),
          ),
        ),
        _SideMenuTile(
          icon: Icons.info_outline,
          label: l10n.aboutApp,
          onTap: () {
            onClose();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) ProfileAccountActions.showAbout(context);
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, color: brand.divider),
        ),
        _SideMenuTile(
          icon: Icons.logout,
          label: l10n.logOut,
          isDestructive: true,
          onTap: () {
            onClose();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) ProfileAccountActions.logOut(context);
            });
          },
        ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.initials,
    required this.onTap,
    required this.onEdit,
  });

  final UserProfile? profile;
  final String initials;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;
  final String displayName =
        profile?.displayName.trim().isNotEmpty == true
            ? profile!.displayName.trim()
            : l10n.displayName;

    return Material(
      color: brand.chipAddFill,
      borderRadius: context.radius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: context.colors.primaryContainer,
                child: Text(
                  initials,
                  style: context.txt.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.menuWelcome,
                      style: context.txt.bodySmall?.copyWith(
                        color: brand.mutedText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.cardTitleStyle,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  unawaited(HapticFeedback.selectionClick());
                  onEdit();
                },
                icon: Icon(
                  Icons.edit_outlined,
                  color: context.colors.primary,
                  size: 22,
                ),
                tooltip: l10n.editDisplayName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideMenuTile extends StatelessWidget {
  const _SideMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color accent = isDestructive
        ? context.brand.destructiveText
        : context.colors.primary;
    final Color labelColor =
        isDestructive ? context.brand.destructiveText : context.brand.titleText;

    return SizedBox(
      height: 52,
      child: InkWell(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onTap();
        },
        borderRadius: context.radius.md,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: accent),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: context.txt.titleSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the shell side menu from any descendant of [AppShell].
void openShellSideMenu(BuildContext context) {
  final ShellDrawerScope? scope = ShellDrawerScope.maybeOf(context);
  if (scope != null) {
    unawaited(HapticFeedback.lightImpact());
    scope.openDrawer();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/shared/widgets/wsid_icon_button.dart';

enum WsidAppBarVariant { logo, main, sub }

/// Icon button · title (or logo) · icon button. Mirrors the Figma variants:
///
///  - [WsidAppBar.logo] : menu · wordmark · bell
///  - [WsidAppBar.main] : menu · title · bell
///  - [WsidAppBar.sub]  : back · title · bell
///
/// Colors and the title style come from the theme (light/dark app mode).
/// [WsidAppBar.sub] also accepts `dark: true` to force the dark look
/// (e.g. the timer screen) without changing the rest of the app.
class WsidAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WsidAppBar.logo({
    super.key,
    this.onLeadingPressed,
    this.onNotificationsPressed,
  }) : variant = WsidAppBarVariant.logo,
       title = '',
       dark = false;

  const WsidAppBar.main({
    super.key,
    this.title = 'What Should I Do?',
    this.onLeadingPressed,
    this.onNotificationsPressed,
  }) : variant = WsidAppBarVariant.main,
       dark = false;

  const WsidAppBar.sub({
    super.key,
    this.title = 'What Should I Do?',
    this.dark = false,
    this.onLeadingPressed,
    this.onNotificationsPressed,
  }) : variant = WsidAppBarVariant.sub;

  final WsidAppBarVariant variant;
  final String title;

  /// Forces the dark look regardless of the app theme ([WsidAppBar.sub] only).
  final bool dark;

  final VoidCallback? onLeadingPressed;
  final VoidCallback? onNotificationsPressed;

  @override
  Size get preferredSize {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    final statusBar = view == null
        ? 0.0
        : view.padding.top / view.devicePixelRatio;
    final row = variant == WsidAppBarVariant.logo ? 53 : 48;
    // status bar + row + 16 bottom padding (+ 1 divider unless forced dark)
    return Size.fromHeight(statusBar + row + 16 + (dark ? 0 : 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSub = variant == WsidAppBarVariant.sub;
    final iconColor = dark ? Colors.white : theme.colorScheme.primary;
    final lightIcons = dark || theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          (lightIcons ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
              .copyWith(statusBarColor: Colors.transparent),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AppColors.green900 : theme.appBarTheme.backgroundColor,
          border: dark
              ? null
              : Border(
                  bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Row(
              children: [
                WsidIconButton(
                  icon: isSub ? Icons.arrow_back_ios_new : Icons.menu,
                  foregroundColor: iconColor,
                  tooltip: isSub ? 'back' : 'menu',
                  onPressed: isSub
                      ? (onLeadingPressed ?? () => Navigator.maybePop(context))
                      : onLeadingPressed,
                ),
                Expanded(
                  child: variant == WsidAppBarVariant.logo
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SvgPicture.asset(
                            AppAssets.splashWordmark,
                            height: 53,
                            semanticsLabel: 'What Should I Do?',
                          ),
                        )
                      : Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.appBarTheme.titleTextStyle?.copyWith(
                            color: dark ? AppColors.grey50 : null,
                          ),
                        ),
                ),
                WsidIconButton(
                  icon: Icons.notifications_none,
                  foregroundColor: iconColor,
                  tooltip: 'notifications',
                  onPressed: onNotificationsPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard reusable application bar honoring project tokens and navigation patterns.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.bottom,
    this.showBackButton = true,
    this.leading,
    this.centerTitle = true,
    this.toolbarHeight = kToolbarHeight,
    this.backgroundColor,
  }) : assert(
         title != null || titleWidget != null,
         'Provide either a title or a titleWidget.',
       );

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final Widget? leading;
  final bool centerTitle;
  final double toolbarHeight;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton && context.canPop()) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      );
    }

    return AppBar(
      centerTitle: centerTitle,
      title: titleWidget ?? Text(title!),
      leading: leadingWidget,
      automaticallyImplyLeading: false,
      toolbarHeight: toolbarHeight,
      backgroundColor: backgroundColor,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

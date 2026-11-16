import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

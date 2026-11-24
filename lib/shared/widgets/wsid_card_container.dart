import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';

/// Standard rounded white card container matching Figma designs (24px radius, #E5E9EB border).
class WsidCardContainer extends StatelessWidget {
  const WsidCardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = context.isLightTheme;
    final radius = borderRadius ?? context.radius.xl;
    final bg = backgroundColor ??
        (isLight ? context.brand.cardFill : context.colors.surface);
    final border = borderColor ??
        (isLight ? context.brand.cardBorder : context.colors.outlineVariant);

    Widget content = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: border, width: 1.0),
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    if (margin != EdgeInsets.zero) {
      content = Padding(padding: margin, child: content);
    }

    return content;
  }
}

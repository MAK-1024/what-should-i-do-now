import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';

/// Light: Figma surface (20px radius, hairline border). Dark: theme [Card] (16px).
class BrandSurfaceCard extends StatelessWidget {
  const BrandSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final Widget content =
        padding != null ? Padding(padding: padding!, child: child) : child;

    if (context.isLightTheme) {
      final brand = context.brand;
      final BorderRadius radius = context.radius.card;
      return Padding(
        padding: margin,
        child: Material(
          color: brand.cardFill,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: brand.cardBorder),
          ),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: radius,
            child: content,
          ),
        ),
      );
    }

    return Padding(
      padding: margin,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: content,
        ),
      ),
    );
  }
}
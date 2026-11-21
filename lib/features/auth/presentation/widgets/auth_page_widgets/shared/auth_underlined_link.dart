import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';

/// Text link with a 2px sage underline (Figma tertiary button).
class AuthUnderlinedLink extends StatelessWidget {
  const AuthUnderlinedLink({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: context.typo.title1Bold.copyWith(
              color: brand.primaryAction,
              decoration: TextDecoration.underline,
              decorationColor: brand.primaryAction,
              decorationThickness: 2,
            ),
          ),
        ),
      ),
    );
  }
}
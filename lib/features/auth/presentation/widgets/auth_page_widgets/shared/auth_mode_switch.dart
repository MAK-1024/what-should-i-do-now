import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';

/// Footer prompt toggling between login and register (Figma link row).
class AuthModeSwitch extends StatelessWidget {
  const AuthModeSwitch({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
    this.enabled = true,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final TextStyle linkStyle = context.typo.title1Bold.copyWith(
      color: brand.primaryAction,
      decoration: TextDecoration.underline,
      decorationColor: brand.primaryAction,
      decorationThickness: 2,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: <Widget>[
        Text(
          prompt,
          style: context.cardSubtitleStyle,
        ),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(actionLabel, style: linkStyle),
          ),
        ),
      ],
    );
  }
}
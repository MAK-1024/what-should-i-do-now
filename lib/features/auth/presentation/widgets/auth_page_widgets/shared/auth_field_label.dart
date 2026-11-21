import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';

/// Sage label with a required-field asterisk (Figma input field label).
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: label,
              style: context.typo.title1Bold.copyWith(color: context.brand.fieldLabel),
            ),
            TextSpan(
              text: ' *',
              style: context.typo.body.copyWith(
                color: context.colors.error,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
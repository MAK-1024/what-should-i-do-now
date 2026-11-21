import 'package:flutter/material.dart';

import 'package:wsidappp/config/theme/theme_extensions.dart';

class WsidTaskBanner extends StatelessWidget {
  const WsidTaskBanner({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String label;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.tertiaryContainer,
        borderRadius: context.radius.lg,
        border: Border.all(
          color: context.colors.tertiary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: context.txt.labelLarge?.copyWith(
              color: context.colors.tertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: context.txt.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  subtitle,
                  style: context.txt.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary),
                  shape: const StadiumBorder(),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

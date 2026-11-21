import 'package:flutter/material.dart';

import 'package:wsidappp/config/theme/theme_extensions.dart';

enum WsidStatusBadgeVariant {
  pending,
  inProgress,
  completed,
  archived,
  neutral,
}

class WsidStatusBadge extends StatelessWidget {
  const WsidStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.variant = WsidStatusBadgeVariant.neutral,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final WsidStatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: context.radius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.txt.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

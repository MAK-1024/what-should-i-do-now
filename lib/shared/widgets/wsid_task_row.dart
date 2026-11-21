import 'package:flutter/material.dart';

import 'package:wsidappp/config/theme/theme_extensions.dart';

enum WsidTaskRowVariant {
  defaultRow,
  completed,
}

class WsidTaskRow extends StatelessWidget {
  const WsidTaskRow({
    super.key,
    required this.title,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.onTap,
    this.variant = WsidTaskRowVariant.defaultRow,
  });

  final String title;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;
  final VoidCallback onTap;
  final WsidTaskRowVariant variant;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = variant == WsidTaskRowVariant.completed;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: context.radius.md,
                ),
                child: Icon(
                  categoryIcon,
                  size: 24,
                  color: categoryColor.computeLuminance() > 0.5
                      ? context.colors.onSurface
                      : context.colors.surface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.txt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? context.colors.onSurfaceVariant
                            : context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.txt.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

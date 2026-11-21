import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';

/// Dashed "add category" grid cell (`332:1718`).
class CategoryAddGridCard extends StatelessWidget {
  const CategoryAddGridCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;

    if (!context.isLightTheme) {
      return Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add, size: 28, color: context.colors.primary),
                const SizedBox(height: 8),
                Text(
                  l10n.addCategory,
                  style: context.txt.labelLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: brand.dashedAddFill,
      borderRadius: context.radius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.card,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            radius: 20,
            strokeColor: brand.dashedAddStroke,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.dashboard_customize_outlined,
                  size: 28,
                  color: brand.chipAddIcon,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.addCategory,
                  style: context.typo.bodyBold.copyWith(color: brand.chipAddIcon),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.radius,
    required this.strokeColor,
  });

  final double radius;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Paint paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Path path = Path()..addRRect(rrect);
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      const double dash = 6;
      const double gap = 4;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.strokeColor != strokeColor;
}
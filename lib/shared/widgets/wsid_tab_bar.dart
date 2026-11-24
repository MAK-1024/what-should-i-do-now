import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';

/// Clean tab bar matching Figma task screen design (rounded container, sage indicator).
class WsidTabBar extends StatelessWidget {
  const WsidTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    assert(labels.isNotEmpty);
    final isLight = context.isLightTheme;
    final bg = isLight ? context.brand.cardFill : context.colors.surface;
    final border = isLight ? context.brand.cardBorder : context.colors.outlineVariant;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: border),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                for (int i = 0; i < labels.length; i++)
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () => onChanged(i),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: context.txt.labelLarge?.copyWith(
                            color: i == selectedIndex
                                ? context.colors.primary
                                : (isLight
                                    ? context.brand.mutedText
                                    : context.colors.onSurfaceVariant),
                            fontWeight: i == selectedIndex
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Stack(
            children: <Widget>[
              Container(height: 2.5, color: Colors.transparent),
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: selectedIndex == 0
                    ? Alignment.bottomLeft
                    : Alignment.bottomRight,
                child: FractionallySizedBox(
                  widthFactor: 1.0 / labels.length,
                  child: Container(
                    height: 2.5,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

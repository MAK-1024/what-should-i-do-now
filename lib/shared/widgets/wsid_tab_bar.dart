import 'package:flutter/material.dart';

import 'package:wsidappp/config/theme/theme_extensions.dart';

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

    return SizedBox(
      height: 48,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                for (int i = 0; i < labels.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onChanged(i),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: context.txt.labelLarge?.copyWith(
                            color: i == selectedIndex
                                ? context.colors.primary
                                : context.colors.onSurfaceVariant,
                            fontWeight: i == selectedIndex
                                ? FontWeight.w800
                                : FontWeight.w600,
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
              Container(height: 2, color: context.colors.outlineVariant),
              Row(
                children: <Widget>[
                  for (int i = 0; i < labels.length; i++)
                    Expanded(
                      child: i == selectedIndex
                          ? Container(
                              height: 2,
                              color: context.colors.primary,
                            )
                          : const SizedBox(height: 2),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

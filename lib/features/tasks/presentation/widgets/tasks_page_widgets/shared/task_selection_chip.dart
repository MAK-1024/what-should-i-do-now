import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';

/// Figma filter chip: default, selected, or dashed add tile.
class TaskSelectionChip extends StatelessWidget {
  const TaskSelectionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  const TaskSelectionChip.add({
    super.key,
    required this.onTap,
  })  : label = null,
        selected = false;

  final String? label;
  final bool selected;
  final VoidCallback onTap;

  bool get _isAdd => label == null;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    if (_isAdd) {
      return Material(
        color: brand.chipAddFill,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 62,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: brand.chipAddBorder,
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Icon(
              Icons.add,
              size: 24,
              color: brand.chipAddIcon,
            ),
          ),
        ),
      );
    }

    return Material(
      color: selected ? brand.chipSelectedBg : brand.chipUnselectedBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: selected
            ? BorderSide.none
            : BorderSide(color: brand.chipUnselectedBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Text(
            label!,
            style: context.typo.bodyBold.copyWith(
              color: selected ? brand.chipSelectedFg : brand.chipUnselectedFg,
            ),
          ),
        ),
      ),
    );
  }
}
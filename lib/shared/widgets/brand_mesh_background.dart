import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/app_assets.dart';

/// Full-screen mesh glow from Figma `429:3208` (`bg` ingredient).
///
/// Used behind onboarding and auth in light mode; dark uses [BrandPalette.pageBackground] only.
class BrandMeshBackground extends StatelessWidget {
  const BrandMeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.brand.pageBackground,
      child: context.isLightTheme
          ? SvgPicture.asset(
              AppAssets.brandMeshBackground,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              clipBehavior: Clip.hardEdge,
              semanticsLabel: '',
              excludeFromSemantics: true,
            )
          : const SizedBox.shrink(),
    );
  }
}
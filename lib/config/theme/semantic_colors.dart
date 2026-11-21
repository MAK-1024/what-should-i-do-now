import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/app_colors.dart';

/// Resolves colors for Figma-aligned light UI vs pre-refactor dark [ColorScheme].
class BrandPalette {
  const BrandPalette(this._context);

  final BuildContext _context;

  bool get _light => Theme.of(_context).brightness == Brightness.light;

  ColorScheme get _colors => Theme.of(_context).colorScheme;

  /// Full-screen scaffold: white in light, dark canvas in dark (matches [buildDarkTheme]).
  Color get scaffoldBackground =>
      _light ? AppColors.surface : AppColors.darkBackground;

  Color get pageBackground => scaffoldBackground;

  /// Splash / marketing screens: white in light, dark scaffold in dark.
  Color get splashBackground =>
      _light ? AppColors.surface : AppColors.darkBackground;

  Color get scaffoldAlt =>
      _light ? AppColors.background : _colors.surface;

  Color get cardFill => _light ? AppColors.surface : _colors.surface;

  Color get cardBorder =>
      _light ? AppColors.grey50 : _colors.outlineVariant;

  Color get divider => cardBorder;

  /// Inset dividers inside grouped cards (profile/tasks list style).
  bool get groupedCardDividers => !_light;

  Color get titleText =>
      _light ? AppColors.grey700 : _colors.onSurface;

  Color get headlineText =>
      _light ? AppColors.grey900 : _colors.onSurface;

  Color get bodyText =>
      _light ? AppColors.grey700 : _colors.onSurface;

  Color get mutedText =>
      _light ? AppColors.grey500 : _colors.onSurfaceVariant;

  Color get captionMuted =>
      _light ? AppColors.greyNeutral : _colors.onSurfaceVariant;

  Color get hintText =>
      _light ? AppColors.grey300 : _colors.onSurfaceVariant;

  Color get fieldLabel =>
      _light ? AppColors.green500 : _colors.primary;

  Color get sectionLabel =>
      _light ? AppColors.green600 : _colors.primary;

  Color get fieldValue =>
      _light ? AppColors.green800 : _colors.onSurface;

  Color get primaryAction =>
      _light ? AppColors.green500 : _colors.primary;

  Color get onPrimaryAction =>
      _light ? AppColors.onPrimary : _colors.onPrimary;

  Color get inputFill => cardFill;

  Color get inputBorder =>
      _light ? AppColors.inputOutline : _colors.outline;

  Color get inputBorderFocused =>
      _light ? AppColors.green500 : _colors.primary;

  Color get chipSelectedBg => primaryAction;

  Color get chipSelectedFg => onPrimaryAction;

  Color get chipUnselectedBg => cardFill;

  Color get chipUnselectedBorder => cardBorder;

  Color get chipUnselectedFg =>
      _light ? AppColors.grey700 : _colors.onSurface;

  Color get chipAddFill =>
      _light ? AppColors.green50 : _colors.primaryContainer;

  Color get chipAddBorder =>
      _light ? AppColors.green300 : _colors.primary;

  Color get chipAddIcon =>
      _light ? AppColors.green700 : _colors.primary;

  Color get iconMuted => hintText;

  Color get iconOnTint =>
      _light ? AppColors.grey700 : _colors.onSurface;

  Color get linkThumbBg =>
      _light ? AppColors.green100 : _colors.primaryContainer;

  Color get warningAccent =>
      _light ? AppColors.warning700 : _colors.tertiary;

  Color get warningSurface =>
      _light ? AppColors.warning50 : _colors.tertiaryContainer;

  Color get priorityHighTint =>
      _light ? AppColors.error800 : _colors.error;

  Color get priorityMediumTint => warningAccent;

  Color get priorityLowTint =>
      _light ? AppColors.green600 : _colors.primary;

  Color get categoryBadgeTint =>
      _light ? AppColors.green600 : _colors.primary;

  Color get destructiveBorder =>
      _light ? AppColors.error500 : _colors.error;

  Color get destructiveText =>
      _light ? AppColors.error700 : _colors.error;

  Color get dashedAddFill => chipAddFill;

  Color get dashedAddStroke => chipAddBorder;

  /// Category icon circle background (Figma preset; dark uses primary container).
  Color categoryIconCircle(Color lightPreset) =>
      _light ? lightPreset : _colors.primaryContainer;

  Color get iconPickerSelectedFill =>
      _light ? AppColors.green100 : _colors.primaryContainer;

  Color get iconPickerUnselectedFill =>
      _light ? AppColors.grey50 : _colors.surfaceContainerHighest;

  Color get previewWellFill =>
      _light ? AppColors.green50 : _colors.surfaceContainerHighest;

  Color get pageIndicatorActive => primaryAction;

  Color get pageIndicatorInactive =>
      _light ? AppColors.green200 : _colors.outlineVariant;
}
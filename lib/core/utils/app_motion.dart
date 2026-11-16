import 'package:flutter/widgets.dart';

/// Motion tokens shared by all `flutter_animate` usages.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);

  /// Interval between titles while the suggestion card is cycling (starting speed).
  static const Duration cycleStartTick = Duration(milliseconds: 50);

  /// Interval between titles as the wheel reaches maximum deceleration.
  static const Duration cycleEndTick = Duration(milliseconds: 400);

  /// Interval between titles while the suggestion card is cycling (fallback).
  static const Duration cycleTick = Duration(milliseconds: 180);

  /// Minimum time the suggestion card cycles before revealing the winner.
  static const Duration cycleTotal = Duration(milliseconds: 2000);

  static const Duration staggerStep = Duration(milliseconds: 60);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;

  static bool isEnabled(BuildContext context) =>
      !MediaQuery.disableAnimationsOf(context);

  /// Returns [duration], or [Duration.zero] when animations are disabled.
  static Duration of(BuildContext context, Duration duration) =>
      isEnabled(context) ? duration : Duration.zero;
}

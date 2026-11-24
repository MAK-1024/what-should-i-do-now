import 'package:flutter/material.dart';

/// Exposes open/close for the shell side menu ([AppSideMenu]).
class ShellDrawerScope extends InheritedWidget {
  const ShellDrawerScope({
    super.key,
    required this.openDrawer,
    required this.closeDrawer,
    required super.child,
  });

  final VoidCallback openDrawer;
  final VoidCallback closeDrawer;

  static ShellDrawerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellDrawerScope>();
  }

  static ShellDrawerScope of(BuildContext context) {
    final ShellDrawerScope? scope = maybeOf(context);
    assert(scope != null, 'ShellDrawerScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShellDrawerScope oldWidget) => false;
}
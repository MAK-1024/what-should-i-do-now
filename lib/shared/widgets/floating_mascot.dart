import 'package:flutter/material.dart';
import 'package:wsidappp/core/utils/app_motion.dart';

/// Gentle bobbing / floating animation that moves [child] slightly up and down,
/// creating a floating-in-the-air effect for mascot illustrations.
class FloatingMascot extends StatefulWidget {
  const FloatingMascot({
    super.key,
    required this.child,
    this.offsetY = 7.0,
    this.duration = const Duration(milliseconds: 2200),
  });

  final Widget child;
  final double offsetY;
  final Duration duration;

  @override
  State<FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<FloatingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: -widget.offsetY,
      end: widget.offsetY,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppMotion.isEnabled(context)) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

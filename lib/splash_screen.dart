import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/core/constants/app_assets.dart';

/// Animated splash screen for "What Should I Do?".
///
/// Re-creates the 5-frame Figma prototype (Smart Animate, ease-in-out):
///
///   0  blank green            --0.8s-->  (0.1s fade in)
///   1  eyes open + wordmark   --0.3s-->  (0.2s)
///   2  eyes frown (15°)       --0.5s-->  (0.3s)
///   3  eyes frown (20°), face squashed --1.0s--> (0.3s)
///   4  white screen: app icon + big green wordmark
///
/// The face, eyes, lids and brows are drawn with a [CustomPainter] (exact
/// Figma paths, no assets). The wordmark and the app icon are two small SVGs
/// rendered with `flutter_svg`:
///
///   assets/splash/wordmark.svg   (single colour, recoloured in code)
///   assets/splash/app_icon.svg
///
/// Usage:
/// ```dart
/// SplashScreen(
///   onFinished: () => Navigator.of(context).pushReplacement(
///     MaterialPageRoute(builder: (_) => const HomePage()),
///   ),
/// )
/// ```
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
    this.backgroundColor = AppColors.green500,
    this.faceColor = _green400, // not in AppColors yet (Figma green-400)
    this.wordmarkColor = AppColors.green500, // final wordmark colour
    this.finalBackgroundColor = AppColors.surface,
    this.wordmarkAsset = AppAssets.splashWordmark,
    this.iconAsset = AppAssets.splashIcon,
    this.holdAfter = const Duration(milliseconds: 600),
  });

  static const Color _green400 = Color(0xFF7CA18C);

  /// Called once the animation has played and the last frame was held.
  final VoidCallback onFinished;

  final Color backgroundColor;

  /// Colour of the face blob, eyelids and brows.
  final Color faceColor;

  /// Colour the wordmark ends with (it starts white).
  final Color wordmarkColor;

  final Color finalBackgroundColor;
  final String wordmarkAsset;
  final String iconAsset;

  /// How long to keep the final frame before [onFinished].
  final Duration holdAfter;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _Timeline.total.round()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  Future<void> _run() async {
    // Respect the system "reduce motion" setting: jump to the final frame.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      await _controller.forward();
    }
    if (!mounted) return;
    await Future<void>.delayed(widget.holdAfter);
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final p = _Progress.at(_controller.value * _Timeline.total);
        final bg = Color.lerp(
          widget.backgroundColor,
          widget.finalBackgroundColor,
          p.finale,
        )!;

        return Scaffold(
          backgroundColor: bg,
          body: Center(
            child: Semantics(
              label: 'What Should I Do',
              child: FittedBox(
                child: SizedBox(
                  width: _designWidth,
                  height: _designHeight,
                  child: Stack(
                    children: [
                      // Face, eyes, lids, brows.
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _LogoPainter(p, widget.faceColor),
                          ),
                        ),
                      ),
                      // Wordmark: white at the bottom -> green and bigger,
                      // moving to the centre.
                      Positioned(
                        left: lerpDouble(151, 123, p.finale)!,
                        top: lerpDouble(689, 431, p.finale)!,
                        width: lerpDouble(128, 184, p.finale)!,
                        height: lerpDouble(128, 184, p.finale)! * 160 / 184,
                        child: Opacity(
                          opacity: p.fade,
                          child: SvgPicture.asset(
                            widget.wordmarkAsset,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              Color.lerp(
                                Colors.white,
                                widget.wordmarkColor,
                                p.finale,
                              )!,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      // App icon: fades in with the last transition.
                      if (p.finale > 0)
                        Positioned(
                          left: 178,
                          top: 312,
                          width: 75,
                          height: 71,
                          child: Opacity(
                            opacity: p.finale,
                            child: widget.iconAsset.toLowerCase().endsWith('.svg')
                                ? SvgPicture.asset(widget.iconAsset)
                                : Image.asset(widget.iconAsset),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline (milliseconds). Mirrors the prototype: AFTER_TIMEOUT delays and
// Smart Animate durations, ease-in-out.
// ---------------------------------------------------------------------------

class _Timeline {
  static const double blank = 800; // frame 0 hold
  static const double fadeIn = 100; // 0 -> 1
  static const double hold1 = 300;
  static const double toFrown1 = 200; // 1 -> 2
  static const double hold2 = 500;
  static const double toFrown2 = 300; // 2 -> 3
  static const double hold3 = 1000;
  static const double toFinal = 300; // 3 -> 4

  static const double fadeInAt = blank;
  static const double frown1At = fadeInAt + fadeIn + hold1;
  static const double frown2At = frown1At + toFrown1 + hold2;
  static const double finalAt = frown2At + toFrown2 + hold3;
  static const double total = finalAt + toFinal; // 3500
}

double _seg(double ms, double start, double duration) => Curves.easeInOut
    .transform(((ms - start) / duration).clamp(0.0, 1.0).toDouble());

class _Progress {
  const _Progress(this.fade, this.frown, this.finale);

  /// 0..1: logo + wordmark fade in (frame 0 -> 1).
  final double fade;

  /// 0..2: 0 = frame 1, 1 = frame 2, 2 = frame 3.
  final double frown;

  /// 0..1: frame 3 -> final white frame.
  final double finale;

  factory _Progress.at(double ms) => _Progress(
        _seg(ms, _Timeline.fadeInAt, _Timeline.fadeIn),
        _seg(ms, _Timeline.frown1At, _Timeline.toFrown1) +
            _seg(ms, _Timeline.frown2At, _Timeline.toFrown2),
        _seg(ms, _Timeline.finalAt, _Timeline.toFinal),
      );
}

// ---------------------------------------------------------------------------
// Drawing. Coordinates are those of the 430 x 932 Figma frame.
// ---------------------------------------------------------------------------

const double _designWidth = 430;
const double _designHeight = 932;

/// Face blob, frames 1-2. 25 points: start + 8 cubic segments.
const List<Offset> _faceCalm = [
  Offset(142.22227, 436.75),
  Offset(141.72216, 457.75), Offset(142.22227, 492.75), Offset(142.22227, 492.75),
  Offset(144.22227, 517.75), Offset(194.75454, 528.75), Offset(201.72229, 492.75),
  Offset(208.72229, 484.25), Offset(220.22228, 484.25), Offset(225.72228, 492.75),
  Offset(235.22228, 527.25), Offset(279.22223, 523.25), Offset(287.22223, 492.75),
  Offset(287.22223, 474.75), Offset(287.22223, 436.75), Offset(287.22223, 436.75),
  Offset(280.22223, 407.75), Offset(234.72228, 407.75), Offset(227.72228, 436.75),
  Offset(221.72229, 445.25), Offset(205.22229, 444.25), Offset(201.72229, 436.75),
  Offset(190.72217, 403.75), Offset(147.22217, 415.75), Offset(142.22227, 436.75),
];

/// Face blob, frame 3 (squashed: 145 x 89 at y = 421).
const List<Offset> _faceFrown = [
  Offset(142.22193, 439.95044),
  Offset(141.72258, 458.24743), Offset(142.22193, 488.74237), Offset(142.22193, 488.74237),
  Offset(144.21887, 510.52448), Offset(194.67382, 520.10861), Offset(201.6309, 488.74237),
  Offset(208.62018, 481.33646), Offset(220.10258, 481.33646), Offset(225.59416, 488.74237),
  Offset(235.07963, 518.80169), Offset(279.01225, 515.31655), Offset(287, 488.74237),
  Offset(287, 473.05926), Offset(287, 439.95044), Offset(287, 439.95044),
  Offset(280.01071, 414.68319), Offset(234.58039, 414.68318), Offset(227.5911, 439.95044),
  Offset(221.60029, 447.35635), Offset(205.12554, 446.48507), Offset(201.6309, 439.95044),
  Offset(190.64761, 411.19808), Offset(147.21418, 421.65349), Offset(142.22193, 439.95044),
];

/// Bottom eyelids (cheeks): 13 points, same order in every keyframe so they
/// can be interpolated point by point, exactly like Smart Animate.
List<Offset> _lid(
  double ox,
  double oy,
  double w,
  double h,
  double sideY,
  double bottomCtrlY,
  double topCtrlY,
) {
  final c = w / 2;
  final a = w * 0.7762;
  final b = w * 0.2238;
  return [
    Offset(w, sideY),
    Offset(w, bottomCtrlY), Offset(a, h), Offset(c, h),
    Offset(b, h), Offset(0, bottomCtrlY), Offset(0, sideY),
    Offset(0, topCtrlY), Offset(b, 0), Offset(c, 0),
    Offset(a, 0), Offset(w, topCtrlY), Offset(w, sideY),
  ].map((p) => p + Offset(ox, oy)).toList();
}

final List<List<Offset>> _lidsLeft = [
  _lid(153, 501, 42, 11.5, 5.0233, 7.7975, 2.249),
  _lid(146, 490, 53, 18, 10.0465, 15.595, 4.498),
  _lid(146, 481.29, 53, 20.5753, 12.9194, 20.0545, 5.7842),
];
final List<List<Offset>> _lidsRight = [
  _lid(236, 501, 42, 11, 5.0233, 7.7975, 2.249),
  _lid(229, 490, 53, 17.5, 9.4186, 14.6204, 4.2169),
  _lid(231, 481.29, 53, 20.5753, 12.9194, 20.0545, 5.7842),
];

/// Brows: [centerX, centerY, width, height, angleDegrees (clockwise)].
const List<List<double>> _browsLeft = [
  [174, 423, 32, 8, 0],
  [175, 431, 54, 12, 15],
  [177.4, 432.9, 54, 12, 20],
];
const List<List<double>> _browsRight = [
  [258, 423, 32, 8, 0],
  [254, 431, 54, 12, -15],
  [251.4, 432.9, 54, 12, -20],
];

List<double> _stage(List<List<double>> k, double s) {
  final i = s <= 1 ? 0 : 1;
  final t = s <= 1 ? s : s - 1;
  return [for (var j = 0; j < k[i].length; j++) lerpDouble(k[i][j], k[i + 1][j], t)!];
}

List<Offset> _stagePts(List<List<Offset>> k, double s) {
  final i = s <= 1 ? 0 : 1;
  final t = s <= 1 ? s : s - 1;
  return _lerpPts(k[i], k[i + 1], t);
}

List<Offset> _lerpPts(List<Offset> a, List<Offset> b, double t) =>
    [for (var i = 0; i < a.length; i++) Offset.lerp(a[i], b[i], t)!];

Path _cubicPath(List<Offset> pts) {
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 1; i + 2 < pts.length; i += 3) {
    path.cubicTo(
      pts[i].dx, pts[i].dy,
      pts[i + 1].dx, pts[i + 1].dy,
      pts[i + 2].dx, pts[i + 2].dy,
    );
  }
  return path..close();
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter(this.p, this.color);

  final _Progress p;
  final Color color;

  void _eye(
    Canvas canvas, {
    required double x,
    required double top,
    required double height,
    required double pupilY,
    required double sparkleDy,
  }) {
    canvas
      ..save()
      ..translate(x, top)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, 47, height),
          Radius.circular(height < 47 ? height / 2 : 23.5),
        ),
        Paint()..color = Colors.white,
      );
    final pupil = RRect.fromRectAndRadius(
      Rect.fromLTWH(9, pupilY, 29, 48),
      const Radius.circular(14.5),
    );
    canvas
      ..save()
      ..clipRRect(pupil)
      ..drawRRect(pupil, Paint()..color = Colors.black)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(4, pupilY + sparkleDy, 18, 18),
          const Radius.circular(9),
        ),
        Paint()..color = Colors.white,
      )
      ..restore()
      ..restore();
  }

  void _brow(Canvas canvas, List<double> b, Paint paint) {
    canvas
      ..save()
      ..translate(b[0], b[1])
      ..rotate(b[4] * 3.1415926535 / 180)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: b[2], height: b[3]),
          const Radius.circular(4),
        ),
        paint,
      )
      ..restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = p.fade * (1 - p.finale);
    if (opacity <= 0) return;

    // One layer so overlapping same-colour shapes fade as a single image.
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
    );

    final paint = Paint()..color = color;
    final s = p.frown;
    final c = (s - 1).clamp(0.0, 1.0).toDouble(); // only frame 2 -> 3 squashes

    // Face
    canvas.drawPath(_cubicPath(_lerpPts(_faceCalm, _faceFrown, c)), paint);

    // Eyes (frame 3: 74.6 high, pupil 2px higher)
    final eyeTop = lerpDouble(427, 426.7, c)!;
    final eyeH = lerpDouble(78, 74.6, c)!;
    final pupilY = lerpDouble(15, 13, c)!;
    _eye(canvas,
        x: 150, top: eyeTop, height: eyeH, pupilY: pupilY, sparkleDy: -5);
    _eye(canvas,
        x: 234, top: eyeTop, height: eyeH, pupilY: pupilY, sparkleDy: -3);

    // Bottom lids
    canvas.drawPath(_cubicPath(_stagePts(_lidsLeft, s)), paint);
    canvas.drawPath(_cubicPath(_stagePts(_lidsRight, s)), paint);

    // Brows (drawn last, above the eyes)
    _brow(canvas, _stage(_browsLeft, s), paint);
    _brow(canvas, _stage(_browsRight, s), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => true;
}
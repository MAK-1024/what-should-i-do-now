import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/onboarding/presentation/widgets/onboarding_page_widgets/sections/onboarding_actions.dart';
import 'package:wsidappp/shared/widgets/brand_mesh_background.dart';
import 'package:wsidappp/features/onboarding/presentation/widgets/onboarding_page_widgets/sections/onboarding_slide.dart';
import 'package:wsidappp/features/onboarding/presentation/widgets/onboarding_page_widgets/shared/onboarding_page_indicator.dart';

/// Three-slide onboarding: brand wordmark, swipeable mascot slides, page
/// indicator and skip / next actions.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Reference frame height; vertical offsets scale proportionally to it.
  static const double _designHeight = 932;
  static const double _maxContentWidth = 430;
  static const Size _wordmarkSize = Size(90, 78);
  static const double _controlsHeight = 80;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    await prefs.setBool('onboarding_complete', true);
    if (mounted) context.go(RouteList.auth);
  }

  void _onNextPressed(int pageCount) {
    if (_currentPage == pageCount - 1) {
      _completeOnboarding();
      return;
    }
    final Duration duration = AppMotion.of(context, AppMotion.medium);
    if (duration == Duration.zero) {
      _pageController.jumpToPage(_currentPage + 1);
    } else {
      _pageController.nextPage(duration: duration, curve: AppMotion.standard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final EdgeInsets safeArea = MediaQuery.paddingOf(context);

    final List<OnboardingSlide> slides = <OnboardingSlide>[
      OnboardingSlide(
        imagePath: AppAssets.onboardingSpin,
        imageSize: 224,
        title: l10n.onboardingTitle1,
        subtitle: l10n.onboardingSubtitle1,
      ),
      OnboardingSlide(
        imagePath: AppAssets.onboardingIdea,
        imageSize: 244,
        title: l10n.onboardingTitle2,
        subtitle: l10n.onboardingSubtitle2,
      ),
      OnboardingSlide(
        imagePath: AppAssets.onboardingFocus,
        imageSize: 224,
        title: l10n.onboardingTitle3,
        subtitle: l10n.onboardingSubtitle3,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: BrandMeshBackground()),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double scale = constraints.maxHeight / _designHeight;
              final double wordmarkTop =
                  math.max(safeArea.top + 12, 122 * scale);
              final double controlsBottom =
                  math.max(safeArea.bottom + 16, 127 * scale);

              return Stack(
                children: <Widget>[
                  Positioned(
                    top: wordmarkTop,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.brandWordmark,
                        width: _wordmarkSize.width,
                        height: _wordmarkSize.height,
                        semanticsLabel: l10n.whatShouldIDo,
                      ),
                    ).animate().fadeIn(
                          duration: AppMotion.of(context, AppMotion.slow),
                          curve: AppMotion.standard,
                        ),
                  ),
                  Positioned(
                    top: wordmarkTop + _wordmarkSize.height,
                    bottom: controlsBottom + _controlsHeight,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _maxContentWidth),
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (int index) =>
                              setState(() => _currentPage = index),
                          children: slides
                              .map(
                                (OnboardingSlide slide) => Align(
                                  alignment: Alignment.center,
                                  child: slide,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: controlsBottom,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _maxContentWidth),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              OnboardingPageIndicator(
                                count: slides.length,
                                currentIndex: _currentPage,
                              ),
                              const SizedBox(height: 28),
                              OnboardingActions(
                                isLastPage: _currentPage == slides.length - 1,
                                onSkip: _completeOnboarding,
                                onNext: () => _onNextPressed(slides.length),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/utils/app_motion.dart';

/// Shared shimmer loading surfaces (flutter_animate), used instead of spinners.
abstract final class WsidShimmer {
  static Color base(BuildContext context) =>
      context.colors.surfaceContainerHighest;

  static Widget apply(BuildContext context, Widget child) {
    if (!AppMotion.isEnabled(context)) return child;
    return child
        .animate(onPlay: (AnimationController controller) => controller.repeat())
        .shimmer(
          duration: AppMotion.slow * 3,
          color: context.colors.surface,
        );
  }
}

/// Task / pending list placeholder inside a [Card].
class WsidShimmerListCard extends StatelessWidget {
  const WsidShimmerListCard({
    super.key,
    this.rowCount = 3,
    this.rowHeight = 64,
  });

  final int rowCount;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return WsidShimmer.apply(
      context,
      Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: List<Widget>.generate(rowCount, (int index) {
              return SizedBox(
                height: rowHeight,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: WsidShimmer.base(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 12,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: WsidShimmer.base(context),
                                borderRadius: context.radius.sm,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 10,
                              width: 120,
                              decoration: BoxDecoration(
                                color: WsidShimmer.base(context),
                                borderRadius: context.radius.sm,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Categories grid skeleton (2 columns).
class WsidShimmerCategoryGrid extends StatelessWidget {
  const WsidShimmerCategoryGrid({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: WsidShimmer.apply(
        context,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.92,
          ),
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: WsidShimmer.base(context),
                        borderRadius: context.radius.md,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: WsidShimmer.base(context),
                        borderRadius: context.radius.sm,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 72,
                      decoration: BoxDecoration(
                        color: WsidShimmer.base(context),
                        borderRadius: context.radius.sm,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Profile screen skeleton.
class WsidShimmerProfileBody extends StatelessWidget {
  const WsidShimmerProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar({double? width}) => Container(
          height: 14,
          width: width,
          decoration: BoxDecoration(
            color: WsidShimmer.base(context),
            borderRadius: context.radius.sm,
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: WsidShimmer.apply(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: WsidShimmer.base(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          bar(),
                          const SizedBox(height: 10),
                          bar(width: 140),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < 2; i++) ...<Widget>[
              bar(width: 100),
              const SizedBox(height: 12),
              Card(
                child: SizedBox(
                  height: 160,
                  child: ColoredBox(color: WsidShimmer.base(context)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

/// Home decider card skeleton.
class WsidShimmerDeciderCard extends StatelessWidget {
  const WsidShimmerDeciderCard({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar({double? width, double height = 12}) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: WsidShimmer.base(context),
            borderRadius: context.radius.sm,
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: WsidShimmer.apply(
        context,
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                bar(height: 16),
                const SizedBox(height: 10),
                Align(child: bar(width: 200, height: 14)),
                const SizedBox(height: 8),
                Align(child: bar(width: 140)),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: WsidShimmer.base(context),
                          borderRadius: context.radius.lg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: WsidShimmer.base(context),
                          borderRadius: context.radius.lg,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered list shimmer with outer padding (tasks list fallback).
class WsidShimmerPageLoader extends StatelessWidget {
  const WsidShimmerPageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: WsidShimmerListCard(rowCount: 4),
    );
  }
}
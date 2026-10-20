import 'package:flutter/material.dart';
import 'mf_groww_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MUTUAL FUNDS SHIMMER & SKELETON SUITE
/// Native, zero-dependency, smooth 60fps shimmer loaders for all MF screens.
/// ─────────────────────────────────────────────────────────────────────────────

/// Base Shimmer Controller Widget
class MfShimmer extends StatefulWidget {
  final Widget child;
  const MfShimmer({super.key, required this.child});

  @override
  State<MfShimmer> createState() => MfShimmerState();

  /// Helper to wrap an entire skeleton tree in one synced shimmer animation
  static MfShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<MfShimmerState>();
  }
}

class MfShimmerState extends State<MfShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Animation<double> get animation => _anim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => widget.child,
    );
  }
}

/// A single shimmer placeholder box
class MfShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const MfShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final shimmerParent = MfShimmer.of(context);
    final progress = shimmerParent?.animation.value ?? 0.5;

    // Dark slate pulse matching Groww theme
    const baseColor = Color(0xFF161B26);
    const highlightColor = Color(0xFF263246);
    final color = Color.lerp(baseColor, highlightColor, progress)!;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A skeleton fund tile matching the exact layout of Mutual Fund list items
class MfFundTileSkeleton extends StatelessWidget {
  const MfFundTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo placeholder
          const MfShimmerBox(width: 40, height: 40, borderRadius: 10),
          const SizedBox(width: 14),

          // Title & Category placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                MfShimmerBox(width: 180, height: 14, borderRadius: 4),
                SizedBox(height: 8),
                MfShimmerBox(width: 110, height: 11, borderRadius: 3),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Return & Period placeholders
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: const [
              MfShimmerBox(width: 58, height: 16, borderRadius: 4),
              SizedBox(height: 6),
              MfShimmerBox(width: 32, height: 11, borderRadius: 3),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vertical list of fund tile skeletons
class MfFundListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const MfFundListSkeleton({
    super.key,
    this.itemCount = 6,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return MfShimmer(
      child: ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding ?? EdgeInsets.zero,
        itemCount: itemCount,
        separatorBuilder: (context, index) => const Divider(color: GrowwColors.border, height: 1),
        itemBuilder: (context, index) => const MfFundTileSkeleton(),
      ),
    );
  }
}

/// Complete Skeleton for the Mutual Funds Home / Explore Screen
class MfExploreSkeletonView extends StatelessWidget {
  const MfExploreSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return MfShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // 1. Onboarding suggestion banner skeleton
          const MfShimmerBox(height: 52, borderRadius: 12),
          const SizedBox(height: 14),

          // 2. Hero SIP Banner skeleton
          const MfShimmerBox(height: 120, borderRadius: 18),
          const SizedBox(height: 24),

          // 3. Popular Funds Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              MfShimmerBox(width: 120, height: 18, borderRadius: 4),
              MfShimmerBox(width: 60, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),

          // 4. Popular Funds Horizontal Carousel Skeleton
          SizedBox(
            height: 145,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => Container(
                width: 190,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GrowwColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GrowwColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    MfShimmerBox(width: 36, height: 36, borderRadius: 8),
                    SizedBox(height: 12),
                    MfShimmerBox(width: 140, height: 13, borderRadius: 4),
                    SizedBox(height: 6),
                    MfShimmerBox(width: 90, height: 11, borderRadius: 4),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MfShimmerBox(width: 50, height: 15, borderRadius: 4),
                        MfShimmerBox(width: 24, height: 12, borderRadius: 3),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 5. Collections Section Header
          const MfShimmerBox(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: 14),

          // 6. Collections 3x2 Grid Skeleton
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.95,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: GrowwColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GrowwColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  MfShimmerBox(width: 44, height: 44, borderRadius: 10),
                  SizedBox(height: 10),
                  MfShimmerBox(width: 65, height: 11, borderRadius: 3),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 7. Products & Tools Section Header
          const MfShimmerBox(width: 130, height: 18, borderRadius: 4),
          const SizedBox(height: 14),

          // 8. Products & Tools Grid Skeleton
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 10 : 0),
                  height: 72,
                  decoration: BoxDecoration(
                    color: GrowwColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GrowwColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      MfShimmerBox(width: 26, height: 26, borderRadius: 6),
                      SizedBox(height: 6),
                      MfShimmerBox(width: 48, height: 9, borderRadius: 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 9. All Mutual Funds Header & Filter Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              MfShimmerBox(width: 140, height: 19, borderRadius: 4),
              MfShimmerBox(width: 70, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),

          // 10. Fund Items Skeleton (4 items)
          ...List.generate(
            4,
            (index) => const Column(
              children: [
                MfFundTileSkeleton(),
                Divider(color: GrowwColors.border, height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen Skeleton for All Mutual Funds, Search, or Category List views
class MfListScreenSkeleton extends StatelessWidget {
  final int itemCount;

  const MfListScreenSkeleton({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return MfShimmer(
      child: Column(
        children: [
          // Subheader count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                MfShimmerBox(width: 120, height: 13, borderRadius: 3),
                MfShimmerBox(width: 60, height: 13, borderRadius: 3),
              ],
            ),
          ),
          const Divider(color: GrowwColors.border, height: 1),

          // List of items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: itemCount,
              separatorBuilder: (context, index) => const Divider(color: GrowwColors.border, height: 1),
              itemBuilder: (context, index) => const MfFundTileSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

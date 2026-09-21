import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/l10n.dart';
import 'motion.dart';

/// A rounded placeholder block drawn in the theme's input-fill color so
/// it reads correctly in light and dark mode. Put a whole skeleton
/// layout inside a [SkeletonPulse] to animate it.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = AppDimensions.radiusSm,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.palette.inputFill,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Pulses everything below it with one controller (not one per box).
/// Static under reduced motion. Announced once as "Loading" to screen
/// readers; the boxes themselves are decorative.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = context.l10nOrNull?.loading ?? 'Loading';
    final reduce = context.reduceMotion;
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
    return Semantics(
      label: label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: reduce
            ? widget.child
            : FadeTransition(
                opacity: Tween<double>(begin: 0.45, end: 1).animate(
                    CurvedAnimation(
                        parent: _controller, curve: Curves.easeInOut)),
                child: widget.child,
              ),
      ),
    );
  }
}

/// Mirrors the doctor card layout: image, two text lines, a chip.
class DoctorCardSkeleton extends StatelessWidget {
  const DoctorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: context.palette.cardBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 80, height: 80, radius: AppDimensions.radiusMd),
          SizedBox(width: AppDimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 16),
                SizedBox(height: AppDimensions.spaceSm),
                SkeletonBox(width: 110, height: 12),
                SizedBox(height: AppDimensions.spaceSm),
                SkeletonBox(width: 70, height: 20, radius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A screen-filling column of skeleton items (doctor cards by default),
/// shown while a list endpoint loads instead of a blank spinner.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder = _doctorCard,
    this.padding = const EdgeInsets.all(AppDimensions.spaceLg),
  });

  final int itemCount;
  final WidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;

  static Widget _doctorCard(BuildContext _) => const DoctorCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView.builder(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, _) => itemBuilder(context),
      ),
    );
  }
}

/// Centered spinner for screens without a list shape (details, forms),
/// announced to screen readers as "Loading".
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        semanticsLabel: context.l10nOrNull?.loading ?? 'Loading',
      ),
    );
  }
}

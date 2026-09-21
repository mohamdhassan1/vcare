import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';

/// Reduced-motion aware timing. Every animation in the presentation
/// layer should take its duration from here so the OS accessibility
/// setting ("reduce motion") turns motion off app-wide.
extension MotionContext on BuildContext {
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  /// [duration], or zero when the platform asks for reduced motion.
  Duration motion([Duration duration = AppDurations.normal]) =>
      reduceMotion ? Duration.zero : duration;
}

/// Fades (and gently lifts) its child in once, on first build.
///
/// Used for content that appears after a load — cards, empty/error
/// states, chat welcome — so it settles instead of popping. [delay]
/// staggers items in a list; keep it small (≤ 60ms per item).
/// Renders the child immediately under reduced motion.
class FadeIn extends StatefulWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.offset = 8,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Vertical lift in logical pixels (0 for a pure fade).
  final double offset;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  bool _visible = false;
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.delay == Duration.zero) {
        setState(() => _visible = true);
      } else {
        // A real Timer (cancelled on dispose) so a screen that is torn
        // down mid-stagger leaves nothing pending.
        _delay = Timer(widget.delay, () {
          if (mounted) setState(() => _visible = true);
        });
      }
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    // Tween end moves 0 → 1 once visible; the builder animates toward it.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _visible ? 1 : 0),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: widget.child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * widget.offset),
          child: child,
        ),
      ),
    );
  }
}

/// Cross-fades between loading / error / empty / content states.
/// Thin wrapper over [AnimatedSwitcher] with the app's timing and a
/// layout that keeps the incoming child full-size (no jump).
class StateSwitcher extends StatelessWidget {
  const StateSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: context.motion(),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, if (current != null) current],
      ),
      child: child,
    );
  }
}

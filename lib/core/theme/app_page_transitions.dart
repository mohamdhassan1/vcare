import 'package:flutter/material.dart';
import 'app_dimensions.dart';

/// One page transition for every platform (including web, which has
/// none by default): the new screen fades in while sliding up a few
/// pixels, and reverses on pop. Short and identical everywhere, so the
/// app feels like one product on Android, iOS and Chrome.
///
/// Honors the OS "reduce motion" setting by showing the page at once.
class VCarePageTransitionsBuilder extends PageTransitionsBuilder {
  const VCarePageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppDurations.normal;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

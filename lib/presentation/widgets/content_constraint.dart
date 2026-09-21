import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';

/// Caps a scrollable page's content width on web/desktop and centers
/// it, so cards and full-width buttons don't stretch across a 1400px
/// window. Invisible on phones (the constraint is wider than the
/// screen). Works for a page body (an expanding child fills the
/// height) and for a bar or dialog slot (the wrapper takes only its
/// child's height — see [heightFactor] below).
class ContentConstraint extends StatelessWidget {
  const ContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = AppDimensions.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      // heightFactor 1 = wrap the child's height. Without it Align fills
      // any finite height it is given, which turned a bottom bar into a
      // full-screen box and pushed the page body to zero height.
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_styles.dart';
import 'motion.dart';

/// One destination of [AppBottomNav].
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom app bar tabs with an icon *and* a label, and a tinted pill
/// behind the selected icon — so the current tab is clear from shape and
/// text, not from color alone. Leaves a gap in the middle for the docked
/// search FAB (the notch is drawn by the enclosing [BottomAppBar]).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centerGap = 56,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Width reserved in the middle for the FAB notch.
  final double centerGap;

  @override
  Widget build(BuildContext context) {
    final half = items.length ~/ 2;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: EdgeInsets.zero,
      height: 64,
      child: Row(
        children: [
          for (var i = 0; i < half; i++) _item(i),
          SizedBox(width: centerGap),
          for (var i = half; i < items.length; i++) _item(i),
        ],
      ),
    );
  }

  Widget _item(int index) => Expanded(
        child: _NavTab(
          item: items[index],
          selected: index == currentIndex,
          onTap: () => onTap(index),
        ),
      );
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.primary : palette.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: ExcludeSemantics(
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          child: SizedBox(
            height: AppDimensions.minTouchTarget + 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The pill is the non-color cue; it grows in with the
                // icon swap so the change reads as one motion.
                AnimatedContainer(
                  duration: context.motion(AppDurations.fast),
                  curve: Curves.easeOut,
                  width: selected ? 48 : 40,
                  height: 28,
                  decoration: BoxDecoration(
                    color: selected ? palette.primaryLight : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Icon(selected ? item.selectedIcon : item.icon,
                      size: AppDimensions.iconLg, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

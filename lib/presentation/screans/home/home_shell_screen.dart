import 'package:flutter/material.dart';
import 'package:vcare/presentation/screans/inbox/ai_chat_screen.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/motion.dart';
import '../appointments/appointments_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Main application shell: bottom navigation with 4 real tabs, plus a
/// raised center button for Search (a push, not a persistent tab —
/// matches the Figma's visually distinct floating search action).
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;

  /// Short fade of the tab content on every switch. The tabs live in an
  /// IndexedStack (state is kept), so only their opacity is animated —
  /// nothing is rebuilt or re-fetched.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: AppDurations.fast,
    value: 1,
  );

  // Not `const` — AppointmentsScreen and ProfileScreen each set up
  // their own BlocProvider internally, so the list itself doesn't
  // need to be a compile-time constant.
  late final List<Widget> _tabs = [
    const HomeScreen(),
    const AIChatScreen(),
    const AppointmentsScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _fade.duration = context.motion(AppDurations.fast);
    _fade.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.4, end: 1)
            .animate(CurvedAnimation(parent: _fade, curve: Curves.easeOut)),
        child: IndexedStack(index: _index, children: _tabs),
      ),
      // Colors come from floatingActionButtonTheme / iconTheme.
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.searchDoctors,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
        child: const Icon(Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _select,
        items: [
          AppBottomNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: l10n.navHome),
          // "Sparkles" reads as AI/assistant; a chat bubble read as messaging.
          AppBottomNavItem(
              icon: Icons.auto_awesome_outlined,
              selectedIcon: Icons.auto_awesome,
              label: l10n.navAiAssistant),
          AppBottomNavItem(
              icon: Icons.calendar_today_outlined,
              selectedIcon: Icons.calendar_today_rounded,
              label: l10n.navAppointments),
          AppBottomNavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: l10n.navProfile),
        ],
      ),
    );
  }
}

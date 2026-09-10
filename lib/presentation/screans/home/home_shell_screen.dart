import 'package:flutter/material.dart';
import 'package:vcare/presentation/screans/inbox/ai_chat_screen.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
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

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _index = 0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
        child: const Icon(Icons.search, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 0),
            _navItem(Icons.chat_bubble_outline_rounded, 1),
            const SizedBox(width: 40),
            _navItem(Icons.calendar_today_outlined, 2),
            _navItem(Icons.person_outline_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int i) {
    final selected = _index == i;
    return IconButton(
      onPressed: () => setState(() => _index = i),
      icon:
          Icon(icon, color: selected ? AppColors.primary : AppColors.textHint),
    );
  }
}

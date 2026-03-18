import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'tasks/tasks_screen.dart';
import 'habits/habits_screen.dart';
import 'focus/focus_screen.dart';
import 'analytics/analytics_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    TasksScreen(),
    FocusScreen(),
    HabitsScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded,
                    label: 'Board', index: 0, current: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(icon: Icons.check_box_outlined, activeIcon: Icons.check_box_rounded,
                    label: 'Tasks', index: 1, current: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 1)),
                // Center focus button
                _FocusNavBtn(
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(icon: Icons.local_fire_department_outlined,
                    activeIcon: Icons.local_fire_department_rounded,
                    label: 'Habits', index: 3, current: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 3)),
                _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded,
                    label: 'Stats', index: 4, current: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.activeIcon,
    required this.label, required this.index,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: active ? AppTheme.green.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(active ? activeIcon : icon, size: 22,
              color: active ? AppTheme.green : AppTheme.textMuted),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: active ? AppTheme.green : AppTheme.textMuted,
            )),
          ]),
        ),
      ),
    );
  }
}

class _FocusNavBtn extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  const _FocusNavBtn({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56, height: 56,
        decoration: BoxDecoration(
          gradient: isActive
              ? AppGradients.greenPurple
              : LinearGradient(
                  colors: [AppTheme.green.withOpacity(0.4), AppTheme.purple.withOpacity(0.4)]),
          shape: BoxShape.circle,
          boxShadow: isActive ? [
            BoxShadow(
              color: AppTheme.green.withOpacity(0.4),
              blurRadius: 16, spreadRadius: 0,
            ),
          ] : [],
        ),
        child: const Icon(Icons.timer_rounded, size: 24, color: Colors.black),
      ),
    );
  }
}

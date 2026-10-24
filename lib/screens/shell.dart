import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/habit_provider.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'add_habit_screen.dart';
import 'planner_screen.dart';
import 'profile_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _idx = 0;

  static const _screens = [
    HomeScreen(),
    StatsScreen(),
    _AddPlaceholder(),
    PlannerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: _BottomNav(
        idx: _idx,
        onTap: (i) {
          if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: context.read<HabitProvider>(),
                  child: const AddHabitScreen(),
                ),
              ),
            );
          } else {
            setState(() => _idx = i);
          }
        },
      ),
    );
  }
}

class _AddPlaceholder extends StatelessWidget {
  const _AddPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _BottomNav extends StatelessWidget {
  final int idx;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.idx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surf,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NI(icon: Icons.home_rounded,            label: 'Home',    active: idx == 0, onTap: () => onTap(0)),
              _NI(icon: Icons.bar_chart_rounded,       label: 'Stats',   active: idx == 1, onTap: () => onTap(1)),
              GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.purple, AppColors.orange],
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColors.purple.withValues(alpha: .4), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
              ),
              _NI(icon: Icons.calendar_today_rounded,  label: 'Planner', active: idx == 3, onTap: () => onTap(3)),
              _NI(icon: Icons.person_rounded,          label: 'Profile', active: idx == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NI extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NI({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.purple : AppColors.txt3;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 3),
          Text(label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

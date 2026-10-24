import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../db/habit_provider.dart';
import '../utils/theme.dart';
import '../widgets/shared.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(builder: (context, prov, _) {
      if (prov.loading) return const Center(child: CircularProgressIndicator(color: AppColors.purple));

      final habits = prov.habits;
      final compMap = prov.completionMap;
      final totalComp = prov.totalCompletions;
      final bestStreak = prov.bestStreak;

      final today = DateTime.now();
      final weekBars = List.generate(7, (i) {
        final d = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i));
        final count = compMap[d] ?? 0;
        final max = habits.isEmpty ? 1 : habits.length;
        return count / max;
      });

      final bottomInset = MediaQuery.of(context).viewPadding.bottom + 50;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 56, 24, 20),
                  child: Text('Your Stats ✦', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.txt)),
                ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.0,
                children: [
                  _StatCard(icon:'🔥', value:'$bestStreak', label:'Best Streak', color:AppColors.orange, colorL:AppColors.goldL),
                  _StatCard(icon:'✅', value:'$totalComp', label:'Total Completions', color:AppColors.mint, colorL:AppColors.mintL),
                  _StatCard(icon:'📅', value:'${prov.doneToday}/${prov.totalHabits}', label:'Today Done', color:AppColors.purple, colorL:AppColors.purpleL),
                  _StatCard(icon:'⭐', value:'${habits.length}', label:'Active Habits', color:AppColors.coral, colorL:AppColors.coralL),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GlowCard(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionLabel('Last 7 Days'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final d = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i));
                      final isToday = i == 6;
                      final pct = weekBars[i];
                      return Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Text('${(pct * 100).round()}%', style: TextStyle(fontSize: 9, color: isToday ? AppColors.purple : AppColors.txt3, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Expanded(child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: pct.clamp(0.05, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: isToday ? const LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [AppColors.purple, Color(0xFF9B6FFF)]) : null,
                                  color: isToday ? null : AppColors.purpleL,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                              ),
                            ),
                          )),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('E').format(d).substring(0,1),
                            style: TextStyle(fontSize: 11, color: isToday ? AppColors.purple : AppColors.txt3, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500),
                          ),
                        ]),
                      ));
                    }),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            GlowCard(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionLabel('Activity Map  Last 13 Weeks'),
                const SizedBox(height: 14),
                _HeatMap(compMap: compMap, maxPerDay: habits.isEmpty ? 1 : habits.length),
              ]),
            ),
            const SizedBox(height: 20),

            if (habits.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: SectionLabel('Habit Breakdown'),
              ),
              const SizedBox(height: 12),
              ...habits.map((h) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: GlowCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: h.colorLight, borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(h.emoji, style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(h.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.txt)),
                      const SizedBox(height: 6),
                      GradientProgressBar(value: h.streak / max(h.bestStreak, 1).toDouble(), colors: [h.color, h.color.withValues(alpha: .5)]),
                      const SizedBox(height: 4),
                      Text('${h.streak} day streak • best: ${h.bestStreak}', style: const TextStyle(fontSize: 11, color: AppColors.txt3)),
                    ])),
                  ]),
                ),
              )),
            ],
            const SizedBox(height: 20),
          ],
        )),
      ],
    ),
  );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String icon, value, label;
  final Color color, colorL;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color, required this.colorL});
  @override
  Widget build(BuildContext context) => GlowCard(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: colorL, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 18)))),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.txt3, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _HeatMap extends StatelessWidget {
  final Map<DateTime, int> compMap;
  final int maxPerDay;
  const _HeatMap({required this.compMap, required this.maxPerDay});

  @override
  Widget build(BuildContext context) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final days = List.generate(91, (i) => today.subtract(Duration(days: 90 - i)));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 13, mainAxisSpacing: 4, crossAxisSpacing: 4,
        children: days.map((d) {
          final count = compMap[d] ?? 0;
          final ratio = maxPerDay > 0 ? count / maxPerDay : 0.0;
          Color col;
          if (ratio == 0) {
            col = AppColors.surf2;
          } else if (ratio < .33) {
            col = AppColors.purple.withValues(alpha: .25);
          } else if (ratio < .67) {
            col = AppColors.purple.withValues(alpha: .55);
          } else {
            col = AppColors.purple;
          }
          return Container(decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(3)));
        }).toList(),
      ),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Less', style: TextStyle(fontSize: 11, color: AppColors.txt3)),
        ...[AppColors.surf2, AppColors.purple.withValues(alpha: .25), AppColors.purple.withValues(alpha: .55), AppColors.purple].map((c) =>
          Padding(padding: const EdgeInsets.only(left: 4),
            child: Container(width: 14, height: 14, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))))),
        const SizedBox(width: 4),
        const Text('More', style: TextStyle(fontSize: 11, color: AppColors.txt3)),
      ]),
    ]);
  }
}

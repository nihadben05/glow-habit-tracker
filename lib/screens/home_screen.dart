import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../db/habit_provider.dart';
import '../db/profile_provider.dart';
import '../models/habit.dart';
import '../utils/theme.dart';
import '../widgets/shared.dart';
import 'habit_detail_screen.dart';
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> _dateStatus = {};
  String? _toastMsg;
 
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
 
  bool get _isToday => _dateOnly(_selectedDate) == _dateOnly(DateTime.now());
 
  Future<void> _loadDateStatus(HabitProvider prov) async {
    if (_isToday) {
      setState(() => _dateStatus = Map.from(prov.todayStatus));
    } else {
      final s = await prov.getStatusForDate(_selectedDate);
      if (mounted) setState(() => _dateStatus = s);
    }
  }
 
  void _showToast(String msg) {
    setState(() => _toastMsg = msg);
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }
 
  Future<void> _toggle(HabitProvider prov, Habit h) async {
    final wasDone = _isToday ? (prov.todayStatus[h.id] ?? false) : (_dateStatus[h.id] ?? false);
    if (_isToday) {
      await prov.toggleToday(h.id);
      if (!wasDone) _showToast('✦ ${h.name} completed!');
    }
    // Past dates: show info only (read-only for history)
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History is read-only. Toggle today\'s habits from the Today view.'), duration: Duration(seconds: 2)));
    }
    await _loadDateStatus(prov);
  }
 
  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(builder: (context, prov, _) {
      if (prov.loading) return const Center(child: CircularProgressIndicator(color: AppColors.purple));
 
      // Load date status when provider updates
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDateStatus(prov));
 
      final habits = prov.habits;
      final progress = _isToday ? prov.todayProgress
          : (habits.isEmpty ? 0.0 : _dateStatus.values.where((v) => v).length / habits.length);
      final done = _isToday ? prov.doneToday
          : _dateStatus.values.where((v) => v).length;
 
      final bottomInset = MediaQuery.of(context).viewPadding.bottom + 50;
      return Stack(children: [
        Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header
                _Header(date: _selectedDate, name: context.watch<ProfileProvider>().name),
                const SizedBox(height: 4),
                // ── Week strip
                _WeekStrip(
                  selected: _selectedDate,
                onSelect: (d) {
                  setState(() { _selectedDate = d; _dateStatus = {}; });
                  _loadDateStatus(prov);
                },
              ),
              const SizedBox(height: 20),
              // ── Progress card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProgressCard(done: done, total: habits.length, progress: progress, streak: prov.bestStreak),
              ),
              const SizedBox(height: 24),
              // ── Habits
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionLabel(
                  _isToday ? "Today's Habits" : DateFormat('MMM d').format(_selectedDate),
                  trailing: Text('${habits.length} habits', style: const TextStyle(fontSize: 13, color: AppColors.txt3)),
                ),
              ),
              const SizedBox(height: 14),
              if (habits.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: EmptyState(emoji: '🌱', title: 'No habits yet', subtitle: 'Tap + below to add your first habit'),
                )
              else
                ...habits.map((h) {
                  final done = _dateStatus[h.id] ?? (_isToday && (prov.todayStatus[h.id] ?? false));
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: _HabitTile(
                      habit: h,
                      done: done,
                      onToggle: () => _toggle(prov, h),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(value: prov, child: HabitDetailScreen(habitId: h.id)))),
                    ),
                  );
                }),
              const SizedBox(height: 20),
            ],
          )),
        ]),
        ),
        // Toast
        _toastMsg != null ? Positioned(top: 80, left: 24, right: 24, child: _Toast(message: _toastMsg!)) : SizedBox.shrink(),
      ]);
    });
  }
}
 
// ── Sub-widgets ──────────────────────────────────────────────
 
class _Header extends StatelessWidget {
  final DateTime date;
  final String name;
  const _Header({required this.date, required this.name});
 
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 🌙';
  }
 
  // First name only — "Alex Johnson" → "Alex"
  String get _firstName => name.trim().split(' ').first;
 
  // First letter for avatar
  String get _initial => name.isNotEmpty ? name[0].toUpperCase() : 'A';
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_greeting(), style: const TextStyle(fontSize: 13, color: AppColors.txt3, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          RichText(text: TextSpan(
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.txt),
            children: [
              const TextSpan(text: 'Hey, '),
              TextSpan(text: '$_firstName!', style: const TextStyle(color: AppColors.purple)),
            ],
          )),
        ]),
        Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.purple, AppColors.mint])),
          child: Center(child: Text(_initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
        ),
      ]),
    );
  }
}
 
class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  const _WeekStrip({required this.selected, required this.onSelect});
 
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
 
  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 7,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = today.add(Duration(days: i - 3));
          final isToday = d == today;
          final isSelected = _dateOnly(selected) == d;
          return GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.purple : AppColors.surf,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? AppColors.purple : AppColors.divider, width: isSelected ? 2 : 1.5),
                boxShadow: isSelected ? [BoxShadow(color: AppColors.purple.withValues(alpha: .25), blurRadius: 12, offset: const Offset(0, 4))] : [],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  DateFormat('E').format(d).substring(0, 1).toUpperCase() + DateFormat('E').format(d).substring(1, 2),
                  style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : AppColors.txt3, fontWeight: FontWeight.w600, letterSpacing: .5),
                ),
                const SizedBox(height: 4),
                Text('${d.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.txt)),
                const SizedBox(height: 4),
                Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? (isSelected ? Colors.white60 : AppColors.purple)
                        : Colors.transparent,
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
 
class _ProgressCard extends StatelessWidget {
  final int done, total;
  final double progress;
  final int streak;
  const _ProgressCard({required this.done, required this.total, required this.progress, required this.streak});
 
  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple, Color(0xFF9B6FFF)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: .3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Today's Progress", style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('$pct%', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
            const SizedBox(height: 4),
            Text('$done of $total habits done', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              const Text('🔥', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text('$streak day\nstreak', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Stack(children: [
            Container(height: 8, color: Colors.white.withValues(alpha: .25)),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(height: 8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50))),
            ),
          ]),
        ),
      ]),
    );
  }
}
 
class _HabitTile extends StatelessWidget {
  final Habit habit;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  const _HabitTile({required this.habit, required this.done, required this.onToggle, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: done ? habit.colorLight : AppColors.surf,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: done ? habit.color.withValues(alpha: .25) : AppColors.divider, width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: habit.colorLight, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text(habit.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(habit.name, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.txt,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.txt2,
            )),
            const SizedBox(height: 4),
            Row(children: [
              AppChip(label: habit.freq, color: habit.color, colorL: habit.colorLight),
              const SizedBox(width: 8),
              Text('🔥 ${habit.streak} days', style: const TextStyle(fontSize: 11, color: AppColors.txt3)),
            ]),
          ])),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.txt3, size: 18),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30, height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? habit.color : Colors.transparent,
                  border: Border.all(color: done ? habit.color : AppColors.surf3, width: 2),
                ),
                child: done ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
 
class _Toast extends StatelessWidget {
  final String message;
  const _Toast({required this.message});
  @override
  Widget build(BuildContext context) => Material(
    elevation: 6,
    borderRadius: BorderRadius.circular(50),
    color: AppColors.purple,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
    ),
  );
}
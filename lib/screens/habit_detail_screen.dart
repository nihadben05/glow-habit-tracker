import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../db/habit_provider.dart';
import '../models/habit.dart';
import '../utils/theme.dart';
import '../widgets/shared.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});
  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  List<HabitLog> _logs = [];
  bool _loadingLogs = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prov = context.read<HabitProvider>();
    final logs = await prov.getLogsForHabit(widget.habitId);
    if (mounted) setState(() { _logs = logs; _loadingLogs = false; });
  }

  Habit? _habit(HabitProvider prov) {
    try { return prov.habits.firstWhere((h) => h.id == widget.habitId); }
    catch (_) { return null; }
  }

  double _completionRate() {
    if (_logs.isEmpty) return 0;
    return _logs.where((l) => l.completed).length / _logs.length;
  }

  // Last 28 days grid status
  Map<DateTime, bool> _buildCalendarMap() {
    final map = <DateTime, bool>{};
    for (final log in _logs) {
      map[DateTime(log.date.year, log.date.month, log.date.day)] = log.completed;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(builder: (context, prov, _) {
      final habit = _habit(prov);
      if (habit == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Habit not found')),
        );
      }

      final rate = (_completionRate() * 100).round();
      final calMap = _buildCalendarMap();

      return Scaffold(
        backgroundColor: AppColors.bg,
        body: CustomScrollView(slivers: [
          // Hero header
          SliverToBoxAdapter(child: Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [habit.color, habit.color.withValues(alpha: .7)],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: prov, child: AddHabitScreen(existingHabit: habit))));
                    _loadLogs();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(20)),
                    child: const Row(children: [
                      Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              Text(habit.emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              Text(habit.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(20)),
                  child: Text(habit.freq, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                if (habit.reminderTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      const Icon(Icons.notifications_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(_formatTime(habit.reminderTime!), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
              ]),
            ]),
          )),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // Stats row
              Row(children: [
                Expanded(child: _StatMini(icon: '🔥', value: '${habit.streak}', label: 'Current')),
                const SizedBox(width: 12),
                Expanded(child: _StatMini(icon: '⭐', value: '${habit.bestStreak}', label: 'Best')),
                const SizedBox(width: 12),
                Expanded(child: _StatMini(icon: '📅', value: '$rate%', label: 'Completion')),
              ]),
              const SizedBox(height: 20),

              // Calendar heatmap (last 28 days)
              GlowCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionLabel('Last 28 Days'),
                const SizedBox(height: 16),
                if (_loadingLogs)
                  const Center(child: CircularProgressIndicator(color: AppColors.purple))
                else
                  _MiniCalendar(calMap: calMap, color: habit.color),
              ])),
              const SizedBox(height: 16),

              // Recent logs
              GlowCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionLabel('Recent Activity'),
                const SizedBox(height: 12),
                if (_loadingLogs) ...[
                  const Center(child: CircularProgressIndicator(color: AppColors.purple)),
                ],
                if (!_loadingLogs && _logs.isEmpty) ...[
                  const EmptyState(emoji: '📋', title: 'No logs yet', subtitle: 'Complete this habit to see your history'),
                ],
                ..._logs.take(14).map((log) => _LogRow(log: log, color: habit.color)),
              ])),
              const SizedBox(height: 16),

              // Delete button
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, prov, habit),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete Habit', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coral,
                  side: const BorderSide(color: AppColors.coral),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          )),
        ]),
      );
    });
  }

  Future<void> _confirmDelete(BuildContext ctx, HabitProvider prov, Habit h) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Delete "${h.name}" and all its history? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await prov.deleteHabit(h.id);
      if (ctx.mounted) Navigator.pop(ctx);
    }
  }

  String _formatTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    int h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final p = h >= 12 ? 'PM' : 'AM';
    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }
    return '$h:$m $p';
  }
}

class _StatMini extends StatelessWidget {
  final String icon, value, label;
  const _StatMini({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => GlowCard(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.txt)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.txt3)),
    ]),
  );
}

class _MiniCalendar extends StatelessWidget {
  final Map<DateTime, bool> calMap;
  final Color color;
  const _MiniCalendar({required this.calMap, required this.color});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(28, (i) {
      final d = DateTime(today.year, today.month, today.day).subtract(Duration(days: 27 - i));
      return d;
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Day labels
      Row(children: ['M','T','W','T','F','S','S'].map((d) =>
        Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 10, color: AppColors.txt3, fontWeight: FontWeight.w600))))
      ).toList()),
      const SizedBox(height: 6),
      // Grid
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        mainAxisSpacing: 6, crossAxisSpacing: 6,
        children: days.map((d) {
          final key = DateTime(d.year, d.month, d.day);
          final done = calMap[key];
          final isToday = key == DateTime(today.year, today.month, today.day);
          return Container(
            decoration: BoxDecoration(
              color: done == true ? color : (done == false ? AppColors.coralL : AppColors.surf2),
              borderRadius: BorderRadius.circular(6),
              border: isToday ? Border.all(color: AppColors.txt, width: 2) : null,
            ),
            child: Center(child: Text(
              '${d.day}',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: done == true ? Colors.white : AppColors.txt3),
            )),
          );
        }).toList(),
      ),
      const SizedBox(height: 10),
      Row(children: [
        _Legend(color: color, label: 'Done'),
        const SizedBox(width: 16),
        _Legend(color: AppColors.coralL, label: 'Missed', textColor: AppColors.coral),
        const SizedBox(width: 16),
        _Legend(color: AppColors.surf2, label: 'No data'),
      ]),
    ]);
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;
  const _Legend({required this.color, required this.label, this.textColor = AppColors.txt3});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 11, color: textColor)),
  ]);
}

class _LogRow extends StatelessWidget {
  final HabitLog log;
  final Color color;
  const _LogRow({required this.log, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: log.completed ? color : AppColors.coralL,
        ),
        child: Icon(
          log.completed ? Icons.check_rounded : Icons.close_rounded,
          size: 14,
          color: log.completed ? Colors.white : AppColors.coral,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(
        DateFormat('EEE, MMM d').format(log.date),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.txt),
      )),
      Text(
        log.completed ? 'Completed' : 'Missed',
        style: TextStyle(fontSize: 12, color: log.completed ? color : AppColors.coral, fontWeight: FontWeight.w600),
      ),
    ]),
  );
}

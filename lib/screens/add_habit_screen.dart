import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/habit_provider.dart';
import '../models/habit.dart';
import '../utils/theme.dart';
import '../widgets/shared.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? existingHabit;
  const AddHabitScreen({super.key, this.existingHabit});
  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameCtrl = TextEditingController();
  String _emoji = '🏃';
  Color  _color = AppColors.purple;
  String _freq  = 'daily';
  String? _reminderTime;
  bool _saving = false;

  static const _emojis = ['🏃','🧘','📚','💧','✍️','🎯','💪','🌿','🎨','🧠','🌅','🥗','🎵','🚴','🏊','💊','🍎','🧹','💻','🎤'];
  static const _freqLabels = {'daily':'Daily','weekdays':'Weekdays','weekends':'Weekends','3x_week':'3x / Week'};

  bool get _isEdit => widget.existingHabit != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final h = widget.existingHabit!;
      _nameCtrl.text = h.name;
      _emoji = h.emoji;
      _color = h.color;
      _freq  = h.freq;
      _reminderTime = h.reminderTime;
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a habit name')));
      return;
    }
    setState(() => _saving = true);
    try {
      final prov = context.read<HabitProvider>();
      if (_isEdit) {
        await prov.updateHabit(widget.existingHabit!.copyWith(
          name: name, emoji: _emoji, colorValue: _color.toARGB32(),
          freq: _freq, reminderTime: _reminderTime,
        ));
      } else {
        await prov.addHabit(name: name, emoji: _emoji, color: _color, freq: _freq, reminderTime: _reminderTime);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save habit. Please try again.')));
      }
    }
  }

  Future<void> _pickTime() async {
    final current = _reminderTime != null
        ? TimeOfDay(hour: int.parse(_reminderTime!.split(':')[0]), minute: int.parse(_reminderTime!.split(':')[1]))
        : const TimeOfDay(hour: 7, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null && mounted) {
      setState(() {
        _reminderTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  String _formatTime(String t) {
    final p = t.split(':');
    int h = int.parse(p[0]);
    final m = p[1];
    final am = h >= 12 ? 'PM' : 'AM';
    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }
    return '$h:$m $am';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.surf, shape: BoxShape.circle, border: Border.all(color: AppColors.divider),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)]),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.txt2, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Text(_isEdit ? 'Edit Habit' : 'New Habit',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.txt)),
          ]),
        ),
        const SizedBox(height: 20),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Habit Name', style: TextStyle(fontSize: 14, color: AppColors.txt, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.txt, fontSize: 15, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(hintText: 'e.g. Morning Run'),
            ),
            const SizedBox(height: 24),

            const Text('Emoji', style: TextStyle(fontSize: 14, color: AppColors.txt, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: _emojis.map((e) {
              final sel = e == _emoji;
              return GestureDetector(
                onTap: () => setState(() => _emoji = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.lightFor(_color) : AppColors.surf,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sel ? _color : AppColors.divider, width: sel ? 2 : 1.5),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
                ),
              );
            }).toList()),
            const SizedBox(height: 24),

            const Text('Color', style: TextStyle(fontSize: 14, color: AppColors.txt, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
            const SizedBox(height: 24),

            const Text('Frequency', style: TextStyle(fontSize: 14, color: AppColors.txt, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: _freqLabels.entries.map((e) {
              final sel = e.key == _freq;
              return GestureDetector(
                onTap: () => setState(() => _freq = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.lightFor(_color) : AppColors.surf,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: sel ? _color : AppColors.divider, width: sel ? 2 : 1.5),
                  ),
                  child: Text(e.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? _color : AppColors.txt2)),
                ),
              );
            }).toList()),
            const SizedBox(height: 24),

            const Text('Reminder (optional)', style: TextStyle(fontSize: 14, color: AppColors.txt, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surf, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _reminderTime != null ? _color : AppColors.divider, width: _reminderTime != null ? 2 : 1.5),
                ),
                child: Row(children: [
                  Icon(Icons.notifications_outlined, color: _reminderTime != null ? _color : AppColors.txt3, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _reminderTime != null ? _formatTime(_reminderTime!) : 'Set reminder time',
                    style: TextStyle(fontSize: 15, color: _reminderTime != null ? AppColors.txt : AppColors.txt3),
                  ),
                  const Spacer(),
                  if (_reminderTime != null) ...[
                    GestureDetector(
                      onTap: () => setState(() => _reminderTime = null),
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.txt3),
                    ),
                  ]
                ]),
              ),
            ),
            const SizedBox(height: 36),

            PrimaryBtn(label: _isEdit ? 'Save Changes' : '✦ Create Habit', onTap: _save, loading: _saving),
            const SizedBox(height: 40),
          ]),
        )),
      ])),
    );
  }
}

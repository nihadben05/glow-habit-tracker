import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/planner_provider.dart';
import '../utils/theme.dart';
import '../widgets/shared.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlannerProvider>(
      builder: (context, planner, _) {
        final dateLabel = '${planner.selectedDate.month}/${planner.selectedDate.day}/${planner.selectedDate.year}';

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            centerTitle: true,
            title: const Text('Planner', style: TextStyle(color: AppColors.txt, fontWeight: FontWeight.w700)),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: AppColors.txt,
                        onPressed: () => planner.selectDate(planner.selectedDate.subtract(const Duration(days: 1))),
                      ),
                      Column(
                        children: [
                          const Text('Selected Date', style: TextStyle(color: AppColors.txt3, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(dateLabel, style: const TextStyle(color: AppColors.txt, fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: AppColors.txt,
                        onPressed: () => planner.selectDate(planner.selectedDate.add(const Duration(days: 1))),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: _SmallCard(label: 'Total', value: '${planner.totalCount}')),
                      const SizedBox(width: 12),
                      Expanded(child: _SmallCard(label: 'Done', value: '${planner.completedCount}')),
                    ],
                  ),
                ),
                Expanded(
                  child: planner.loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
                      : planner.tasks.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: EmptyState(
                                emoji: '🗓️',
                                title: 'No tasks yet',
                                subtitle: 'Add a task to plan your day',
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: planner.tasks.length,
                              itemBuilder: (context, index) {
                                final task = planner.tasks[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GlowCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: task.completed,
                                          onChanged: (_) => planner.toggleComplete(task.id),
                                          activeColor: AppColors.purple,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.txt)),
                                              if (task.subtitle != null && task.subtitle!.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(task.subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.txt3)),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(task.time, style: const TextStyle(color: AppColors.txt3)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.purple,
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '08:00');
    Color selectedColor = AppColors.purple;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surf,
          title: const Text('Add Planner Task', style: TextStyle(color: AppColors.txt)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtitle (optional)')),
              const SizedBox(height: 12),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time')),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ColorDot(color: AppColors.purple, selected: selectedColor == AppColors.purple, onTap: () => selectedColor = AppColors.purple),
                  const SizedBox(width: 8),
                  _ColorDot(color: AppColors.orange, selected: selectedColor == AppColors.orange, onTap: () => selectedColor = AppColors.orange),
                  const SizedBox(width: 8),
                  _ColorDot(color: AppColors.blue, selected: selectedColor == AppColors.blue, onTap: () => selectedColor = AppColors.blue),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                context.read<PlannerProvider>().addTask(
                      title: titleCtrl.text.trim(),
                      subtitle: subtitleCtrl.text.trim().isEmpty ? null : subtitleCtrl.text.trim(),
                      time: timeCtrl.text.trim(),
                      color: selectedColor,
                    );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _SmallCard extends StatelessWidget {
  final String label;
  final String value;
  const _SmallCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.txt3, fontSize: 12)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.txt)),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }
}

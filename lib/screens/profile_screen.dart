import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/habit_provider.dart';
import '../db/planner_provider.dart';
import '../db/profile_provider.dart';
import '../utils/theme.dart';
import '../widgets/shared.dart';
import '../screens/auth_gate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, HabitProvider>(
      builder: (context, profile, habits, _) {
        final bestStreak = habits.bestStreak;
        final totalComp  = habits.totalCompletions;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple, Color(0xFF9B6FFF)]),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                      GestureDetector(
                        onTap: () => _editProfile(context, profile),
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
                    const SizedBox(height: 24),
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .2),
                        border: Border.all(color: Colors.white.withValues(alpha: .4), width: 3),
                      ),
                      child: Center(child: Text(profile.initial,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 36))),
                    ),
                    const SizedBox(height: 14),
                    Text(profile.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(profile.title, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: .8), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Text(profile.bio, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: .7), height: 1.5)),
                  ]),
                ),
                const SizedBox(height: 24),

                // ── Quick stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    Expanded(child: _PStatCard(value: '$bestStreak', label: 'Best Streak', icon: '🔥')),
                    const SizedBox(width: 12),
                    Expanded(child: _PStatCard(value: '${habits.totalHabits}', label: 'Habits', icon: '⭐')),
                    const SizedBox(width: 12),
                    Expanded(child: _PStatCard(value: '$totalComp', label: 'Completions', icon: '✅')),
                  ]),
                ),
                const SizedBox(height: 24),

                // ── My Habits
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SectionLabel('My Habits',
                    trailing: AppChip(label: '${habits.totalHabits} active', color: AppColors.purple, colorL: AppColors.purpleL)),
                ),
                const SizedBox(height: 12),

                if (habits.habits.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: EmptyState(emoji: '🌱', title: 'No habits yet', subtitle: 'Add your first habit from the Home tab'),
                  )
                else
                  ...habits.habits.map((h) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: GlowCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: h.colorLight, borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(h.emoji, style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(h.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.txt)),
                          const SizedBox(height: 4),
                          GradientProgressBar(value: h.bestStreak > 0 ? h.streak / h.bestStreak : 0, colors: [h.color, h.color.withValues(alpha: .4)]),
                          const SizedBox(height: 4),
                          Text('${h.streak} day streak • best: ${h.bestStreak}', style: const TextStyle(fontSize: 11, color: AppColors.txt3)),
                        ])),
                        const SizedBox(width: 8),
                        Text(h.emoji, style: const TextStyle(fontSize: 24)),
                      ]),
                    ),
                  )),
                const SizedBox(height: 24),

                // ── Settings
                const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: SectionLabel('Settings')),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: '🔔', title: 'Notifications', subtitle: 'Daily reminders',
                  trailing: Switch(
                    value: profile.notificationsEnabled,
                    onChanged: (_) => profile.toggleNotifications(),
                    activeThumbColor: AppColors.purple,
                  ),
                ),
                _SettingsTile(
                  icon: '🌙', title: 'Dark Mode', subtitle: 'Switch to dark theme',
                  trailing: Switch(
                    value: profile.darkMode,
                    onChanged: (_) => profile.toggleDarkMode(),
                    activeThumbColor: AppColors.purple,
                  ),
                ),
                _SettingsTile(
                  icon: '📊', title: 'Weekly Report', subtitle: 'Progress emails every Monday',
                  trailing: Switch(
                    value: profile.weeklyReport,
                    onChanged: (_) => profile.toggleWeeklyReport(),
                    activeThumbColor: AppColors.purple,
                  ),
                ),
                _SettingsTile(icon: '🔒', title: 'Privacy', subtitle: 'Data & privacy settings'),
                _SettingsTile(icon: '❓', title: 'Help & Support', subtitle: 'FAQs and contact us'),
                _SettingsTile(icon: '⭐', title: 'Rate the App', subtitle: 'Leave a review on the App Store'),
                const SizedBox(height: 16),

                // Sign out
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, profile),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.coral,
                      side: const BorderSide(color: AppColors.coral),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: Text('', style: TextStyle(fontSize: 12, color: AppColors.txt3))),
                const SizedBox(height: 40),
              ],
            )),
          ]),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, ProfileProvider profile) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // غلق dialog
            Navigator.pop(dialogContext);

            // logout
            await profile.logout();

            // reset data
            await context.read<HabitProvider>().load(userId: null);
            await context.read<PlannerProvider>().load(userId: null);

            // 🔥 أهم خطوة: امسح navigation وروح للـ login
           Navigator.pushAndRemoveUntil(
           context,
           MaterialPageRoute(builder: (_) => const AuthGate()),
           (route) => false,
             );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.coral,
          ),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}

  void _editProfile(BuildContext context, ProfileProvider profile) {
    final nameCtrl  = TextEditingController(text: profile.name);
    final titleCtrl = TextEditingController(text: profile.title);
    final bioCtrl   = TextEditingController(text: profile.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surf,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surf3, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.txt)),
            const SizedBox(height: 20),
            SheetField(controller: nameCtrl,  label: 'Name',  hint: 'Your full name'),
            const SizedBox(height: 14),
            SheetField(controller: titleCtrl, label: 'Title', hint: 'e.g. Habit Champion 🏆'),
            const SizedBox(height: 14),
            SheetField(controller: bioCtrl,   label: 'Bio',   hint: 'Tell us about yourself', maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await profile.update(newName: nameCtrl.text, newTitle: titleCtrl.text, newBio: bioCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple, foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
              ),
              child: const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PStatCard extends StatelessWidget {
  final String value, label, icon;
  const _PStatCard({required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => GlowCard(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.txt)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.txt3, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _SettingsTile extends StatelessWidget {
  final String icon, title, subtitle;
  final Widget? trailing;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
    child: GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.txt)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.txt3)),
        ])),
        trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.txt3, size: 20),
      ]),
    ),
  );
}
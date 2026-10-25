import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class HabitProvider extends ChangeNotifier {
  String? _userId;
  List<Habit> _habits = [];
  Map<String, bool> _todayStatus = {};
  Map<DateTime, int> _completionMap = {};
  bool _loading = true;

  String? get userId => _userId;

  List<Habit> get habits => _habits;
  Map<String, bool> get todayStatus => _todayStatus;
  Map<DateTime, int> get completionMap => _completionMap;
  bool get loading => _loading;

  int get doneToday => _todayStatus.values.where((v) => v).length;
  int get totalHabits => _habits.length;
  double get todayProgress => totalHabits == 0 ? 0 : doneToday / totalHabits;

  int get bestStreak => _habits.isEmpty ? 0
      : _habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);

  int get totalCompletions => _completionMap.values.fold(0, (a, b) => a + b);

  Future<void> load({String? userId}) async {
    _loading = true;
    notifyListeners();

    if (userId != null) {
      _userId = userId;
    } else {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('profile_user_id');
    }

    if (_userId == null || _userId!.isEmpty) {
      _habits = [];
      _todayStatus = {};
      _completionMap = {};
    } else {
      try {
        final habitsData = await ApiService.getHabits();
        _habits = habitsData.map((data) => Habit.fromJson(data)).toList();
        await _refreshTodayStatus();
        _completionMap = {};
      } catch (e) {
        debugPrint('Failed to load habits: $e');
        _habits = [];
        _todayStatus = {};
        _completionMap = {};
      }

      if (await _notificationsEnabled()) {
        for (final habit in _habits) {
          if (habit.reminderTime != null) {
            await NotificationService.instance.scheduleHabitReminder(
              habitId: habit.id,
              title: 'Habit reminder',
              body: 'Time to complete ${habit.name}',
              reminderTime: habit.reminderTime!,
              freq: habit.freq,
            );
          }
        }
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _refreshTodayStatus() async {
    final today = DateTime.now();
    final dateStr = today.toIso8601String().split('T')[0];
    if (_userId == null || _userId!.isEmpty) {
      _todayStatus = {for (final h in _habits) h.id: false};
      return;
    }
    try {
      final logs = await ApiService.getHabitLogs(dateStr);
      _todayStatus = {for (final h in _habits) h.id: false};
      for (final log in logs) {
        if (log['completed'] == 1) _todayStatus[log['habit_id']] = true;
      }
    } catch (e) {
      debugPrint('Failed to refresh today status: $e');
      _todayStatus = {for (final h in _habits) h.id: false};
    }
  }

  Future<void> toggleToday(String habitId) async {
    final current = _todayStatus[habitId] ?? false;
    final newVal = !current;
    final today = DateTime.now();
    final dateStr = today.toIso8601String().split('T')[0];

    try {
      await ApiService.toggleHabitLog(
        habitId: habitId,
        date: dateStr,
        completed: newVal,
      );

      _todayStatus[habitId] = newVal;

      final habitsData = await ApiService.getHabits();
      _habits = habitsData.map((data) => Habit.fromJson(data)).toList();

      _completionMap = {};

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to toggle habit: $e');
      rethrow;
    }
  }

  Future<void> addHabit({
    required String name,
    required String emoji,
    required Color color,
    required String freq,
    String? reminderTime,
  }) async {
    try {
      final habitData = {
        'name': name,
        'emoji': emoji,
        'colorValue': color.toARGB32(),
        'freq': freq,
        'reminderTime': reminderTime,
      };

      final result = await ApiService.createHabit(
        name: habitData['name'] as String,
        emoji: habitData['emoji'] as String,
        colorValue: habitData['colorValue'] as int,
        freq: habitData['freq'] as String,
        reminderTime: habitData['reminderTime'] as String?,
      );
      final newHabit = Habit.fromJson(result);

      _habits.add(newHabit);
      _todayStatus[newHabit.id] = false;

      if (reminderTime != null && await _notificationsEnabled()) {
        try {
          await NotificationService.instance.scheduleHabitReminder(
            habitId: newHabit.id,
            title: 'Habit reminder',
            body: 'Time to complete ${newHabit.name}',
            reminderTime: reminderTime,
            freq: freq,
          );
        } catch (e) {
          debugPrint('Failed to schedule notification: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add habit: $e');
      rethrow;
    }
  }

  Future<void> updateHabit(Habit updated) async {
    try {
      final habitData = {
        'name': updated.name,
        'emoji': updated.emoji,
        'colorValue': updated.colorValue,
        'freq': updated.freq,
        'reminderTime': updated.reminderTime,
      };

      await ApiService.updateHabit(
        habitId: updated.id,
        name: habitData['name'] as String,
        emoji: habitData['emoji'] as String,
        colorValue: habitData['colorValue'] as int,
        freq: habitData['freq'] as String,
        reminderTime: habitData['reminderTime'] as String?,
      );

      final idx = _habits.indexWhere((h) => h.id == updated.id);
      if (idx != -1) _habits[idx] = updated;

      if (await _notificationsEnabled()) {
        try {
          if (updated.reminderTime != null) {
            await NotificationService.instance.scheduleHabitReminder(
              habitId: updated.id,
              title: 'Habit reminder',
              body: 'Time to complete ${updated.name}',
              reminderTime: updated.reminderTime!,
              freq: updated.freq,
            );
          } else {
            await NotificationService.instance.cancelHabitReminders(updated.id);
          }
        } catch (e) {
          debugPrint('Failed to update notifications: $e');
        }
      } else {
        try {
          await NotificationService.instance.cancelHabitReminders(updated.id);
        } catch (e) {
          debugPrint('Failed to cancel notifications: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update habit: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await NotificationService.instance.cancelHabitReminders(id);
      await ApiService.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      _todayStatus.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete habit: $e');
      rethrow;
    }
  }

  Future<List<HabitLog>> getLogsForHabit(String habitId) async {
    return [];
  }

  Future<bool> _notificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('profile_notif') ?? true;
  }

  Future<Map<String, bool>> getStatusForDate(DateTime date) async {
    if (_userId == null || _userId!.isEmpty) {
      return {for (final h in _habits) h.id: false};
    }
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final logs = await ApiService.getHabitLogs(dateStr);
      return {
        for (final h in _habits) h.id: false,
        for (final l in logs) if (l['completed'] == 1) l['habit_id']: true,
      };
    } catch (e) {
      debugPrint('Failed to get status for date: $e');
      return {for (final h in _habits) h.id: false};
    }
  }
}

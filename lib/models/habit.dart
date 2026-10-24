import 'package:flutter/material.dart';
import '../utils/theme.dart';

class Habit {
  final String id;
  final String userId;
  String name;
  String emoji;
  int colorValue;
  String freq;
  String? reminderTime;
  int streak;
  int bestStreak;
  DateTime createdAt;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.freq,
    this.reminderTime,
    this.streak = 0,
    this.bestStreak = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get color => Color(colorValue);
  Color get colorLight => AppColors.lightFor(Color(colorValue));

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'emoji': emoji,
    'color_value': colorValue,
    'freq': freq,
    'reminder_time': reminderTime,
    'streak': streak,
    'best_streak': bestStreak,
    'created_at': createdAt.toIso8601String(),
  };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
    id: m['id'],
    userId: m['user_id'] ?? '',
    name: m['name'],
    emoji: m['emoji'],
    colorValue: m['color_value'],
    freq: m['freq'],
    reminderTime: m['reminder_time'],
    streak: m['streak'] ?? 0,
    bestStreak: m['best_streak'] ?? 0,
    createdAt: DateTime.parse(m['created_at']),
  );

  factory Habit.fromJson(Map<String, dynamic> json) => Habit.fromMap(json);

  Habit copyWith({
    String? userId,
    String? name, String? emoji, int? colorValue,
    String? freq, String? reminderTime, int? streak, int? bestStreak,
  }) => Habit(
    id: id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    colorValue: colorValue ?? this.colorValue,
    freq: freq ?? this.freq,
    reminderTime: reminderTime ?? this.reminderTime,
    streak: streak ?? this.streak,
    bestStreak: bestStreak ?? this.bestStreak,
    createdAt: createdAt,
  );
}

class HabitLog {
  final String id;
  final String habitId;
  final String userId;
  final DateTime date;
  bool completed;
  String? note;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.completed,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'habit_id': habitId,
    'user_id': userId,
    'date': date.toIso8601String(),
    'completed': completed ? 1 : 0,
    'note': note,
  };

  factory HabitLog.fromMap(Map<String, dynamic> m) => HabitLog(
    id: m['id'],
    habitId: m['habit_id'],
    userId: m['user_id'] ?? '',
    date: DateTime.parse(m['date']),
    completed: m['completed'] == 1,
    note: m['note'],
  );
}

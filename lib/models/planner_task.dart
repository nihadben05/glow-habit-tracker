import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PlannerTask {
  final String id;
  final String userId;
  String title;
  String? subtitle;
  String time;
  int colorValue;
  DateTime date;
  bool completed;

  PlannerTask({
    required this.id,
    required this.userId,
    required this.title,
    this.subtitle,
    required this.time,
    required this.colorValue,
    required this.date,
    this.completed = false,
  });

  Color get color => Color(colorValue);
  Color get colorLight => AppColors.lightFor(Color(colorValue));

  String get displayTime {
    final parts = time.split(':');
    if (parts.length < 2) {
      return time;
    }
    int h = int.tryParse(parts[0]) ?? 0;
    int m = int.tryParse(parts[1]) ?? 0;
    final period = h >= 12 ? 'PM' : 'AM';
    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }
    return '$h:${m.toString().padLeft(2, '0')} $period';
  }

  int get sortKey {
    final parts = time.split(':');
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'subtitle': subtitle,
    'time': time,
    'color_value': colorValue,
    'date': date.toIso8601String(),
    'completed': completed ? 1 : 0,
  };

  factory PlannerTask.fromMap(Map<String, dynamic> m) => PlannerTask(
    id: m['id'],
    userId: m['user_id'] ?? '',
    title: m['title'],
    subtitle: m['subtitle'] ?? m['description'],
    time: m['time'] ?? '12:00',
    colorValue: m['color_value'] ?? 0xFF2196F3,
    date: DateTime.parse(m['date']),
    completed: m['completed'] == 1,
  );

  factory PlannerTask.fromJson(Map<String, dynamic> json) => PlannerTask.fromMap(json);

  PlannerTask copyWith({
    String? userId,
    String? title, String? subtitle, String? time,
    int? colorValue, DateTime? date, bool? completed,
  }) => PlannerTask(
    id: id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    time: time ?? this.time,
    colorValue: colorValue ?? this.colorValue,
    date: date ?? this.date,
    completed: completed ?? this.completed,
  );
}

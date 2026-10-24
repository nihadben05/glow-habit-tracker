import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';

void main() {
  group('Habit', () {
    final createdAt = DateTime(2026, 1, 15, 8, 30);

    Habit sample() => Habit(
          id: 'h1',
          userId: 'u1',
          name: 'Drink water',
          emoji: '💧',
          colorValue: 0xFF7C5CFC,
          freq: 'daily',
          reminderTime: '08:30',
          streak: 3,
          bestStreak: 7,
          createdAt: createdAt,
        );

    test('toMap and fromMap round trip keeps every field', () {
      final copy = Habit.fromMap(sample().toMap());

      expect(copy.id, 'h1');
      expect(copy.userId, 'u1');
      expect(copy.name, 'Drink water');
      expect(copy.emoji, '💧');
      expect(copy.colorValue, 0xFF7C5CFC);
      expect(copy.freq, 'daily');
      expect(copy.reminderTime, '08:30');
      expect(copy.streak, 3);
      expect(copy.bestStreak, 7);
      expect(copy.createdAt, createdAt);
    });

    test('fromMap uses defaults for missing optional values', () {
      final habit = Habit.fromMap({
        'id': 'h2',
        'name': 'Read',
        'emoji': '📚',
        'color_value': 0xFF000000,
        'freq': 'weekdays',
        'created_at': createdAt.toIso8601String(),
      });

      expect(habit.userId, '');
      expect(habit.reminderTime, isNull);
      expect(habit.streak, 0);
      expect(habit.bestStreak, 0);
    });

    test('copyWith changes only the given fields', () {
      final updated = sample().copyWith(name: 'Drink more water', streak: 4);

      expect(updated.id, 'h1');
      expect(updated.name, 'Drink more water');
      expect(updated.streak, 4);
      expect(updated.bestStreak, 7);
      expect(updated.freq, 'daily');
    });
  });

  group('HabitLog', () {
    test('completed is stored as 1 or 0 and read back correctly', () {
      final log = HabitLog(
        id: 'l1',
        habitId: 'h1',
        userId: 'u1',
        date: DateTime(2026, 1, 15),
        completed: true,
      );

      expect(log.toMap()['completed'], 1);
      expect(HabitLog.fromMap(log.toMap()).completed, isTrue);

      log.completed = false;
      expect(log.toMap()['completed'], 0);
      expect(HabitLog.fromMap(log.toMap()).completed, isFalse);
    });
  });
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/planner_task.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'glow.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id            TEXT PRIMARY KEY,
          email         TEXT NOT NULL UNIQUE,
          password      TEXT NOT NULL,
          name          TEXT NOT NULL,
          title         TEXT,
          bio           TEXT,
          notifications INTEGER NOT NULL DEFAULT 1,
          dark_mode     INTEGER NOT NULL DEFAULT 0,
          weekly_report INTEGER NOT NULL DEFAULT 0,
          created_at    TEXT NOT NULL
        )
      ''');
      oldVersion = 2;
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE habits ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE habit_logs ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE planner_tasks ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id            TEXT PRIMARY KEY,
        email         TEXT NOT NULL UNIQUE,
        password      TEXT NOT NULL,
        name          TEXT NOT NULL,
        title         TEXT,
        bio           TEXT,
        notifications INTEGER NOT NULL DEFAULT 1,
        dark_mode     INTEGER NOT NULL DEFAULT 0,
        weekly_report INTEGER NOT NULL DEFAULT 0,
        created_at    TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id          TEXT PRIMARY KEY,
        user_id     TEXT NOT NULL,
        name        TEXT NOT NULL,
        emoji       TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        freq        TEXT NOT NULL,
        reminder_time TEXT,
        streak      INTEGER NOT NULL DEFAULT 0,
        best_streak INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        id        TEXT PRIMARY KEY,
        habit_id  TEXT NOT NULL,
        user_id   TEXT NOT NULL,
        date      TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        note      TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE (habit_id, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE planner_tasks (
        id          TEXT PRIMARY KEY,
        user_id     TEXT NOT NULL,
        title       TEXT NOT NULL,
        subtitle    TEXT,
        time        TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        date        TEXT NOT NULL,
        completed   INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// User account storage
  Future<void> insertUser(Map<String, Object?> user) async {
    final d = await db;
    await d.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, Object?>?> getUserByEmail(String email) async {
    final d = await db;
    final rows = await d.query('users', where: 'email = ?', whereArgs: [email]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> getUserById(String id) async {
    final d = await db;
    final rows = await d.query('users', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updateUser(String id, Map<String, Object?> data) async {
    final d = await db;
    await d.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  // ── HABITS ──────────────────────────────────────────────

  Future<List<Habit>> getAllHabits(String userId) async {
    final d = await db;
    final rows = await d.query('habits', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at ASC');
    return rows.map(Habit.fromMap).toList();
  }

  Future<void> insertHabit(Habit h) async {
    final d = await db;
    await d.insert('habits', h.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateHabit(Habit h) async {
    final d = await db;
    await d.update('habits', h.toMap(), where: 'id = ?', whereArgs: [h.id]);
  }

  Future<void> deleteHabit(String id) async {
    final d = await db;
    await d.delete('habits', where: 'id = ?', whereArgs: [id]);
    await d.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
  }

  // ── HABIT LOGS ──────────────────────────────────────────

  /// Get all logs for a specific date
  Future<List<HabitLog>> getLogsForDate(String userId, DateTime date) async {
    final d = await db;
    final dateStr = _dateOnly(date).toIso8601String();
    final rows = await d.query('habit_logs', where: 'date = ? AND user_id = ?', whereArgs: [dateStr, userId]);
    return rows.map(HabitLog.fromMap).toList();
  }

  /// Get all logs for a habit (last N days)
  Future<List<HabitLog>> getLogsForHabit(String habitId, {int days = 30}) async {
    final d = await db;
    final from = _dateOnly(DateTime.now().subtract(Duration(days: days))).toIso8601String();
    final rows = await d.query(
      'habit_logs',
      where: 'habit_id = ? AND date >= ?',
      whereArgs: [habitId, from],
      orderBy: 'date DESC',
    );
    return rows.map(HabitLog.fromMap).toList();
  }

  /// Get all logs for the last N days (for heatmap/stats)
  Future<List<HabitLog>> getRecentLogs(String userId, {int days = 91}) async {
    final d = await db;
    final from = _dateOnly(DateTime.now().subtract(Duration(days: days))).toIso8601String();
    final rows = await d.query('habit_logs', where: 'date >= ? AND user_id = ?', whereArgs: [from, userId], orderBy: 'date DESC');
    return rows.map(HabitLog.fromMap).toList();
  }

  Future<void> upsertLog(HabitLog log) async {
    final d = await db;
    await d.insert('habit_logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Toggle completion for a habit on a given date, returns new log
  Future<HabitLog> toggleHabitLog({
    required String habitId,
    required String logId,
    required String userId,
    required DateTime date,
    required bool newValue,
    String? note,
  }) async {
    final d = await db;
    final dateStr = _dateOnly(date).toIso8601String();
    final existing = await d.query('habit_logs',
      where: 'habit_id = ? AND date = ? AND user_id = ?', whereArgs: [habitId, dateStr, userId]);

    final log = HabitLog(
      id: existing.isEmpty ? logId : existing.first['id'] as String,
      habitId: habitId,
      userId: userId,
      date: _dateOnly(date),
      completed: newValue,
      note: note,
    );
    await d.insert('habit_logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return log;
  }

  // ── PLANNER ─────────────────────────────────────────────

  Future<List<PlannerTask>> getTasksForDate(String userId, DateTime date) async {
    final d = await db;
    final dateStr = _dateOnly(date).toIso8601String();
    final rows = await d.query('planner_tasks', where: 'date = ? AND user_id = ?', whereArgs: [dateStr, userId]);
    return rows.map(PlannerTask.fromMap).toList();
  }

  Future<void> insertTask(PlannerTask t) async {
    final d = await db;
    await d.insert('planner_tasks', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(PlannerTask t) async {
    final d = await db;
    await d.update('planner_tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> deleteTask(String id, {String? userId}) async {
    final d = await db;
    if (userId == null || userId.isEmpty) {
      await d.delete('planner_tasks', where: 'id = ?', whereArgs: [id]);
    } else {
      await d.delete('planner_tasks', where: 'id = ? AND user_id = ?', whereArgs: [id, userId]);
    }
  }

  Future<void> toggleTaskComplete(String id, bool completed, {String? userId}) async {
    final d = await db;
    if (userId == null || userId.isEmpty) {
      await d.update('planner_tasks', {'completed': completed ? 1 : 0},
          where: 'id = ?', whereArgs: [id]);
    } else {
      await d.update('planner_tasks', {'completed': completed ? 1 : 0},
          where: 'id = ? AND user_id = ?', whereArgs: [id, userId]);
    }
  }

  // ── STATS ───────────────────────────────────────────────

  /// Returns how many habits were completed on each date (for heatmap)
  Future<Map<DateTime, int>> getCompletionMap(String userId, {int days = 91}) async {
    final logs = await getRecentLogs(userId, days: days);
    final map = <DateTime, int>{};
    for (final log in logs) {
      if (log.completed) {
        final d = _dateOnly(log.date);
        map[d] = (map[d] ?? 0) + 1;
      }
    }
    return map;
  }

  /// Recalculate and update streak for a habit
  Future<int> recalcStreak(String habitId) async {
    final logs = await getLogsForHabit(habitId, days: 365);
    final completedDates = logs.where((l) => l.completed).map((l) => _dateOnly(l.date)).toSet();

    int streak = 0;
    DateTime cursor = _dateOnly(DateTime.now());

    // If today not done, start from yesterday
    if (!completedDates.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (completedDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // ── HELPERS ─────────────────────────────────────────────

  static DateTime _dateOnly(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day);

  Future<void> close() async {
    final d = await db;
    await d.close();
    _db = null;
  }

  Future<void> clearAllData(String userId) async {
    final d = await db;
    await d.delete('habit_logs', where: 'user_id = ?', whereArgs: [userId]);
    await d.delete('habits', where: 'user_id = ?', whereArgs: [userId]);
    await d.delete('planner_tasks', where: 'user_id = ?', whereArgs: [userId]);
  }
}

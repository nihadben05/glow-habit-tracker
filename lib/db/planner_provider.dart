import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/planner_task.dart';
import '../services/api_service.dart';

class PlannerProvider extends ChangeNotifier {
  String? _userId;
  List<PlannerTask> _tasks = [];
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;

  List<PlannerTask> get tasks {
    final sorted = [..._tasks];
    sorted.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return sorted;
  }

  DateTime get selectedDate => _selectedDate;
  bool get loading => _loading;

  int get completedCount => _tasks.where((t) => t.completed).length;
  int get totalCount => _tasks.length;

  Future<void> load({DateTime? date, String? userId}) async {
    _loading = true;
    notifyListeners();

    if (userId != null) {
      _userId = userId;
    } else {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('profile_user_id');
    }

    if (date != null) _selectedDate = date;
    if (_userId == null || _userId!.isEmpty) {
      _tasks = [];
    } else {
      try {
        final dateStr = _selectedDate.toIso8601String().split('T')[0];
        final tasksData = await ApiService.getPlannerTasks(dateStr);
        _tasks = tasksData.map((data) => PlannerTask.fromJson(data)).toList();
      } catch (e) {
        print('Failed to load planner tasks: $e');
        _tasks = [];
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await load(date: date);
  }

  Future<void> addTask({
    required String title,
    String? subtitle,
    required String time,
    required Color color,
  }) async {
    try {
      final dateStr = _selectedDate.toIso8601String().split('T')[0];
      final result = await ApiService.createTask(
        title: title,
        date: dateStr,
        description: subtitle,
        priority: 0, // Default priority
        time: time,
        colorValue: color.value,
      );
      final newTask = PlannerTask.fromJson(result);
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      print('Failed to add task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(PlannerTask updated) async {
    try {
      await ApiService.updateTask(
        taskId: updated.id,
        title: updated.title,
        subtitle: updated.subtitle,
        time: updated.time,
        colorValue: updated.colorValue,
        completed: updated.completed,
        description: updated.subtitle,
        priority: 0, // Default priority
      );
      final idx = _tasks.indexWhere((t) => t.id == updated.id);
      if (idx != -1) _tasks[idx] = updated;
      notifyListeners();
    } catch (e) {
      print('Failed to update task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await ApiService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      print('Failed to delete task: $e');
      rethrow;
    }
  }

  Future<void> toggleComplete(String id) async {
    try {
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx == -1) return;
      final newVal = !_tasks[idx].completed;
      _tasks[idx] = _tasks[idx].copyWith(completed: newVal);
      
      await ApiService.updateTask(
        taskId: id,
        title: _tasks[idx].title,
        completed: newVal,
        description: _tasks[idx].subtitle,
        priority: 0,
      );
      
      notifyListeners();
    } catch (e) {
      print('Failed to toggle task: $e');
      rethrow;
    }
  }
}

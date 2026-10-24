import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001/api';
    }
    return 'http://localhost:3001/api';
  }

  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    debugPrint('ApiService using baseUrl: $baseUrl');
  }

  static Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  static Future<List<dynamic>> getHabits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/habits'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch habits');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createHabit({
    required String name,
    required String emoji,
    required int colorValue,
    required String freq,
    String? reminderTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/habits'),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'emoji': emoji,
          'colorValue': colorValue,
          'freq': freq,
          'reminderTime': reminderTime,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create habit');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> updateHabit({
    required String habitId,
    required String name,
    required String emoji,
    required int colorValue,
    required String freq,
    String? reminderTime,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/habits/$habitId'),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'emoji': emoji,
          'colorValue': colorValue,
          'freq': freq,
          'reminderTime': reminderTime,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update habit');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> deleteHabit(String habitId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/habits/$habitId'),
        headers: _headers(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete habit');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getHabitLogs(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/habits/logs/$date'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch habit logs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> toggleHabitLog({
    required String habitId,
    required String date,
    required bool completed,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/habits/logs/toggle'),
        headers: _headers(),
        body: jsonEncode({
          'habitId': habitId,
          'date': date,
          'completed': completed,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to toggle habit log');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getPlannerTasks(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/planner/$date'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch tasks');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createTask({
    required String title,
    required String date,
    String? description,
    int priority = 0,
    String? time,
    int? colorValue,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/planner'),
        headers: _headers(),
        body: jsonEncode({
          'title': title,
          'description': description,
          'date': date,
          'priority': priority,
          'time': time,
          'colorValue': colorValue,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> updateTask({
    required String taskId,
    required String title,
    String? subtitle,
    String? time,
    int? colorValue,
    bool completed = false,
    String? description,
    int priority = 0,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/planner/$taskId'),
        headers: _headers(),
        body: jsonEncode({
          'title': title,
          'subtitle': subtitle,
          'time': time,
          'colorValue': colorValue,
          'description': description,
          'completed': completed,
          'priority': priority,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/planner/$taskId'),
        headers: _headers(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

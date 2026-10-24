import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database.dart';
import '../models/user_profile.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  static const _kName     = 'profile_name';
  static const _kTitle    = 'profile_title';
  static const _kBio      = 'profile_bio';
  static const _kNotif    = 'profile_notif';
  static const _kDark     = 'profile_dark';
  static const _kWeekly   = 'profile_weekly';
  static const _kEmail    = 'profile_email';
  static const _kPassword = 'profile_password';
  static const _kUserId   = 'profile_user_id';
  static const _kLoggedIn = 'profile_logged_in';

  UserProfile profile = UserProfile();

  bool isLoggedIn = false;
  String? _storedUserId;
  String? _storedEmail;

  String? get userId         => _storedUserId;
  String get name            => profile.name;
  String get title           => profile.title;
  String get bio             => profile.bio;
  String get initial         => profile.initial;
  bool get notificationsEnabled => profile.notificationsEnabled;
  bool get darkMode             => profile.darkMode;
  bool get weeklyReport         => profile.weeklyReport;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn      = prefs.getBool(_kLoggedIn) ?? false;
    _storedUserId   = prefs.getString(_kUserId);
    _storedEmail    = prefs.getString(_kEmail);

    if (_storedUserId != null) {
      final row = await AppDatabase.instance.getUserById(_storedUserId!);
      if (row != null) {
        profile = UserProfile.fromMap({
          'name':                 row['name'],
          'title':                row['title'],
          'bio':                  row['bio'],
          'notificationsEnabled': row['notifications'] == 1,
          'darkMode':             row['dark_mode'] == 1,
          'weeklyReport':         row['weekly_report'] == 1,
        });
      }
    }

    if (_storedUserId == null && _storedEmail != null) {
      profile = UserProfile.fromMap({
        'name':                 prefs.getString(_kName),
        'title':                prefs.getString(_kTitle),
        'bio':                  prefs.getString(_kBio),
        'notificationsEnabled': prefs.getBool(_kNotif),
        'darkMode':             prefs.getBool(_kDark),
        'weeklyReport':         prefs.getBool(_kWeekly),
      });
    }

    notifyListeners();
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty)     return 'Please enter your name.';
    if (!email.contains('@'))    return 'Please enter a valid email.';
    if (password.length < 6)     return 'Password must be at least 6 characters.';

    try {
      final userData = await ApiService.register(name: name, email: email, password: password);

      _storedUserId = userData!['userId'];
      _storedEmail = email.trim().toLowerCase();
      profile = profile.copyWith(name: userData['name']);
      isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserId, _storedUserId!);
      await prefs.setString(_kEmail, _storedEmail!);
      await prefs.setBool(_kLoggedIn, true);
      await _save();

      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty)   return 'Please enter your email.';
    if (password.isEmpty)       return 'Please enter your password.';

    try {
      final userData = await ApiService.login(email: email, password: password);

      _storedUserId = userData!['userId'];
      _storedEmail = email.toLowerCase();
      profile = profile.copyWith(name: userData['name']);
      isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserId, _storedUserId!);
      await prefs.setString(_kEmail, _storedEmail!);
      await prefs.setBool(_kLoggedIn, true);
      await _save();

      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> logout() async {
    isLoggedIn = false;
    _storedUserId = null;
    _storedEmail = null;
    profile = UserProfile();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
    await prefs.remove(_kUserId);
    await prefs.remove(_kEmail);
    await prefs.remove(_kPassword);
    await prefs.remove(_kName);
    await prefs.remove(_kTitle);
    await prefs.remove(_kBio);

    notifyListeners();
  }

  Future<void> update({
    String? newName,
    String? newTitle,
    String? newBio,
  }) async {
    profile = profile.copyWith(
      name:  (newName  != null && newName.isNotEmpty)  ? newName  : null,
      title: (newTitle != null && newTitle.isNotEmpty) ? newTitle : null,
      bio:   newBio,
    );
    if (_storedUserId != null) {
      await AppDatabase.instance.updateUser(_storedUserId!, {
        'name': profile.name,
        'title': profile.title,
        'bio': profile.bio,
        'notifications': profile.notificationsEnabled ? 1 : 0,
        'dark_mode': profile.darkMode ? 1 : 0,
        'weekly_report': profile.weeklyReport ? 1 : 0,
      });
    }
    await _save();
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    profile = profile.copyWith(notificationsEnabled: !profile.notificationsEnabled);
    await _saveUser();
    await _save();

    if (_storedUserId != null) {
      if (profile.notificationsEnabled) {
        final habits = await AppDatabase.instance.getAllHabits(_storedUserId!);
        for (final habit in habits) {
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
      } else {
        await NotificationService.instance.cancelAll();
      }
    }

    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    profile = profile.copyWith(darkMode: !profile.darkMode);
    await _saveUser();
    await _save();
    notifyListeners();
  }

  Future<void> toggleWeeklyReport() async {
    profile = profile.copyWith(weeklyReport: !profile.weeklyReport);
    await _saveUser();
    await _save();
    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (_storedUserId == null) return;
    await AppDatabase.instance.updateUser(_storedUserId!, {
      'name': profile.name,
      'title': profile.title,
      'bio': profile.bio,
      'notifications': profile.notificationsEnabled ? 1 : 0,
      'dark_mode': profile.darkMode ? 1 : 0,
      'weekly_report': profile.weeklyReport ? 1 : 0,
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName,   profile.name);
    await prefs.setString(_kTitle,  profile.title);
    await prefs.setString(_kBio,    profile.bio);
    await prefs.setBool(_kNotif,    profile.notificationsEnabled);
    await prefs.setBool(_kDark,     profile.darkMode);
    await prefs.setBool(_kWeekly,   profile.weeklyReport);
  }
}

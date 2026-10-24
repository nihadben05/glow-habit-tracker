import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  static const _kName     = 'profile_name';
  static const _kTitle    = 'profile_title';
  static const _kBio      = 'profile_bio';
  static const _kNotif    = 'profile_notif';
  static const _kDark     = 'profile_dark';
  static const _kWeekly   = 'profile_weekly';
  static const _kEmail    = 'profile_email';
  static const _kUserId   = 'profile_user_id';
  static const _kLoggedIn = 'profile_logged_in';

  UserProfile profile = UserProfile();

  bool isLoggedIn = false;
  String? _storedUserId;
  String? _storedEmail;

  // Getters
  String? get userId => _storedUserId;
  String get name => profile.name;
  String get title => profile.title;
  String get bio => profile.bio;
  String get initial => profile.initial;
  bool get notificationsEnabled => profile.notificationsEnabled;
  bool get darkMode => profile.darkMode;
  bool get weeklyReport => profile.weeklyReport;

  /// 🔹 Load data at app start
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    isLoggedIn    = prefs.getBool(_kLoggedIn) ?? false;
    _storedUserId = prefs.getString(_kUserId);
    _storedEmail  = prefs.getString(_kEmail);

    if (isLoggedIn && _storedUserId != null) {
      profile = UserProfile.fromMap({
        'name': prefs.getString(_kName),
        'title': prefs.getString(_kTitle),
        'bio': prefs.getString(_kBio),
        'notificationsEnabled': prefs.getBool(_kNotif) ?? true,
        'darkMode': prefs.getBool(_kDark) ?? false,
        'weeklyReport': prefs.getBool(_kWeekly) ?? false,
      });
    } else {
      profile = UserProfile(); // فارغ
    }

    notifyListeners();
  }

  // ───────── AUTH ─────────

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) return 'Enter name';
    if (!email.contains('@')) return 'Invalid email';
    if (password.length < 6) return 'Password too short';

    final error = await ApiService.register(
      name: name,
      email: email,
      password: password,
    );
    if (error != null) return error;

    _storedUserId = email;
    _storedEmail = email.toLowerCase();
    profile = profile.copyWith(name: name.trim());
    isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, _storedUserId!);
    await prefs.setString(_kEmail, _storedEmail!);
    await prefs.setBool(_kLoggedIn, true);

    await _save();
    notifyListeners();
    return null;
  }

  Future<String?> login({
  required String email,
  required String password,
}) async {
  try {
    final error = await ApiService.login(
      email: email,
      password: password,
    ).timeout(const Duration(seconds: 10));

    if (error != null) return error;

    _storedUserId = email;
    _storedEmail = email;

    profile = profile.copyWith(name: email.split('@').first);
    isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kUserId, email);

    await _save();

    return null;
  } catch (e) {
    return "Connection error";
  }
}
  Future<void> logout() async {
    isLoggedIn = false;
    _storedUserId = null;
    _storedEmail = null;
    profile = UserProfile();

    await ApiService.logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  // ───────── PROFILE ─────────

  Future<void> update({
    String? newName,
    String? newTitle,
    String? newBio,
  }) async {
    profile = profile.copyWith(
      name: (newName != null && newName.isNotEmpty) ? newName : null,
      title: (newTitle != null && newTitle.isNotEmpty) ? newTitle : null,
      bio: newBio,
    );

    await _save();
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    profile = profile.copyWith(
      notificationsEnabled: !profile.notificationsEnabled,
    );
    await _save();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    profile = profile.copyWith(
      darkMode: !profile.darkMode,
    );
    await _save();
    notifyListeners();
  }

  Future<void> toggleWeeklyReport() async {
    profile = profile.copyWith(
      weeklyReport: !profile.weeklyReport,
    );
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_kName, profile.name);
    await prefs.setString(_kTitle, profile.title);
    await prefs.setString(_kBio, profile.bio);
    await prefs.setBool(_kNotif, profile.notificationsEnabled);
    await prefs.setBool(_kDark, profile.darkMode);
    await prefs.setBool(_kWeekly, profile.weeklyReport);
  }
}
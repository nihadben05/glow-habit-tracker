class UserProfile {
  String name;
  String title;
  String bio;
  bool notificationsEnabled;
  bool darkMode;
  bool weeklyReport;

  UserProfile({
    this.name = '',
    this.title = '',
    this.bio = '',
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.weeklyReport = false,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '';

  UserProfile copyWith({
    String? name,
    String? title,
    String? bio,
    bool? notificationsEnabled,
    bool? darkMode,
    bool? weeklyReport,
  }) {
    return UserProfile(
      name: name ?? this.name,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      weeklyReport: weeklyReport ?? this.weeklyReport,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'title': title,
        'bio': bio,
        'notificationsEnabled': notificationsEnabled,
        'darkMode': darkMode,
        'weeklyReport': weeklyReport,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) {
    return UserProfile(
      name: m['name'] ?? '',
      title: m['title'] ?? '',
      bio: m['bio'] ?? '',
      notificationsEnabled: m['notificationsEnabled'] ?? true,
      darkMode: m['darkMode'] ?? false,
      weeklyReport: m['weeklyReport'] ?? false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/profile_provider.dart';
import 'db/habit_provider.dart';
import 'db/planner_provider.dart';
import 'services/notification_service.dart';
import 'services/api_service.dart';
import 'utils/theme.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();
  await ApiService.init();

  final profileProvider = ProfileProvider();
  await profileProvider.load();

  runApp(MyApp(profileProvider: profileProvider));
}

class MyApp extends StatelessWidget {
  final ProfileProvider profileProvider;

  const MyApp({super.key, required this.profileProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider(create: (_) => HabitProvider()..load()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glow App',
        theme: AppTheme.light,

        // ✅ FIRST PAGE IS SPLASH
        home: const SplashScreen(),
      ),
    );
  }
}
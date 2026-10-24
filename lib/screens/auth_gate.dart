import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/profile_provider.dart';
import 'shell.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    if (profile.isLoggedIn) {
      return const Shell();
    } else {
      return const LoginScreen();
    }
  }
}
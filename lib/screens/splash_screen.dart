import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.purple, AppColors.orange],
                  ),
                  boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: .3), blurRadius: 28, offset: const Offset(0, 10))],
                ),
                child: const Center(child: Text('✦', style: TextStyle(fontSize: 42, color: Colors.white))),
              ),
              const SizedBox(height: 32),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.txt, height: 1.15),
                  children: [
                    TextSpan(text: 'Build habits\n'),
                    TextSpan(text: 'Glow daily.', style: TextStyle(color: AppColors.purple)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Track your habits, plan your days, and grow into the best version of yourself.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.txt2, height: 1.6),
              ),
              const SizedBox(height: 48),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Dot(active: true), const SizedBox(width: 8),
                const _Dot(), const SizedBox(width: 8),
                const _Dot(),
              ]),
              const SizedBox(height: 32),
              _PrimaryBtn(
                label: 'Get Started →',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
              ),
              const SizedBox(height: 12),
              _GhostBtn(
                label: 'I already have an account',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});
  @override
  Widget build(BuildContext context) => Container(
    width: active ? 24 : 8, height: 8,
    decoration: BoxDecoration(
      color: active ? AppColors.purple : AppColors.surf3,
      borderRadius: BorderRadius.circular(50),
    ),
  );
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.purple, AppColors.orange],
        ),
        boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );
}

class _GhostBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.surf3, width: 1.5),
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.txt2, fontSize: 15, fontWeight: FontWeight.w500)),
    ),
  );
}

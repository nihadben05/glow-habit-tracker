import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/habit_provider.dart';
import '../db/planner_provider.dart';
import '../db/profile_provider.dart';
import '../utils/theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMsg = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final error = await context.read<ProfileProvider>().register(
        name:     _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (error != null) {
        setState(() => _errorMsg = error);
      } else {
        // Reload habit and planner state after clearing previous account data.
        final userId = context.read<ProfileProvider>().userId;
        await context.read<HabitProvider>().load(userId: userId);
        await context.read<PlannerProvider>().load(userId: userId);
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      setState(() => _errorMsg = 'An error occurred. Please try again.');
    }
    // On success AuthGate automatically switches to Shell
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // ── Back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surf, shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.txt2, size: 18),
                  ),
                ),
                const SizedBox(height: 32),
                // ── Logo small
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [AppColors.purple, AppColors.orange]),
                  ),
                  child: const Center(child: Text('✦', style: TextStyle(fontSize: 24, color: Colors.white))),
                ),
                const SizedBox(height: 20),
                const Text('Create your account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.txt)),
                const SizedBox(height: 6),
                const Text('Start building better habits today.', style: TextStyle(fontSize: 15, color: AppColors.txt2)),
                const SizedBox(height: 36),

                // ── Name
                Label('Full Name'),
                const SizedBox(height: 8),
                Field(
                  controller: _nameCtrl,
                  hint: 'Your Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 18),

                // ── Email
                Label('Email Address'),
                const SizedBox(height: 8),
                Field(
                  controller: _emailCtrl,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // ── Password
                Label('Password'),
                const SizedBox(height: 8),
                Field(
                  controller: _passwordCtrl,
                  hint: 'At least 6 characters',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: AppColors.txt3),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // ── Confirm Password
                Label('Confirm Password'),
                const SizedBox(height: 8),
                Field(
                  controller: _confirmCtrl,
                  hint: 'Repeat your password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: AppColors.txt3),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passwordCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Error banner
                if (_errorMsg != null) ...[
                  ErrorBanner(message: _errorMsg!),
                  const SizedBox(height: 16),
                ],

                // ── Submit
                PrimaryBtn(
                  label: 'Create Account',
                  loading: _loading,
                  onTap: _submit,
                ),
                const SizedBox(height: 20),

                // ── Already have account
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Already have an account? ', style: TextStyle(color: AppColors.txt2, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Log in', style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// LOGIN SCREEN  (also in this file for brevity — split if preferred)
// ─────────────────────────────────────────

// ── Shared auth widgets ──────────────────

class Label extends StatelessWidget {
  final String text;
  const Label(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.txt));
}

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const Field({super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: const TextStyle(color: AppColors.txt, fontSize: 15),
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.txt3),
      suffixIcon: suffixIcon,
    ),
  );
}

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.coralL,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.coral.withValues(alpha: .3)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.coral, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: const TextStyle(color: AppColors.coral, fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}

class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  const PrimaryBtn({super.key, required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
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
      child: loading
        ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
        : Text(label, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/habit_provider.dart';
import '../db/planner_provider.dart';
import '../db/profile_provider.dart';
import '../utils/theme.dart';
import 'shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    final profile = context.read<ProfileProvider>();

    final error = await profile.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (error != null) {
      setState(() => _errorMsg = error);
      return;
    }

    final userId = profile.userId;

    await context.read<HabitProvider>().load(userId: userId);
    await context.read<PlannerProvider>().load(userId: userId);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Shell()),
      (route) => false,
    );
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text('Demo app: clear data to reset account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          )
        ],
      ),
    );
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

                // 🔙 Back button (your design style)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surf,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: AppColors.txt2,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ✦ Logo
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.purple, AppColors.orange],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '✦',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.txt,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Log in to continue your journey.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.txt2,
                  ),
                ),

                const SizedBox(height: 35),

                // EMAIL
                const Text('Email Address',
                    style: TextStyle(color: AppColors.txt, fontWeight: FontWeight.w600)),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Email required' : null,
                ),

                const SizedBox(height: 18),

                // PASSWORD
                const Text('Password',
                    style: TextStyle(color: AppColors.txt, fontWeight: FontWeight.w600)),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Password required' : null,
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: AppColors.purple),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (_errorMsg != null)
                  Text(
                    _errorMsg!,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Log In',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // SIGNUP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
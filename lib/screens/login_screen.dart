// lib/screens/login_screen.dart
// Login screen with email/password and Google sign-in

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(_getErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        if (mounted) setState(() => _loading = false);
        return; // User cancelled
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(_getErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getErrorMessage(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('user-not-found')) return 'Bu e-posta ile kayitli kullanici bulunamadi.';
      if (msg.contains('wrong-password')) return 'Yanlis sifre girdiniz.';
      if (msg.contains('invalid-email')) return 'Gecersiz e-posta adresi.';
      if (msg.contains('user-disabled')) return 'Bu hesap devre disi birakilmis.';
      if (msg.contains('too-many-requests')) return 'Cok fazla deneme yaptiniz. Lutfen bekleyin.';
      if (msg.contains('invalid-credential')) return 'E-posta veya sifre hatali.';
    }
    return 'Bir hata olustu. Lutfen tekrar deneyin.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),

              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.gamepad_rounded, color: Colors.white, size: 46),
                ),
              ).animate().fadeIn(duration: 500.ms).scaleXY(begin: 0.8),

              const SizedBox(height: 20),

              // ── Title ─────────────────────────────────────────────────────
              const Center(
                child: Text(
                  'GameGuess',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 6),

              const Center(
                child: Text(
                  'Hesabiniza giris yapin',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 40),

              // ── Form ──────────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      hint: 'E-posta adresi',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'E-posta gerekli';
                        }
                        if (!val.contains('@')) return 'Gecerli bir e-posta girin';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Sifre',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Sifre gerekli';
                        if (val.length < 6) return 'Sifre en az 6 karakter olmali';
                        return null;
                      },
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 12),

              // ── Forgot password ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: const Text(
                    'Sifremi Unuttum',
                    style: TextStyle(color: AppColors.primaryLight, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Sign in button ────────────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signInWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Giris Yap',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ).animate(delay: 500.ms).fadeIn().scaleXY(begin: 0.95),

              const SizedBox(height: 24),

              // ── Divider ───────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.textMuted.withOpacity(0.3))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('veya', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ),
                  Expanded(child: Divider(color: AppColors.textMuted.withOpacity(0.3))),
                ],
              ).animate(delay: 600.ms).fadeIn(),

              const SizedBox(height: 24),

              // ── Google sign in ────────────────────────────────────────────
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _loading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: AppColors.surface,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        width: 22,
                        height: 22,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.g_mobiledata,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Google ile Giris Yap',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 700.ms).fadeIn(),

              const SizedBox(height: 30),

              // ── Register link ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hesabiniz yok mu? ',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text(
                      'Kayit Ol',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 800.ms).fadeIn(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

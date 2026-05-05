import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_social_button.dart';
import '../widgets/auth_text_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthController _authController;
  String? _lastErrorMessage;
  bool _navigatedToHome = false;

  @override
  void initState() {
    super.initState();
    _authController = AuthController.createDefault()
      ..addListener(_handleAuthStateChange);
  }

  @override
  void dispose() {
    _authController
      ..removeListener(_handleAuthStateChange)
      ..dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    TextInput.finishAutofillContext();
    await _authController.signUpWithEmailPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _usernameController.text.trim(),
    );
  }

  Future<void> _signUpWithGoogle() async {
    await _authController.signUpWithGoogle();
  }

  void _handleAuthStateChange() {
    if (!mounted) {
      return;
    }

    final errorMessage = _authController.errorMessage;
    if (errorMessage == null) {
      _lastErrorMessage = null;
    }
    if (errorMessage != null && errorMessage != _lastErrorMessage) {
      _lastErrorMessage = errorMessage;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    if (_authController.currentUser != null && !_navigatedToHome) {
      _navigatedToHome = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRegistrationSuccessDialogAndGoHome();
      });
    }
  }

  Future<void> _showRegistrationSuccessDialogAndGoHome() async {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteConstants.home,
      (route) => false,
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    if (!emailPattern.hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.length < 3) {
      return 'Nama pengguna harus terdiri minimal 3 karakter.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) {
      return 'Gunakan minimal 8 karakter.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      return 'Gunakan huruf dan angka.';
    }
    return null;
  }

  String? _validatePasswordMatch(String? value) {
    if (value != _passwordController.text) {
      return 'Kata sandi tidak cocok.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authController,
      builder: (context, _) {
        return AuthLayout(
          title: 'Buat akun',
          subtitle: 'Mulailah melacak perawatan kucing Anda dengan aman.',
          contentAlignment: const Alignment(0, -0.28),
          children: [
            Center(
              child: Image.asset(
                AuthAssets.signupCat,
                width: 132,
                height: 124,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Buat Akun Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AnaboolColors.brown,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  children: [
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      fieldKey: 'email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      prefixIcon: Icons.alternate_email_rounded,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _usernameController,
                      hintText: 'Nama Pengguna',
                      fieldKey: 'username',
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      prefixIcon: Icons.person_outline_rounded,
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'Kata Sandi',
                      fieldKey: 'password',
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Konfirmasi kata sandi',
                      fieldKey: 'confirm-password',
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      prefixIcon: Icons.verified_user_outlined,
                      validator: _validatePasswordMatch,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'Mendaftar',
              onPressed: () {
                _submit();
              },
              isLoading: _authController.isLoading,
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: Divider(color: AnaboolColors.peach)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Atau daftar dengan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AnaboolColors.brownSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AnaboolColors.peach)),
              ],
            ),
            const SizedBox(height: 16),
            AuthSocialButton(
              asset: AuthAssets.googleIcon,
              label: 'Daftar dengan Google',
              onPressed: () {
                _signUpWithGoogle();
              },
              isEnabled: !_authController.isLoading,
            ),
            const SizedBox(height: 18),
            const Text(
              'Gunakan 8 karakter atau lebih yang terdiri dari huruf dan angka.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AnaboolColors.brownSoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            AuthFooterLink(
              prefix: 'Sudah punya akun?',
              action: 'Masuk',
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(RouteConstants.login);
              },
            ),
          ],
        );
      },
    );
  }
}

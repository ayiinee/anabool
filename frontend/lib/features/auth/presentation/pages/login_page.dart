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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _authController;
  String? _lastErrorMessage;
  String? _lastStatusMessage;
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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    TextInput.finishAutofillContext();
    await _authController.loginWithEmailPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _loginWithGoogle() async {
    await _authController.loginWithGoogle();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final emailError = _validateEmail(email);

    if (emailError != null) {
      _showSnackBar(emailError);
      return;
    }

    await _authController.sendPasswordResetEmail(email);
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
      _showSnackBar(errorMessage);
    }

    final statusMessage = _authController.statusMessage;
    if (statusMessage == null) {
      _lastStatusMessage = null;
    }
    if (statusMessage != null && statusMessage != _lastStatusMessage) {
      _lastStatusMessage = statusMessage;
      _showSnackBar(statusMessage);
    }

    if (_authController.shouldRedirectToSignup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(RouteConstants.signup);
      });
      return;
    }

    if (_authController.currentUser != null && !_navigatedToHome) {
      _navigatedToHome = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteConstants.home,
          (route) => false,
        );
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
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

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Kata sandi diperlukan.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authController,
      builder: (context, _) {
        return AuthLayout(
          title: 'Selamat Datang Kembali',
          subtitle: 'Jaga keamanan akun Anabool Anda.',
          contentAlignment: const Alignment(0, -0.08),
          children: [
            Center(
              child: Image.asset(
                AuthAssets.loginCat,
                width: 132,
                height: 124,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Masuk ke akun Anda',
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
                      controller: _passwordController,
                      hintText: 'Kata Sandi',
                      fieldKey: 'password',
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: _validatePassword,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _authController.isLoading ? null : _resetPassword,
                style: TextButton.styleFrom(
                  foregroundColor: AnaboolColors.brown,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Lupa kata sandi?'),
              ),
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'Masuk',
              onPressed: () {
                _submit();
              },
              isLoading: _authController.isLoading,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: Divider(color: AnaboolColors.peach)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Atau masuk dengan',
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
              label: 'Masuk dengan Google',
              onPressed: () {
                _loginWithGoogle();
              },
              isEnabled: !_authController.isLoading,
            ),
            const SizedBox(height: 22),
            AuthFooterLink(
              prefix: "Tidak punya akun?",
              action: 'Mendaftar',
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(RouteConstants.signup);
              },
            ),
          ],
        );
      },
    );
  }
}

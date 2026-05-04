import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    TextInput.finishAutofillContext();
    Navigator.of(context).pushNamed(RouteConstants.home);
  }

  void _showUnavailableMessage(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login is not connected yet.'),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan ulang kata sandi belum terhubung.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
          onPressed: _submit,
        ),
        const SizedBox(height: 24),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AuthSocialButton(
              asset: AuthAssets.googleIcon,
              label: 'Lanjutkan dengan Google',
              onPressed: () => _showUnavailableMessage('Google'),
            ),
            AuthSocialButton(
              asset: AuthAssets.facebookIcon,
              label: 'Lanjutkan dengan Facebook',
              onPressed: () => _showUnavailableMessage('Facebook'),
            ),
            AuthSocialButton(
              asset: AuthAssets.xIcon,
              label: 'Lanjutkan dengan X',
              onPressed: () => _showUnavailableMessage('X'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Gunakan kata sandi unik dan hanya masuk ke akun Anda di perangkat tepercaya.',
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
          prefix: "Tidak punya akun?",
          action: 'Mendaftar',
          onTap: () {
            Navigator.of(context).pushReplacementNamed(RouteConstants.signup);
          },
        ),
      ],
    );
  }
}

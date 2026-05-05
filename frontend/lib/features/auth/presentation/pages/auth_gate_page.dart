import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_user_model.dart';
import '../../domain/entities/auth_exception.dart';
import '../../domain/entities/auth_sync_mode.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const LoginPage();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AnaboolColors.canvas,
            body: Center(
              child: CircularProgressIndicator(
                color: AnaboolColors.brown,
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return FutureBuilder<bool>(
            future: _validateBackendUser(user),
            builder: (context, validationSnapshot) {
              if (validationSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const _AuthLoadingScreen();
              }

              if (validationSnapshot.data == true) {
                return const HomePage();
              }

              return const SignupPage();
            },
          );
        }

        return const LoginPage();
      },
    );
  }

  Future<bool> _validateBackendUser(User user) async {
    try {
      await FirebaseAuthRemoteDatasource().syncUserProfile(
        AuthUserModel.fromFirebaseUser(user),
        mode: AuthSyncMode.login,
      );
      return true;
    } on AuthRegistrationRequiredException {
      return false;
    } catch (_) {
      // Keep the Firebase session so the signup page can finish Google register sync.
      return false;
    }
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: Center(
        child: CircularProgressIndicator(
          color: AnaboolColors.brown,
        ),
      ),
    );
  }
}

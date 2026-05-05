import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'login_page.dart';

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

        if (snapshot.data != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

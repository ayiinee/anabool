import 'package:flutter/material.dart';

import '../core/constants/route_constants.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/home/presentation/pages/home_page.dart';

class AppRouter {
  const AppRouter._();

  static const initialRoute = RouteConstants.login;

  static Map<String, WidgetBuilder> get routes {
    return {
      RouteConstants.login: (_) => const LoginPage(),
      RouteConstants.signup: (_) => const SignupPage(),
      RouteConstants.home: (_) => const HomePage(),
    };
  }
}

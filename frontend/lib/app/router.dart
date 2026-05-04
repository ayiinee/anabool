import 'package:flutter/material.dart';

import '../core/constants/route_constants.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/scan/domain/entities/scan_session.dart';
import '../features/scan/presentation/pages/scan_camera_page.dart';
import '../features/scan/presentation/pages/scan_preview_page.dart';
import '../features/scan/presentation/pages/scan_result_page.dart';

class AppRouter {
  const AppRouter._();

  static const initialRoute = RouteConstants.login;

  static Map<String, WidgetBuilder> get routes {
    return {
      RouteConstants.login: (_) => const LoginPage(),
      RouteConstants.signup: (_) => const SignupPage(),
      RouteConstants.home: (_) => const HomePage(),
      RouteConstants.scanCamera: (_) => const ScanCameraPage(),
      RouteConstants.scanPreview: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is ScanPreviewArguments) {
          return ScanPreviewPage(arguments: arguments);
        }

        return const ScanCameraPage();
      },
      RouteConstants.scanResult: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is ScanSession) {
          return ScanResultPage(session: arguments);
        }

        return const ScanCameraPage();
      },
    };
  }
}

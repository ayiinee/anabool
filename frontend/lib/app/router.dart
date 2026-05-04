import 'package:flutter/material.dart';

import '../core/constants/route_constants.dart';
import '../features/home/presentation/pages/home_page.dart';

class AppRouter {
  const AppRouter._();

  static const initialRoute = RouteConstants.home;

  static Map<String, WidgetBuilder> get routes {
    return {
      RouteConstants.home: (_) => const HomePage(),
    };
  }
}

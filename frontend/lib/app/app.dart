import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class AnaboolApp extends StatelessWidget {
  const AnaboolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ANABOOL',
      theme: AnaboolTheme.light,
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_bottom_navigation.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBottomNavigation(
      activeDestination: AppBottomNavigationDestination.home,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../widgets/anabul_status_section.dart';
import '../widgets/consultation_section.dart';
import '../widgets/hero_header.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/recommendation_section.dart';
import '../widgets/section_divider.dart';
import '../widgets/shortcut_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 118 + bottomInset),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroHeader(),
                  SizedBox(height: 34),
                  ShortcutSection(),
                  SectionDivider(),
                  ConsultationSection(),
                  SectionDivider(),
                  AnabulStatusSection(),
                  SectionDivider(),
                  RecommendationSection(),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: HomeBottomNavigation(),
            ),
          ],
        ),
      ),
    );
  }
}

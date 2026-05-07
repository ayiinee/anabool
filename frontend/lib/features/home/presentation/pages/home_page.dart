import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../widgets/design_image.dart';
import '../widgets/anabul_status_section.dart';
import '../widgets/consultation_section.dart';
import '../widgets/hero_header.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/recommendation_section.dart';
import '../widgets/section_divider.dart';
import '../widgets/shortcut_section.dart';

class HomePageArguments {
  const HomePageArguments({
    this.showCatOnboarding = false,
  });

  final bool showCatOnboarding;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _checkedOnboardingArgument = false;
  bool _shownCatOnboarding = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedOnboardingArgument) {
      return;
    }

    _checkedOnboardingArgument = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final shouldShow = arguments is HomePageArguments &&
        arguments.showCatOnboarding &&
        !_shownCatOnboarding;
    if (shouldShow) {
      _shownCatOnboarding = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showCatOnboardingDialog();
        }
      });
    }
  }

  Future<void> _showCatOnboardingDialog() async {
    final action = await showDialog<_CatOnboardingAction>(
      context: context,
      builder: (context) => const _CatOnboardingDialog(),
    );

    if (!mounted || action != _CatOnboardingAction.start) {
      return;
    }

    Navigator.of(context).pushNamed(RouteConstants.addCat);
  }

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

enum _CatOnboardingAction {
  start,
  skip,
}

class _CatOnboardingDialog extends StatelessWidget {
  const _CatOnboardingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DesignImage(
              asset: CatAssets.personalizationMascot,
              width: 112,
              height: 112,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            const Text(
              'Lengkapi Profil Kucing',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AnaboolColors.brownDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simpan rutinitas kotak pasir agar Ana bisa membantu memantau kebiasaan anabul.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AnaboolColors.brownSoft,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                key: const ValueKey('cat-onboarding-start'),
                onPressed: () {
                  Navigator.of(context).pop(_CatOnboardingAction.start);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AnaboolColors.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Mulai Sekarang',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const ValueKey('cat-onboarding-skip'),
              onPressed: () {
                Navigator.of(context).pop(_CatOnboardingAction.skip);
              },
              child: const Text(
                'Lewati Dulu',
                style: TextStyle(
                  color: AnaboolColors.brownSoft,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

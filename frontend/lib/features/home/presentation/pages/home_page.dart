import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../features/pickup/presentation/controllers/pickup_session.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
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

  Future<void> _openActivePickupOrder(BuildContext context) async {
    final shouldClearAfterOpen = pickupSessionController.isOrderComplete;

    await Navigator.of(context).pushNamed(
      RouteConstants.pickupTracking,
      arguments: pickupSessionController,
    );

    if (shouldClearAfterOpen) {
      pickupSessionController.clearCompletedOrder();
    }
  }

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
              padding: EdgeInsets.only(bottom: 188 + bottomInset),
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
            AnimatedBuilder(
              animation: pickupSessionController,
              builder: (context, _) {
                if (pickupSessionController.activeOrder == null) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  left: 16,
                  right: 16,
                  bottom: AppBottomNavigation.baseHeight + bottomInset + 10,
                  child: _ActivePickupOrderBanner(
                    onTap: () => _openActivePickupOrder(context),
                  ),
                );
              },
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

class _ActivePickupOrderBanner extends StatelessWidget {
  const _ActivePickupOrderBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = pickupSessionController;
    final order = controller.activeOrder;
    if (order == null) return const SizedBox.shrink();

    final categoryLabel =
        order.pickupType == 'pupuk' ? 'Pick Up Pupuk' : 'Pick Up Kotoran';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AnaboolColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AnaboolColors.peach.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: AnaboolColors.brown,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.activeOrderStatusLabel} - $categoryLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AnaboolColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.agent.name} | ${controller.activeOrderEtaLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AnaboolColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: AnaboolColors.brown,
                size: 24,
              ),
            ],
          ),
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

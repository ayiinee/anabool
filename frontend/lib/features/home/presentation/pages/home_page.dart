import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../features/pickup/presentation/controllers/pickup_session.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../widgets/anabul_status_section.dart';
import '../widgets/consultation_section.dart';
import '../widgets/hero_header.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/recommendation_section.dart';
import '../widgets/section_divider.dart';
import '../widgets/shortcut_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

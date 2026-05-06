import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/entities/pickup_agent.dart';
import '../controllers/pickup_controller.dart';

/// Screen 2 & 3: Agent selection with map placeholder, price/meowpoint toggle,
/// and list of nearby agents.
class PickupAgentsPage extends StatefulWidget {
  const PickupAgentsPage({super.key, required this.controller});

  final PickupController controller;

  @override
  State<PickupAgentsPage> createState() => _PickupAgentsPageState();
}

class _PickupAgentsPageState extends State<PickupAgentsPage> {
  PickupController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onControllerChange);
    // Auto-select first agent
    if (_ctrl.selectedAgentId == null && _ctrl.agents.isNotEmpty) {
      _ctrl.selectAgent(_ctrl.agents.first.id);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  void _onOrderTap() async {
    if (_ctrl.selectedAgentId == null) return;

    await _ctrl.createOrder();

    if (!mounted) return;
    if (_ctrl.activeOrder != null) {
      Navigator.of(context).pushNamed(
        RouteConstants.pickupTracking,
        arguments: _ctrl,
      );
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
            Column(
              children: [
                // ── App Bar ──
                _AgentsAppBar(
                  onBack: () => Navigator.of(context).maybePop(),
                ),

                // ── Map Placeholder ──
                Expanded(
                  flex: 5,
                  child: _MapPlaceholder(),
                ),

                // ── Bottom Sheet ──
                Expanded(
                  flex: 4,
                  child: _AgentBottomSheet(
                    controller: _ctrl,
                    onOrderTap: _onOrderTap,
                    bottomInset: bottomInset,
                  ),
                ),
              ],
            ),

            // Bottom navigation
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                onHomeTap: () => Navigator.of(context)
                    .pushReplacementNamed(RouteConstants.home),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// App Bar
// ──────────────────────────────────────────────────────────────────────────────

class _AgentsAppBar extends StatelessWidget {
  const _AgentsAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              tooltip: 'Kembali',
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFD3B8),
                foregroundColor: AnaboolColors.ink,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
            ),
          ),
          const Expanded(
            child: Text(
              'Pelacakan Langsung',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AnaboolColors.ink,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              tooltip: 'Bagikan',
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFD3B8),
                foregroundColor: AnaboolColors.ink,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.share_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Map Placeholder
// ──────────────────────────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0D6),
        image: const DecorationImage(
          image: AssetImage('assets/images/home/home-poster.png'),
          fit: BoxFit.cover,
          opacity: 0.08,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AnaboolColors.brown.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.map_rounded,
              size: 32,
              color: AnaboolColors.brown.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Peta akan ditampilkan di sini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AnaboolColors.brown.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dikembangkan oleh developer GIS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AnaboolColors.muted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Bottom Sheet with agent list
// ──────────────────────────────────────────────────────────────────────────────

class _AgentBottomSheet extends StatelessWidget {
  const _AgentBottomSheet({
    required this.controller,
    required this.onOrderTap,
    required this.bottomInset,
  });

  final PickupController controller;
  final VoidCallback onOrderTap;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1C000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD4D4D4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Payment mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PaymentModeToggle(controller: controller),
          ),

          const SizedBox(height: 8),

          // Agent list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 4,
                bottom: 120 + bottomInset,
              ),
              itemCount: controller.agents.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AnaboolColors.border.withValues(alpha: 0.4),
              ),
              itemBuilder: (context, index) {
                final agent = controller.agents[index];
                final isSelected = controller.selectedAgentId == agent.id;

                return _AgentTile(
                  agent: agent,
                  isSelected: isSelected,
                  paymentMode: controller.paymentMode,
                  onTap: () => controller.selectAgent(agent.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Payment Mode Toggle (Price vs MeowPoint)
// ──────────────────────────────────────────────────────────────────────────────

class _PaymentModeToggle extends StatelessWidget {
  const _PaymentModeToggle({required this.controller});

  final PickupController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleTab(
              label: 'Harga',
              icon: Icons.payments_outlined,
              isActive: controller.paymentMode == 'price',
              onTap: () => controller.togglePaymentMode('price'),
            ),
          ),
          Expanded(
            child: _ToggleTab(
              label: 'MeowPoint',
              icon: Icons.star_rounded,
              isActive: controller.paymentMode == 'meowpoint',
              onTap: () => controller.togglePaymentMode('meowpoint'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isActive ? AnaboolColors.brown : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AnaboolColors.brown.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : AnaboolColors.muted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : AnaboolColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Agent Tile
// ──────────────────────────────────────────────────────────────────────────────

class _AgentTile extends StatelessWidget {
  const _AgentTile({
    required this.agent,
    required this.isSelected,
    required this.paymentMode,
    required this.onTap,
  });

  final PickupAgent agent;
  final bool isSelected;
  final String paymentMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            // Agent avatar (cat mascot style)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AnaboolColors.peach.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: DesignImage(
                  asset: HomeAssets.pickupCat,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Agent info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AnaboolColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    agent.distanceLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AnaboolColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            // Price or MeowPoint
            if (paymentMode == 'meowpoint') ...[
              Icon(
                Icons.star_rounded,
                size: 16,
                color: AnaboolColors.header,
              ),
              const SizedBox(width: 3),
              Text(
                agent.meowpointsLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AnaboolColors.ink,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '\nMeowPoint',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AnaboolColors.muted,
                  height: 1.2,
                ),
              ),
            ] else ...[
              Text(
                agent.priceLabelIdr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AnaboolColors.ink,
                ),
              ),
            ],

            const SizedBox(width: 10),

            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AnaboolColors.brown : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isSelected ? AnaboolColors.brown : AnaboolColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

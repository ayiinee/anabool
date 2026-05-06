import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../controllers/pickup_controller.dart';

/// Screen 1: Pick-up category selection (Kotoran / Pupuk).
///
/// Matches the Figma design with a cute cat mascot in the center,
/// a "Pilih kategori" heading, and two category buttons side by side.
class PickupCategoryPage extends StatefulWidget {
  const PickupCategoryPage({super.key});

  @override
  State<PickupCategoryPage> createState() => _PickupCategoryPageState();
}

class _PickupCategoryPageState extends State<PickupCategoryPage> {
  late final PickupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PickupController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCategoryTap(String category) {
    _controller.selectCategory(category);
    Navigator.of(context).pushNamed(
      RouteConstants.pickupAgents,
      arguments: _controller,
    );
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
                _PickupAppBar(
                  title: 'Pick-up',
                  onBack: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context)
                          .pushReplacementNamed(RouteConstants.home);
                    }
                  },
                ),

                // ── Content ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 118 + bottomInset),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // Mascot cat image
                        const DesignImage(
                          asset: PickupAssets.pickupMascot,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 24),

                        // Heading
                        const Text(
                          'Pilih kategori',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AnaboolColors.ink,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Category buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Row(
                            children: [
                              Expanded(
                                child: _CategoryButton(
                                  label: 'Pick-up\nKotoran',
                                  isFilled: true,
                                  onTap: () => _onCategoryTap('kotoran'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _CategoryButton(
                                  label: 'Pick-up\nPupuk',
                                  isFilled: false,
                                  onTap: () => _onCategoryTap('pupuk'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom navigation
            const Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared AppBar used across pickup screens.
// ──────────────────────────────────────────────────────────────────────────────

class _PickupAppBar extends StatelessWidget {
  const _PickupAppBar({
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Back button
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              tooltip: 'Kembali',
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFD3B8),
                foregroundColor: AnaboolColors.ink,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
            ),
          ),

          // Title (centered)
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AnaboolColors.ink,
              ),
            ),
          ),

          // Trailing
          if (trailing != null)
            trailing!
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Category button widget.
// ──────────────────────────────────────────────────────────────────────────────

class _CategoryButton extends StatefulWidget {
  const _CategoryButton({
    required this.label,
    required this.isFilled,
    required this.onTap,
  });

  final String label;
  final bool isFilled;
  final VoidCallback onTap;

  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<_CategoryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.95 : 1.0,
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: widget.isFilled
                ? AnaboolColors.brown
                : AnaboolColors.peach.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: widget.isFilled
                ? null
                : Border.all(
                    color: AnaboolColors.brown.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
            boxShadow: [
              BoxShadow(
                color: widget.isFilled
                    ? AnaboolColors.brown.withValues(alpha: 0.3)
                    : const Color(0x14000000),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: widget.isFilled ? Colors.white : AnaboolColors.brown,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

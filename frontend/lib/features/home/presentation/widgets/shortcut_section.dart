import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import 'design_image.dart';
import 'home_components.dart';

class ShortcutSection extends StatelessWidget {
  const ShortcutSection({super.key});

  @override
  Widget build(BuildContext context) {
    const shortcuts = [
      _ShortcutItem('Aktifitas', HomeAssets.activityCat),
      _ShortcutItem('Modul', HomeAssets.educationCat),
      _ShortcutItem('Pick-up', HomeAssets.pickupCat),
      _ShortcutItem('Produk', HomeAssets.marketCat),
    ];

    return const Padding(
      padding: EdgeInsets.fromLTRB(
        HomeMetrics.horizontalPadding,
        8,
        HomeMetrics.horizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionTitle('Pintasan'),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: shortcuts,
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem(this.label, this.asset);

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return _InteractiveShortcut(
      label: label,
      asset: asset,
      onTap: () {
        if (label == 'Modul') {
          Navigator.of(context).pushNamed(RouteConstants.education);
          return;
        }

        if (label == 'Pick-up') {
          Navigator.of(context).pushNamed(RouteConstants.pickup);
          return;
        }

        if (label == 'Produk') {
          Navigator.of(context).pushNamed(RouteConstants.marketplace);
          return;
        }

        _showShortcutFeedback(context, label);
      },
    );
  }
}

class _InteractiveShortcut extends StatefulWidget {
  const _InteractiveShortcut({
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  State<_InteractiveShortcut> createState() => _InteractiveShortcutState();
}

class _InteractiveShortcutState extends State<_InteractiveShortcut> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool value) {
    if (_hovered == value) {
      return;
    }

    setState(() {
      _hovered = value;
    });
  }

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLifted = _hovered || _pressed;

    return SizedBox(
      width: 62,
      child: Column(
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            scale: _pressed ? 0.96 : (_hovered ? 1.04 : 1),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(HomeMetrics.tileRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(HomeMetrics.tileRadius),
                onTap: widget.onTap,
                onHover: _setHovered,
                onHighlightChanged: _setPressed,
                splashColor: AnaboolColors.header.withValues(alpha: 0.18),
                highlightColor: AnaboolColors.header.withValues(alpha: 0.10),
                hoverColor: AnaboolColors.header.withValues(alpha: 0.08),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: isLifted
                        ? const Color(0xFFFFFAF7)
                        : AnaboolColors.surface,
                    borderRadius: BorderRadius.circular(HomeMetrics.tileRadius),
                    border: Border.all(
                      color: isLifted
                          ? AnaboolColors.brownSoft
                          : AnaboolColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isLifted
                            ? const Color(0x287A3400)
                            : const Color(0x14000000),
                        blurRadius: isLifted ? 13 : 7,
                        offset: Offset(0, isLifted ? 5 : 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: DesignImage(
                      asset: widget.asset,
                      width: 62,
                      height: 62,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

void _showShortcutFeedback(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Pintasan $label sedang disiapkan.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

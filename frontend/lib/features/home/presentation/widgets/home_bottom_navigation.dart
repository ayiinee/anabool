import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import 'design_image.dart';
import 'home_components.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerGap =
            (constraints.maxWidth * 0.20).clamp(72.0, 88.0).toDouble();

        return SizedBox(
          height: 102 + bottomInset,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 76 + bottomInset,
                padding: EdgeInsets.only(bottom: bottomInset),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1C000000),
                      blurRadius: 12,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _BottomNavItem(
                      icon: Icons.home_rounded,
                      label: 'Beranda',
                      active: true,
                      onTap: () => _showNavigationFeedback(
                        context,
                        'Anda sudah berada di Beranda.',
                      ),
                    ),
                    _BottomNavItem(
                      icon: Icons.school_rounded,
                      label: 'Modul',
                      onTap: () => _showNavigationFeedback(
                        context,
                        'Halaman Modul sedang disiapkan.',
                      ),
                    ),
                    SizedBox(width: centerGap),
                    _BottomNavItem(
                      icon: Icons.storefront_rounded,
                      label: 'Produk',
                      onTap: () => _showNavigationFeedback(
                        context,
                        'Halaman Produk sedang disiapkan.',
                      ),
                    ),
                    _BottomNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profil',
                      onTap: () => _showNavigationFeedback(
                        context,
                        'Halaman Profil sedang disiapkan.',
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: _ScanButton(
                  onTap: () => _showNavigationFeedback(
                    context,
                    'Fitur scan kotak pasir sedang disiapkan.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _InteractiveBottomNavItem(
      icon: icon,
      label: label,
      active: active,
      onTap: onTap,
    );
  }
}

class _InteractiveBottomNavItem extends StatefulWidget {
  const _InteractiveBottomNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_InteractiveBottomNavItem> createState() =>
      _InteractiveBottomNavItemState();
}

class _InteractiveBottomNavItemState extends State<_InteractiveBottomNavItem> {
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
    final color = widget.active ? AnaboolColors.brown : AnaboolColors.muted;
    final isEngaged = _hovered || _pressed || widget.active;

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(HomeMetrics.cardRadius),
          onTap: widget.onTap,
          onHover: _setHovered,
          onHighlightChanged: _setPressed,
          splashColor: AnaboolColors.header.withValues(alpha: 0.16),
          highlightColor: AnaboolColors.header.withValues(alpha: 0.10),
          hoverColor: AnaboolColors.header.withValues(alpha: 0.08),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            scale: _pressed ? 0.96 : (_hovered ? 1.03 : 1),
            child: SizedBox(
              height: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    width: 34,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isEngaged
                          ? AnaboolColors.peach.withValues(alpha: 0.72)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 23,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight:
                            widget.active ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatefulWidget {
  const _ScanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton> {
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

    return Semantics(
      button: true,
      label: 'Pindai kotak pasir',
      child: Tooltip(
        message: 'Pindai kotak pasir',
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          scale: _pressed ? 0.94 : (_hovered ? 1.06 : 1),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkResponse(
              containedInkWell: true,
              customBorder: const CircleBorder(),
              onTap: widget.onTap,
              onHover: _setHovered,
              onHighlightChanged: _setPressed,
              splashColor: Colors.white.withValues(alpha: 0.20),
              highlightColor: Colors.white.withValues(alpha: 0.12),
              hoverColor: Colors.white.withValues(alpha: 0.10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color:
                      isLifted ? AnaboolColors.brownDark : AnaboolColors.brown,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: isLifted
                          ? const Color(0x557A3400)
                          : const Color(0x3D000000),
                      blurRadius: isLifted ? 16 : 12,
                      offset: Offset(0, isLifted ? 6 : 4),
                    ),
                    BoxShadow(
                      color: isLifted
                          ? const Color(0x72FFAA61)
                          : const Color(0x5CFFAA61),
                      blurRadius: isLifted ? 30 : 24,
                      spreadRadius: isLifted ? 5 : 3,
                      offset: Offset(0, isLifted ? 14 : 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: DesignImage(
                    asset: HomeAssets.scanIcon,
                    width: 49,
                    height: 49,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showNavigationFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

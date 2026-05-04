import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import 'design_image.dart';

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
                    const _BottomNavItem(
                      icon: Icons.home_rounded,
                      label: 'Beranda',
                      active: true,
                    ),
                    const _BottomNavItem(
                      icon: Icons.school_rounded,
                      label: 'Modul',
                    ),
                    SizedBox(width: centerGap),
                    const _BottomNavItem(
                      icon: Icons.storefront_rounded,
                      label: 'Produk',
                    ),
                    const _BottomNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Semantics(
                  button: true,
                  label: 'Pindai kotak pasir',
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AnaboolColors.brown,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3D000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Color(0x5CFFAA61),
                          blurRadius: 24,
                          spreadRadius: 3,
                          offset: Offset(0, 12),
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
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AnaboolColors.brown : AnaboolColors.muted;

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {},
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: color,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

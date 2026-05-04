import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import 'design_image.dart';

class ShortcutSection extends StatelessWidget {
  const ShortcutSection({super.key});

  static const _horizontalPadding = 22.0;

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
        _horizontalPadding,
        8,
        _horizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pintasan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
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
    return SizedBox(
      width: 62,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AnaboolColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: DesignImage(
                asset: asset,
                width: 62,
                height: 62,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            label,
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

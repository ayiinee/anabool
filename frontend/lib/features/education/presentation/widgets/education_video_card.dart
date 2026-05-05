import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../home/presentation/widgets/design_image.dart';

class EducationVideoCard extends StatelessWidget {
  const EducationVideoCard({
    super.key,
    required this.thumbnailAsset,
    required this.durationMinutes,
  });

  final String thumbnailAsset;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: const Color(0xFFFFF7F1),
              child: DesignImage(
                asset: thumbnailAsset.isEmpty
                    ? EducationAssets.moduleCat
                    : thumbnailAsset,
                fit: BoxFit.contain,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.34),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AnaboolColors.brown,
                  size: 36,
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$durationMinutes menit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

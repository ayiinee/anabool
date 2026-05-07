import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/entities/cat_profile.dart';

class CatProfileCard extends StatelessWidget {
  const CatProfileCard({
    super.key,
    required this.profile,
    this.onTap,
  });

  final CatProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF0C7B4)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F4),
                shape: BoxShape.circle,
                border: Border.all(color: AnaboolColors.brown, width: 2.5),
              ),
              child: ClipOval(
                child: DesignImage(
                  asset: profile.cat.avatarAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.cat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AnaboolColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (profile.cat.breed.isNotEmpty) profile.cat.breed,
                      profile.cat.lifeStage,
                      profile.cat.gender,
                    ].join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AnaboolColors.brownSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MetricPill(
                        icon: Icons.water_drop_outlined,
                        label: '${profile.cat.peeFrequencyPerDay}x pipis',
                      ),
                      const SizedBox(width: 6),
                      _MetricPill(
                        icon: Icons.pets_rounded,
                        label: '${profile.cat.poopFrequencyPerDay}x pup',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AnaboolColors.brown,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1EB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AnaboolColors.brown),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AnaboolColors.brownDark,
                  fontSize: 11,
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
